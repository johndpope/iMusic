//
//  MPRankingViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPCreateSongListTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (75/375)
}

class MPCreateSongListViewController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
        hv.md_btnDidClickedBlock = {(sender) in
            let pv = MPCreateSongListView.md_viewFromXIB() as! MPCreateSongListView
            HFAlertController.showCustomView(view: pv)
        }
        tableView.tableHeaderView = hv
    }
    
}
extension MPCreateSongListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPCreateSongListTableViewCell
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
