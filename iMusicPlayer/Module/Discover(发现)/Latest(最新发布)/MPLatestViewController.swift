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
        tableView.tableHeaderView = hv
        
        hv.sgmDidChangeBlock = {
            self.refreshData()
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
        let json: [String : Any] = ["data_id": 0, "data_title": NSLocalizedString("新歌首发", comment: ""), "data_description": "", "data_originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "data_type": "YouTube", "data_img": models.first?.data_artworkBigUrl ?? "pic_album_default", "data_tracksCount": models.count, "data_recentlyType": 2]
        let album = GeneralPlaylists(JSON: json)
        cell.updateCell(model: models[indexPath.row], models: self.models, album: album)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
