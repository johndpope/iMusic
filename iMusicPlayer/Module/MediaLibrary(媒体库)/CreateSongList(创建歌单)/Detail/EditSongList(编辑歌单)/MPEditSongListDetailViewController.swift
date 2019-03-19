//
//  MPEditSongListDetailViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPEditSongListDetailTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
}

class MPEditSongListDetailViewController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        view.sendSubviewToBack(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.bottom.equalTo(self.view.safeArea.bottom).offset(-(SCREEN_WIDTH*(53/375)))
        }
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.identifier
        tableView.backgroundColor = UIColor.white
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        tableView.mj_header = nil
        tableView.mj_footer = nil

        // 隐藏返回按钮
        self.hiddenLeftButton = true
        
        let hv = MPEditSongListDetailHeaderView.md_viewFromXIB() as! MPEditSongListDetailHeaderView
        self.navigationItem.titleView = hv
    }
    
}
extension MPEditSongListDetailViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPEditSongListDetailTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
