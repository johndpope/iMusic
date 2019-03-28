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

class MPMyFavoriteViewController: BaseTableViewController {

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
        MPModelTools.getSongInTable(tableName: MPMyFavoriteViewController.classCode) { (model) in
            if let m = model {
                self.model = m
                self.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("我的最爱", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
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
        tableView.tableHeaderView = hv
    }
    
}
extension MPMyFavoriteViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSongTableViewCell
        cell.updateCell(model: model[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
