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
                    self.model = m
                    self.tableView.mj_header.endRefreshing()
                }
            }
            break
        case .Favorite:
            MPModelTools.getSongInTable(tableName: MPMyFavoriteViewController.classCode) { (model) in
                if let m = model {
                    self.model = m
                    self.tableView.mj_header.endRefreshing()
                    
                    self.headerView?.count = model?.count ?? 0
                }
            }
            break
        case .Download:
            title = NSLocalizedString("我的下载", comment: "")
            break
        case .Cache:
            title = NSLocalizedString("离线歌曲", comment: "")
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
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPMyFavoriteHeaderView.md_viewFromXIB() as! MPMyFavoriteHeaderView
        headerView = hv
        tableView.tableHeaderView = hv
    }
    
}
extension MPMyFavoriteViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSongTableViewCell
        cell.updateCell(model: model[indexPath.row], models: self.model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
