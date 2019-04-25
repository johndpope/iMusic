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
    static let headerHeight = SCREEN_WIDTH * (95/375)
}

class MPLatestViewController: BaseTableViewController {
    
    var headView: MPLatestHeaderView?

    var models = [MPSongModel]() {
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
        if let hv = self.headView {
            MPModelTools.getLatestModel(latestType:  hv.currentType, tableName: hv.currentType) { (models) in
                if let m = models {
                    self.models = m
                }
            }
        }
        tableView.mj_header.endRefreshing()
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("最新歌曲", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
    }
    
    override func clickLeft() {
        super.clickLeft()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.identifier
        
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPLatestHeaderView.md_viewFromXIB() as! MPLatestHeaderView
        self.headView = hv
        self.headView?.height = Constant.headerHeight
        tableView.tableHeaderView = hv
        
        hv.sgmDidChangeBlock = {
            self.refreshData()
        }
        
        // 随机播放
        hv.clickBlock = {(sender) in
            if let _ = sender as? UIButton {
                if self.models.count > 0 {
                    self.randomPlay()
                }else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("没有可播放的歌曲", comment: ""))
                }
            }
        }
    }
    
}
extension MPLatestViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSongTableViewCell
        // 构造当前播放专辑列表模型
        let json: [String : Any] = ["id": 0, "title": NSLocalizedString("新歌首发", comment: ""), "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": models.first?.data_artworkBigUrl ?? "pic_album_default", "tracksCount": models.count, "recentlyType": 2]
//        let album = GeneralPlaylists(JSON: json)
        let album = Mapper<GeneralPlaylists>().map(JSON: json)
        cell.updateCell(model: models[indexPath.row], models: self.models, album: album)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
// MARK: - 随机播放
extension MPLatestViewController {
    private func randomPlay(index: Int = -1) {
        // 显示当前的播放View
//        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
//            var cs: MPSongModel?
//            // 循序不能倒过来
//            if index != -1 {
//                cs = models[index]
//            }else {
//                cs = models.first
//            }
//            // 随机播放
//            pv.currentPlayOrderMode = 1
//            pv.currentSong = cs
//            pv.model = models
//            // 构造当前播放专辑列表模型
//            let tempImg = cs?.data_artworkBigUrl ?? ""
//            let img = (tempImg == "" ? (cs?.data_artworkUrl ?? "") : tempImg) == "" ? "pic_album_default" : (tempImg == "" ? (cs?.data_artworkUrl ?? "") : tempImg)
//            // 构造当前播放专辑列表模型
//            let json: [String : Any] = ["id": 0, "title": NSLocalizedString("新歌首发", comment: ""), "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": img, "tracksCount": models.count, "recentlyType": 2]
//            //        let album = GeneralPlaylists(JSON: json)
//            let album = Mapper<GeneralPlaylists>().map(JSON: json)
//            pv.currentAlbum = album
//            pv.bigStyle()
//        }
        
        let cs = models[index == -1 ? 0 : index]
        // 构造当前播放专辑列表模型
        let tempImg = cs.data_artworkBigUrl ?? ""
        let img = (tempImg == "" ? (cs.data_artworkUrl ?? "") : tempImg) == "" ? "pic_album_default" : (tempImg == "" ? (cs.data_artworkUrl ?? "") : tempImg)
        // 构造当前播放专辑列表模型
        let json: [String : Any] = ["id": 0, "title": NSLocalizedString("新歌首发", comment: ""), "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": img, "tracksCount": models.count, "recentlyType": 2]
        let album = GeneralPlaylists(JSON: json)
        album?.data_songs = models
        MPModelTools.saveRecentlyAlbum(album: album!)
        
        cs.data_playingStatus = 1
        
        MPModelTools.saveCurrentPlayList(currentList: models)
        
//        NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_PlayCurrentList), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, userInfo: ["randomMode" : 1])
    }
}
