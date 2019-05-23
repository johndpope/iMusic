//
//  MPRankingViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPChoicenessTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (117/375)
    static let sectionHeight = SCREEN_WIDTH * (8/375)
}

class MPChoicenessViewController: BaseTableViewController {
    
    var typeID: Int = 0
    
    var leftTitle = ""
    
    var start = 0
    
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
        
        MPModelTools.getSongListModel(typeID: typeID, tableName: "") { (model) in
            if let m = model {
                self.model = m
                self.start = 0
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.resetNoMoreData()
            }
        }
        
    }
    
    override func pageTurning() {
        super.pageTurning()
        start += 20
        DiscoverCent?.requestSongList(type: typeID, rows: 20, start: start, complete: { (isSucceed, model, msg) in
           self.tableView.mj_footer.endRefreshing()
            switch isSucceed {
            case true:
                if let m = model, m.count > 0 {
                    QYTools.shared.Log(log: "获取到下一页数据".decryptLog())
                    self.model += m
                }else {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    self.start -= 20
                }
                break
            case false:
                SVProgressHUD.showError(withStatus: msg)
                self.start -= 20
                break
            }
        })
        
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        var title = NSLocalizedString("歌单精选", comment: "").decryptString()
        if leftTitle != "" {
            title = NSLocalizedString(leftTitle, comment: "")
        }
        addLeftItem(title: title, imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
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
        tableView.backgroundColor = UIColor.white
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: Constant.sectionHeight)))
    }
    
}
extension MPChoicenessViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPChoicenessTableViewCell
        cell.updateCell(model: model[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MPSongListViewController()
        vc.headerSongModel = model[indexPath.row]
        vc.type = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
