//
//  MPEditSongListViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPSongTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
    static let detailVcName = "MPEditSongListDetailViewController"
}

class MPEditSongListViewController: BaseTableViewController {
    
    var headerView: MPEditSongListHeaderView?
    
    var songListModel: GeneralPlaylists? {
        didSet {
            // 标记当前歌单类型：8：创建的歌单
            songListModel?.data_recentlyType = 8
            headerView?.count = songListModel?.data_tracksCount ?? 0
        }
    }
    
    var model = [MPSongModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    override func refreshData() {
        super.refreshData()
        // 刷新数据
        MPModelTools.getSongInTable(tableName: songListModel?.data_title ?? "") { (model) in
            if let m = model {
                self.model = m
//                self.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString(songListModel?.data_title ?? "", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
    }
    
    override func clickLeft() {
        super.clickLeft()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.identifier
        tableView.backgroundColor = UIColor.white
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPEditSongListHeaderView.md_viewFromXIB() as! MPEditSongListHeaderView
        headerView = hv
        hv.count = songListModel?.data_tracksCount ?? 0
        hv.md_btnDidClickedBlock = {[weak self] (sender) in
            if sender.tag == 10001 {
                if self?.model.count ?? 0 > 0 {
                    self?.randomPlay()
                }else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("没有可播放的歌曲", comment: ""))
                }
            }else {
                let vc = MPEditSongListDetailViewController.init(nibName: Constant.detailVcName, bundle: nil)
                if let m = self?.model {
                    vc.model = m
                    vc.songListModel = self?.songListModel
                    // 刷新专辑信息
                    vc.updateAlbumBlock = {(album) in
                        self?.songListModel = album
                    }
                }
//                self?.navigationController?.pushViewController(vc, animated: true)
                self?.navigationController?.present(vc, animated: true, completion: nil)
            }
        }
        tableView.tableHeaderView = hv
    }
    
}
extension MPEditSongListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSongTableViewCell
        cell.updateCell(model: model[indexPath.row], models: self.model, album: self.songListModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
// MARK: - 随机播放
extension MPEditSongListViewController {
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
//            pv.currentPlayOrderMode = 1
//            pv.currentSong = cs
//            pv.model = model
//            pv.currentAlbum = songListModel
//            pv.bigStyle()
//        }
        
        songListModel?.data_songs = model
        MPModelTools.saveRecentlyAlbum(album: songListModel!)
        
        model[index == -1 ? 0 : index].data_playingStatus = 1
        
        MPModelTools.saveCurrentPlayList(currentList: model)
        
//        NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_PlayCurrentList), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, userInfo: ["randomMode" : 1])
    }
}
