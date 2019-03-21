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
    
    var itemClickedBlock: ((_ title: String) -> Void)?
    
    var searchingView: MPSearchingView?
    var searchResultView: MPSearchResultView?
    var searchView: MPSearchNavView?

    override func viewDidLoad() {
        // view创建时间冲突：手动调用
        let nav = MPSearchNavView.md_viewFromXIB() as! MPSearchNavView
        searchView = nav
        nav.delegate = self
        self.navigationItem.titleView = nav
        
        self.itemClickedBlock = {[weak self](title) in
            
            if title != "" {
                // 数据回填
                self?.searchView?.setupData(model: title)
                
                if self?.searchResultView != nil {
                    // 替换数据源
                    self?.searchResultView?.isHidden = false
                    QYTools.shared.Log(log: "替换数据源~")
                }else {
                    QYTools.shared.Log(log: "新增结果数据View~")
                    // 新增结果列表
                    let rv = MPSearchResultView()
                    self?.searchResultView = rv
                    self?.view.addSubview(rv)
                    rv.snp.makeConstraints { (make) in
                        make.left.right.top.bottom.equalToSuperview()
                    }
                }
            }else {
                self?.searchResultView?.isHidden = true
            }
            
        }
        super.viewDidLoad()
    }
    
    override func setupStyle() {
        super.setupStyle()
       
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
    
        hv.itemClickedBlock = self.itemClickedBlock
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 获取当前数据源的标题
        let text = ""
        if let b = itemClickedBlock {
            b(text)
        }
    }
}
extension MPSearchViewController: MPSearchNavViewDelegate {
    func beginSearch(_ text: String) {
        if text != "" {
            if searchingView != nil {
                // 替换数据源
                searchingView?.isHidden = false
                QYTools.shared.Log(log: "替换数据源~")
            }else {
                QYTools.shared.Log(log: "新增关联数据View~")
                // 新增一个列表
                let relatev = MPSearchingView()
                searchingView = relatev
                self.view.addSubview(relatev)
                relatev.snp.makeConstraints { (make) in
                    make.left.right.top.bottom.equalToSuperview()
                }
                
                searchingView?.itemClickedBlock = self.itemClickedBlock
                
            }
            
        }else {
            searchingView?.isHidden = true
            searchResultView?.isHidden = true
        }
       
    }
}
