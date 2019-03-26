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
    
    var headerSongerModel: HotSingerPlaylists? {
        didSet {
            singerId = headerSongerModel?.data_originalId ?? ""
        }
    }
    
    var headerSongModel: GeneralPlaylists? {
        didSet {
            playlistId = headerSongModel?.data_id ?? 0
        }
    }
    
    var playlistId: Int = 0
    var singerId: String = ""

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
        if let hm = self.headerSongModel {
            MPModelTools.getSongListByIDModel(playlistId: playlistId, tableName: "") { (model) in
                if let m = model {
                    self.model = m
                    self.tableView.mj_header.endRefreshing()
                }
            }
        }else {
            MPModelTools.getSongerListByIDModel(singerId: singerId, tableName: "") { (model) in
                if let m = model {
                    self.model = m
                    self.tableView.mj_header.endRefreshing()
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
        }else {
            hv.updateView(model: self.headerSongerModel!)
        }
        tableView.tableHeaderView = hv
    }
    
}
extension MPSongListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSongTableViewCell
        
        cell.updateCell(model: model[indexPath.row])
        
        cell.md_btnDidClickedBlock = {[weak self] (sender) in
            switch sender.tag {
            case 10001:
                break
            case 10002:
                let pv = MPSongToolsView.md_viewFromXIB() as! MPSongToolsView
                pv.plistName = "songTools"
                pv.delegate = self
                HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
                break
            default:
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
}

extension MPSongListViewController: MPSongToolsViewDelegate {
    func addToSongList() {
        let pv = MPAddToSongListView.md_viewFromXIB() as! MPAddToSongListView
        // 新建歌单
        pv.createSongListBlock = {
            let pv = MPCreateSongListView.md_viewFromXIB(cornerRadius: 4) as! MPCreateSongListView
            pv.md_btnDidClickedBlock = {(sender) in
                if sender.tag == 10001 {
                    if let sv = pv.superview {
                        sv.removeFromSuperview()
                    }
                }else {
                    // 新建歌单操作
                    SVProgressHUD.showInfo(withStatus: "正在新建歌单~")
                    if let sv = pv.superview {
                        sv.removeFromSuperview()
                    }
                }
            }
            HFAlertController.showCustomView(view: pv)
        }
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
    }
    
    func nextPlay() {
        
    }
    
    func addToPlayList() {
        
    }
    
    
}
