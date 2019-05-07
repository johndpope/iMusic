//
//  MPRankingViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPPopularTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (76/375)
    static let headerHeight = SCREEN_WIDTH * (120/375)
}

class MPPopularViewController: BaseTableViewController {
    
    var headerView: MPPopularHeaderView?
    
    var page: Int = 0
    
    var songName: String = "" {
        didSet {
            self.refreshData()
        }
    }
    
    var model = [GeneralPlaylists]() {
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
        
        if let hv = self.headerView {
            let tableName = songName + "\(hv.nationality)" + "\(hv.type)"
            MPModelTools.getPopularModel(songerName: songName, nationality: hv.nationality, type: hv.type, tableName: "") { (models) in
                if let m = models {
                    self.model = m
                    self.tableView.mj_header.endRefreshing()
                    self.tableView.mj_footer.resetNoMoreData()
                }
            }
        }
        
    }
    
    override func pageTurning() {
        super.pageTurning()
        self.page += 20
        if let hv = self.headerView {
            DiscoverCent?.requestPopular(nationality: hv.nationality, type: hv.type, name: songName, page: self.page, row: 20, complete: { (isSucceed, model, msg) in
                self.tableView.mj_footer.endRefreshing()
                switch isSucceed {
                case true:
                    if let m = model, m.count > 0 {
                        QYTools.shared.Log(log: "获取到下一页数据")
                        self.model += m
                    }else {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self.page -= 20
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    self.page -= 20
                    break
                }
            })
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("人气歌手", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
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
        
        let hv = MPPopularHeaderView.md_viewFromXIB() as! MPPopularHeaderView
        hv.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: Constant.headerHeight))
        headerView = hv
        tableView.tableHeaderView = hv
        hv.sgmDidChangeBlock = {(name) in
            self.songName = name
        }
    }
    
}
extension MPPopularViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MPPopularTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPPopularTableViewCell
        cell.updateCell(model: model[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MPSongListViewController()
        vc.headerSongModel = model[indexPath.row]
        vc.type = 2
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
