//
//  MPRankingViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import ObjectMapper

private struct Constant {
    static let identifier = "MPCollectSongListTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (90/375)
}

class MPCreateSongListViewController: BaseTableViewController {
    
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
        NSArray.bg_delete(MPCreateSongListViewController.classCode, row: 1)
        MPModelTools.getCollectListModel(tableName: MPCreateSongListViewController.classCode) { (model) in
            if let m = model {
                self.model = m
                self.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("我创建的歌单", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
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
        let hv = MPCreateSongListHeaderView.md_viewFromXIB() as! MPCreateSongListHeaderView
        hv.clickBlock = {(sender) in
            if let _ = sender as? UIButton {
                let pv = MPCreateSongListView.md_viewFromXIB() as! MPCreateSongListView
                HFAlertController.showCustomView(view: pv)
                pv.clickBlock = {(sender) in
                    if let btn = sender as? UIButton {
                        if btn.tag == 10001 {
                            // 取消
                            pv.removeFromWindow()
                        }else {
                            if MPModelTools.createSongList(songListName: pv.xib_songListName.text ?? "") {
                                self.refreshData()
                            }else {
                                SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌单已存在", comment: ""))
                            }
                            pv.removeFromWindow()
                        }
                    }
                }
            }
        }
        tableView.tableHeaderView = hv
    }
    
}
extension MPCreateSongListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPCollectSongListTableViewCell
        cell.selectionStyle = .none
        cell.updateCell(model: model[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MPEditSongListViewController()
        vc.songListModel = model[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
