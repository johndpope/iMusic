//
//  MPLatestViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import  ObjectMapper

private struct Constant {
    static let identifier = "MPSongTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
}

class MPAlbumListViewController: BaseTableViewController {

    var tableName: String = ""
    
    var headerModel: MPRankingTempModel? {
        didSet {
            if let m = headerModel, var source = m.data_title {
                source.removeLast()
                tableName = source
                NSArray.bg_drop(source)
                MPModelTools.getRankingModel(rankType: source, tableName: source) { (models) in
                    if let m = models {
                        self.models = m
                    }
                }
            }
        }
    }
    
    var models = [MPSongModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func refreshData() {
        super.refreshData()
        if let m = headerModel, var source = m.data_title {
            source.removeLast()
            tableName = source
            NSArray.bg_drop(source)
            MPModelTools.getRankingModel(rankType: source, tableName: source) { (models) in
                if let m = models {
                    self.models = m
                }
            }
        }
        tableView.mj_header.endRefreshing()
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("专辑列表", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
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
        
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPAlbumListHeaderView.md_viewFromXIB() as! MPAlbumListHeaderView
        hv.updateView(model: self.headerModel!)
        tableView.tableHeaderView = hv
        
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
extension MPAlbumListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSongTableViewCell
        // 构造当前播放专辑列表模型
        let json: [String : Any] = ["id": 0, "title": headerModel?.data_title ?? "", "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": headerModel?.data_image ?? "pic_album_default", "tracksCount": models.count, "recentlyType": 6]
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
extension MPAlbumListViewController {
    private func randomPlay(index: Int = -1) {
        // 显示当前的播放View
        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
            var cs: MPSongModel?
            // 循序不能倒过来
            if index != -1 {
                cs = models[index]
            }else {
                cs = models.first
            }
            // 随机播放
            pv.currentPlayOrderMode = 1
            pv.currentSong = cs
            pv.model = models
            // 构造当前播放专辑列表模型
            let json: [String : Any] = ["id": 0, "title": headerModel?.data_title ?? "", "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": headerModel?.data_image ?? "pic_album_default", "tracksCount": models.count, "recentlyType": 6]
            //        let album = GeneralPlaylists(JSON: json)
            let album = Mapper<GeneralPlaylists>().map(JSON: json)
            pv.currentAlbum = album
            pv.bigStyle()
        }
    }
}
