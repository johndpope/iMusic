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
    
    var noDataView: MPNoDataView!
    
    var fromType: MPSongListType = .Favorite

    var model = [MPSongModel]() {
        didSet {
            tableView.reloadData()
            if model.count == 0 {
                noDataView.isHidden = false
            }else {
                noDataView.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(NotCenter.NC_RefreshLocalModels), object: nil, queue: nil) { (center) in
            self.refreshData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func refreshData() {
        super.refreshData()
        
        var title = NSLocalizedString("我的音乐收藏", comment: "").decryptString()
        switch fromType {
        case .Recently:
            title = NSLocalizedString("最近播放", comment: "").decryptString()
            
            MPModelTools.getSongInTable(tableName: "RecentlyPlay") { (model) in
                if let m = model {
                    self.model = m.reversed()
                }
            }
            
            break
        case .Favorite:
            MPModelTools.getSongInTable(tableName: MPMyFavoriteViewController.classCode) { (model) in
                if let m = model {
                    self.model = m
                }
            }
            break
        case .Download:
            title = NSLocalizedString("我的下载", comment: "").decryptString()
            self.model.removeAll()
            var temps = [MPSongModel]()
            GKDownloadManager.sharedInstance()?.downloadedFileList()?.enumerateObjects({ (obj, idx, stop) in
                if let dModel = obj as? GKDownloadModel {
                    let sModel = MPSongModel()
                    sModel.data_songName = dModel.fileName
                    sModel.data_singerName = dModel.fileArtistName
                    sModel.data_artworkUrl = dModel.fileCover
                    sModel.data_artworkBigUrl = dModel.fileCover
                    sModel.data_songId = dModel.fileID
                    sModel.data_cache = dModel.fileUrl
                    sModel.data_localPath = dModel.fileLocalPath
                    temps.append(sModel)
                }
            })
            self.model = temps
            break
        case .Cache:
            title = NSLocalizedString("可离线播放", comment: "").decryptString()
            MPModelTools.getSongInTable(tableName: "CacheList") { (model) in
                if let m = model {
                    var temps = [MPSongModel]()
                    m.forEach({ (song) in
                        if MPDownloadTools.checkCacheSongExist(model: song) {
                            temps.append(song)
                        }
                    })
                    self.model = temps
                }
            }
            break
        default:
            break
        }
        addLeftItem(title: title, imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
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
        
        setupNoDataView(image: "pic_noresault", text: NSLocalizedString("找不到歌曲", comment: "").decryptString())
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPMyFavoriteHeaderView.md_viewFromXIB() as! MPMyFavoriteHeaderView
        hv.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: Constant.rowHeight))
        headerView = hv
        tableView.tableHeaderView = hv
        
        hv.clickBlock = {(sender) in
            if let _ = sender as? UIButton {
                if self.model.count > 0 {
                    self.randomPlay()
                }else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("找不到歌曲", comment: "").decryptString())
                }
            }
        }
    }
    
    private func setupNoDataView(image: String, text: String) {
        // 添加无数据提示View
        let sv = MPNoDataView.md_viewFromXIB() as! MPNoDataView
        let x: CGFloat = 20
        let width = (tableView.width - 40)
        let height = SCREEN_WIDTH * (180/375)
        let hvH = tableView.tableHeaderView?.height ?? 0
        let y = (SCREEN_HEIGHT-NavBarHeight-TabBarHeight - height - hvH) * 1/2
        sv.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
        sv.updateView(image: image, text: text)
        sv.isHidden = true
        noDataView = sv
        tableView.addSubview(sv)
    }
    
}
extension MPMyFavoriteViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSongTableViewCell
        // 构造当前播放专辑列表模型
        let json: [String : Any] = ["id": 0, "title": NSLocalizedString("我的音乐收藏", comment: "").decryptString(), "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": model.first?.data_artworkBigUrl ?? "pic_album_default", "tracksCount": model.count, "recentlyType": 3]
//        let album = GeneralPlaylists(JSON: json)
        let album = Mapper<GeneralPlaylists>().map(JSON: json)
        if fromType == .Favorite {
            cell.updateCell(model: model[indexPath.row], models: self.model, album: album, sourceType: 1)
        }else {
            cell.updateCell(model: model[indexPath.row], models: self.model, album: album)
        }
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
        
        // 构造当前播放专辑列表模型
        let json: [String : Any] = ["id": 0, "title": NSLocalizedString("我的音乐收藏", comment: "").decryptString(), "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": model.first?.data_artworkBigUrl ?? "pic_album_default", "tracksCount": model.count, "recentlyType": 3]
        let album = GeneralPlaylists(JSON: json)
        
        album?.data_songs = model
        MPModelTools.saveRecentlyAlbum(album: album!)
        
        MPModelTools.ressetPlayStatus(currentList: model)
        
        model[index == -1 ? 0 : index].data_playingStatus = 1
        
        MPModelTools.saveCurrentPlayList(currentList: model)
        
//        NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_PlayCurrentList), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, userInfo: ["randomMode" : 1])
    }
}
