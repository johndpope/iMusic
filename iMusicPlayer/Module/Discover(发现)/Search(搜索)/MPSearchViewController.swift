//
//  MPSearchViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPSearchTableViewCell"
    static let rowHeight: CGFloat = SCREEN_WIDTH * (45/375)
}

class MPSearchViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupStyle() {
        super.setupStyle()
        let nav = MPSearchNavView.md_viewFromXIB() as! MPSearchNavView
        self.navigationItem.titleView = nav
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.identifier
        
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPSearchHeaderView.md_viewFromXIB() as! MPSearchHeaderView
        tableView.tableHeaderView = hv
        let temps = ["AKB48", "三浦大知", "星野源", "西野カナ", "中島愛", "米津玄师", "Winds" , "星野源", "杨超越", "星野源", "西野カナ", "中島愛", "米津玄师", "Winds" , "星野源", "杨超越"]
        hv.updateTags(tags: temps) { (tagv) in
            let contentH = tagv.intrinsicContentSize.height
            hv.height = contentH + 17*2 + 13*4
            self.tableView.reloadData()
        }
    }
    
}
extension MPSearchViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MPSearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSearchTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
