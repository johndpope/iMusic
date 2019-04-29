//
//  MPLatestViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import ObjectMapper

private struct Constant {
    static let identifier = "MPSongTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
}

enum MPSongListType {
    case Favorite
    case Download
    case Cache
    case Recently
}

class MPMyFavoriteViewController: BaseTableViewController {
    
    var headerView: MPMyFavoriteHeaderView?
    
    var fromType: MPSongListType = .Favorite

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
        
        var title = NSLocalizedString("我的最爱", comment: "")
        switch fromType {
        case .Recently:
            title = NSLocalizedString("最近播放", comment: "")
            MPModelTools.getSongInTable(tableName: "RecentlyPlay") { (model) in
                if let m = model {
                    self.model = m.reversed()
//                    self.tableView.mj_header.endRefreshing()
                    
                    self.headerView?.count = model?.count ?? 0
                    
                    self.saveListToCloudModel(m: m)
                    
                }
            }
            break
        case .Favorite:
            MPModelTools.getSongInTable(tableName: MPMyFavoriteViewController.classCode) { (model) in
                if let m = model {
                    self.model = m
//                    self.tableView.mj_header.endRefreshing()
                    
                    self.headerView?.count = model?.count ?? 0
                    
                    self.saveListToCloudModel(m: m)
                }
            }
            break
        case .Download:
            title = NSLocalizedString("我的下载", comment: "")
            
//            self.saveListToCloudModel(m: m)
            
            break
        case .Cache:
            title = NSLocalizedString("离线歌曲", comment: "")
            break
        default:
            break
        }
        addLeftItem(title: title, imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
    }
    
    private func saveListToCloudModel(m: [MPSongModel]) {
        DispatchQueue.init(label: "SaveListToCloud").async {
            // 保存到上传模型
            switch self.fromType {
            case .Recently:
                if DiscoverCent?.data_CloudListUploadModel.data_history?.count != m.count {
                    DiscoverCent?.data_CloudListUploadModel.data_history = m
                }
                break
            case .Favorite:
                if DiscoverCent?.data_CloudListUploadModel.data_favorite?.count != m.count {
                    DiscoverCent?.data_CloudListUploadModel.data_favorite = m
                }
                break
            case .Download:
                if DiscoverCent?.data_CloudListUploadModel.data_download?.count != m.count {
                    DiscoverCent?.data_CloudListUploadModel.data_download = m
                }
                break
            default:
                break
            }
            
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
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
        
        let hv = MPMyFavoriteHeaderView.md_viewFromXIB() as! MPMyFavoriteHeaderView
        headerView = hv
        tableView.tableHeaderView = hv
        
        hv.clickBlock = {(sender) in
            if let _ = sender as? UIButton {
                if self.model.count > 0 {
                    self.randomPlay()
                }else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("没有可播放的歌曲", comment: ""))
                }
            }
        }
    }
    
}
extension MPMyFavoriteViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSongTableViewCell
        // 构造当前播放专辑列表模型
        let json: [String : Any] = ["id": 0, "title": NSLocalizedString("我的最爱", comment: ""), "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": model.first?.data_artworkBigUrl ?? "pic_album_default", "tracksCount": model.count, "recentlyType": 3]
//        let album = GeneralPlaylists(JSON: json)
        let album = Mapper<GeneralPlaylists>().map(JSON: json)
        cell.updateCell(model: model[indexPath.row], models: self.model, album: album)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
// MARK: - 随机播放
extension MPMyFavoriteViewController {
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
//            // 构造当前播放专辑列表模型
//            let json: [String : Any] = ["id": 0, "title": NSLocalizedString("我的最爱", comment: ""), "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": model.first?.data_artworkBigUrl ?? "pic_album_default", "tracksCount": model.count, "recentlyType": 3]
//            //        let album = GeneralPlaylists(JSON: json)
//            let album = Mapper<GeneralPlaylists>().map(JSON: json)
//            pv.currentAlbum = album
//            pv.bigStyle()
//        }
        
        // 构造当前播放专辑列表模型
        let json: [String : Any] = ["id": 0, "title": NSLocalizedString("我的最爱", comment: ""), "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": model.first?.data_artworkBigUrl ?? "pic_album_default", "tracksCount": model.count, "recentlyType": 3]
        let album = GeneralPlaylists(JSON: json)
        
        album?.data_songs = model
        MPModelTools.saveRecentlyAlbum(album: album!)
        
        model[index == -1 ? 0 : index].data_playingStatus = 1
        
        MPModelTools.saveCurrentPlayList(currentList: model)
        
//        NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_PlayCurrentList), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, userInfo: ["randomMode" : 1])
    }
}
