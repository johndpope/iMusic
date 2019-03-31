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

class MPSongListViewController: BaseTableViewController {
    
    var headerSongModel: GeneralPlaylists? {
        didSet {
            playlistId = headerSongModel?.data_id ?? 0
            singerId = headerSongModel?.data_originalId ?? ""
        }
    }
    
    var playlistId: Int = 0
    var singerId  = ""
    
    /// 1: 歌单 2：歌手
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
                        self.tableView.mj_header.endRefreshing()
                    }
                }
            }else if type == 2 {
                MPModelTools.getSongerListByIDModel(singerId: singerId, tableName: "") { (model) in
                    if let m = model {
                        self.model = m
                        self.tableView.mj_header.endRefreshing()
                    }
                }
            }
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("歌单列表", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
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
        
        let hv = MPSongListHeaderView.md_viewFromXIB() as! MPSongListHeaderView
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
                    QYTools.shared.Log(log: "随机播放")
                }else {
                    QYTools.shared.Log(log: "收藏歌单")
                    let isExsist = MPModelTools.checkCollectListExsist(model: self.headerSongModel!, tableName: MPCollectSongListViewController.classCode)
                    if !isExsist {
                        btn.isSelected = true
                        MPModelTools.saveCollectListModel(model: self.headerSongModel!, tableName: MPCollectSongListViewController.classCode)
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
        cell.updateCell(model: model[indexPath.row], models: self.model, album: self.headerSongModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
}

