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
    
    var noDataView: MPNoDataView!
    
    var page: Int = 0
    
    var songName: String = "" {
        didSet {
            self.refreshData()
        }
    }
    
    var model = [GeneralPlaylists]() {
        didSet {
            tableView.reloadData()
            
            if model.count == 0 {
                noDataView.isHidden = false
                tableView.mj_footer.isHidden = true
            }else {
                noDataView.isHidden = true
                tableView.mj_footer.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
    }
    
    override func refreshData() {
        super.refreshData()
        self.page = 0
        if let hv = self.headerView {
            DiscoverCent?.requestPopular(nationality: hv.nationality, type: hv.type, name: songName, page: self.page, row: 20, complete: { (isSucceed, model, msg) in
                self.tableView.mj_header.endRefreshing()
                switch isSucceed {
                case true:
                    if let m = model, m.count > 0 {
                        self.model = m
                        self.tableView.mj_header.endRefreshing()
                        self.tableView.mj_footer.resetNoMoreData()
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
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
                        QYTools.shared.Log(log: "获取到下一页数据".decryptLog())
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
        
        addLeftItem(title: NSLocalizedString("人气歌手", comment: "").decryptString(), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
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
        
        setupNoDataView(image: "pic_no_resault", text: NSLocalizedString("找不到歌曲", comment: "").decryptString())
    }
    
    private func setupNoDataView(image: String, text: String) {
        // 添加无数据提示View
        let sv = MPNoDataView.md_viewFromXIB() as! MPNoDataView
        let x: CGFloat = 20
        let width = (tableView.width - 40)
        let height = SCREEN_WIDTH * (180/375)
        let hvH = tableView.tableHeaderView?.height ?? 0
        let y = (SCREEN_HEIGHT-NavBarHeight-TabBarHeight - height - hvH)*1/2
        sv.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
        sv.updateView(image: image, text: text)
        sv.isHidden = true
        noDataView = sv
        tableView.addSubview(sv)
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
