//
//  MPLatestViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPLatestTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
}

class MPLatestViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("最新歌曲", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
    }
    
    override func clickLeft() {
        super.clickLeft()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.identifier
        
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPLatestHeaderView.md_viewFromXIB() as! MPLatestHeaderView
        tableView.tableHeaderView = hv
    }
    
}
extension MPLatestViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MPLatestTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPLatestTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
