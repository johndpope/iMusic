//
//  MPLatestViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPSongTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
    static let headerHeight = SCREEN_WIDTH * (225/375)
}

class MPSongListViewController: BaseTableViewController {
    
    var headerSongModel: GeneralPlaylists? {
        didSet {
            playlistId = headerSongModel?.data_id ?? 0
            singerId = headerSongModel?.data_originalId ?? ""
        }
    }
    
    var playlistId: Int = 0
    var singerId  = ""
    
    /// 1: 歌单 2：歌手 3: youtube获取
    var type: Int = 1

    var model = [MPSongModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshData()
    }
    
    override func refreshData() {
        super.refreshData()
        if self.headerSongModel != nil {
            if type == 1 {
                MPModelTools.getSongListByIDModel(playlistId: playlistId, tableName: "") { (model) in
                    if let m = model {
                        self.model = m
                        self.saveListToCloud(m: m)
                    }
                }
            }else if type == 2 {
                MPModelTools.getSongerListByIDModel(singerId: singerId, tableName: "") { (model) in
                    if let m = model {
                        self.model = m
                        self.saveListToCloud(m: m)
                    }
                }
            }else if type == 3 {
                DiscoverCent?.requestSearchSongListByYoutube(playlistId: singerId, pageToken: "", complete: { (isSucceed, model, msg) in
                    switch isSucceed {
                    case true:
                        if let m = model?.data_songs {
                            self.model = m
                            self.headerSongModel?.data_tracksCount = model?.data_num ?? 0
                            (self.tableView.tableHeaderView as? MPSongListHeaderView)?.updateView(model: self.headerSongModel!)
                            self.saveListToCloud(m: m)
                        }
                        break
                    case false:
                        SVProgressHUD.showError(withStatus: msg)
                        break
                    }
                })
            }
        }
    }
    
    private func saveListToCloud(m: [MPSongModel]) {
        DispatchQueue.init(label: "SaveListToCloud").async {
            // 赋值到属性模型
            if m.count != self.headerSongModel?.data_data?.count {
                self.headerSongModel?.data_data = m
                
                // 更新到上传模型
                if var playlist = DiscoverCent?.data_CloudListUploadModel.data_playlist {
                    for i in 0..<playlist.count {
                        let item = playlist[i]
                        if item.data_title == self.headerSongModel?.data_title {
                            playlist[i] = self.headerSongModel!
                        }
                    }
                }
                
            }
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("歌单列表", comment: "").decryptString(), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
        addRightItem(imageName: "nav_icon_search")
}

override func clickLeft() {
    super.clickLeft()
    self.navigationController?.popViewController(animated: true)
}

override func clickRight(sender: UIButton) {
    super.clickRight(sender: sender)
    
    let vc = MPSearchViewController()
    self.navigationController?.pushViewController(vc, animated: true)
}
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.identifier
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPSongListHeaderView.md_viewFromXIB() as! MPSongListHeaderView
        hv.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: Constant.headerHeight))
        if let hm = self.headerSongModel {
            hv.updateView(model: hm)
        }
        let isExsist = MPModelTools.checkCollectListExsist(model: self.headerSongModel!, tableName: MPCollectSongListViewController.classCode)
        if isExsist {
            hv.xib_collect.isSelected = true
        }
        tableView.tableHeaderView = hv
        
        hv.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                if btn.tag == 10001 {
                    QYTools.shared.Log(log: "随机播放".decryptLog())
                    if self.model.count > 0 {
                        self.randomPlay()
                    }else {
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("找不到歌曲", comment: "").decryptString())
                    }
                }else {
                    QYTools.shared.Log(log: "收藏歌单".decryptLog())
                    self.headerSongModel?.data_collectionType = self.type
                    let isExsist = MPModelTools.checkCollectListExsist(model: self.headerSongModel!, tableName: MPCollectSongListViewController.classCode)
                    if !isExsist {
                        btn.isSelected = true
                        MPModelTools.saveCollectListModel(model: self.headerSongModel!, tableName: MPCollectSongListViewController.classCode)
                        
                        // 更新上传模型
                        MPModelTools.updateCloudListModel(type: 5)
                    }
                }
            }
        }
        
    }
    
}
extension MPSongListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSongTableViewCell
        if self.type == 1 {
            self.headerSongModel?.data_recentlyType = 5
        }else if type == 2 {
            self.headerSongModel?.data_recentlyType = 4
        }
        cell.updateCell(model: model[indexPath.row], models: self.model, album: self.headerSongModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
}

// MARK: - 随机播放
extension MPSongListViewController {
    private func randomPlay(index: Int = -1) {
        // 显示当前的播放View
//        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
//            var cs: MPSongModel?
//            // 循序不能倒过来
//            if index != -1 {
//                cs = model[index]
//            }else {
//                cs = model.first
//            }
//            // 随机播放
//            if self.type == 3 {
//                pv.currentSouceType = 0
//            }
//            pv.currentPlayOrderMode = 1
//            pv.currentSong = cs
//            pv.model = model
//            pv.currentAlbum = headerSongModel
//            pv.bigStyle()
//        }
        
        headerSongModel?.data_songs = model
        MPModelTools.saveRecentlyAlbum(album: headerSongModel!)
        
        MPModelTools.ressetPlayStatus(currentList: model)
        
        model[index == -1 ? 0 : index].data_playingStatus = 1
        
        MPModelTools.saveCurrentPlayList(currentList: model)
        
//        NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_PlayCurrentList), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, userInfo: ["randomMode" : 1])
    }
}
