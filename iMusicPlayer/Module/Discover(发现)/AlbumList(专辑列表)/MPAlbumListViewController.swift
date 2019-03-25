//
//  MPLatestViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPAlbumListTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
}

class MPAlbumListViewController: BaseTableViewController {

    var headerModel: MPRankingTempModel? {
        didSet {
            if let m = headerModel, var source = m.data_title {
                source.removeLast()
                MPRankingModel.getModel(rankType: source, tableName: source) { (models) in
                    if let m = models {
                        self.models = m
                    }
                }
            }
        }
    }
    
    var models = [MPRankingModel]() {
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
            MPRankingModel.getModel(rankType: source, tableName: source) { (models) in
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
    }
    
}
extension MPAlbumListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MPAlbumListTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPAlbumListTableViewCell
        cell.updateCell(model: models[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
