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
    static let tableName = "MPSearchViewController"
    static let rowHeight: CGFloat = SCREEN_WIDTH * (45/375)
}

class MPSearchViewController: BaseTableViewController {
    
    var itemClickedBlock: ((_ title: String) -> Void)?
    
    var searchingView: MPSearchingView?
    var searchResultView: MPSearchResultView?
    var searchView: MPSearchNavView?
    
    var headerView: MPSearchHeaderView?
    
    var duration: String = "any"  // 时长：any, short, medium, long
    var filter: String = ""  // 选择："", official, preview, 可多选： "official, preview"
    var order: String = "relevance"  // 排序：relevance, date, videoCount
    
    var keyword: String = "" {
        didSet {
            self.refreshData()
        }
    }

    var keywordModel = [MPSearchKeywordModel]() {
        didSet {
            if let hv = self.headerView {
                let temps = getSearchKeys(models: keywordModel)
                hv.updateTags(tags: temps) { (tagv) in
                    let contentH = tagv.intrinsicContentSize.height
                    hv.height = contentH + 17*2 + 13*4
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    var models = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 获取数据
        
    }
    
    override func viewDidLoad() {
        // view创建时间冲突：手动调用
        let nav = MPSearchNavView.md_viewFromXIB() as! MPSearchNavView
        searchView = nav
        nav.delegate = self
        self.navigationItem.titleView = nav
        
        self.itemClickedBlock = {[weak self](title) in
            
            if title != "" {
                
                // 添加到历史搜索
                if !(self?.models.contains(title))! {
                    self?.models.append(title)
                    self?.tableView.reloadData()
                    // 保存到数据库
                    (self?.models as! NSArray).bg_save(withName: Constant.tableName)
                }
                
                // 数据回填
                self?.searchView?.setupData(model: title)
                
                if self?.searchResultView != nil {
                    // 替换数据源
                    self?.searchResultView?.isHidden = false
                    self?.searchingView?.isHidden = true
                    QYTools.shared.Log(log: "替换数据源~")
                    
//                    MPModelTools.getRelatedKeyword(q: title, finished: { (model) in
//                        self?.searchingView?.model = model
//                    })
                    
                    // 获取搜索结果数据
                    self?.keyword = title
                    
                }else {
                    QYTools.shared.Log(log: "新增结果数据View~")
                    // 新增结果列表
                    let rv = MPSearchResultView()
                    self?.searchResultView = rv
                    self?.view.addSubview(rv)
                    rv.snp.makeConstraints { (make) in
                        make.left.right.top.bottom.equalToSuperview()
                    }
                    
                    // 设置筛选条件的代理
                    self?.searchResultView?.itemClickedBlock = {(duration, filter, order, sgmIndex) in
                         self?.duration = duration
                         self?.filter = filter
                         self?.order = order
                        
                        // 判断是否需要时长和选择
                        if sgmIndex == 2 {
                            self?.duration = "any"
                            self?.filter = ""
                        }
                         self?.refreshData()
                    }
                    
                    // 获取搜索结果数据
                    self?.keyword = title
                    
                }
            }else {
                self?.searchResultView?.isHidden = true
            }
            
        }
        
        super.viewDidLoad()
        
        refreshData()
    }
    
    override func refreshData() {
        super.refreshData()
        
        if let arr = NSArray.bg_array(withName: Constant.tableName) as? [String] {
            self.models = arr
        }
        
        MPModelTools.getSearchKeywordModel(tableName: MPSearchKeywordModel.classCode) { (models) in
            if let m = models {
                self.keywordModel = m
                self.tableView.mj_header.endRefreshing()
            }
        }
        
        MPModelTools.getSearchResult(q: self.keyword, duration: self.duration, filter: self.filter, order: self.order, tableName: "", finished: { (model) in
            if let m = model {
                self.searchResultView?.model = m
            }
        })
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
        headerView = hv
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
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MPSearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSearchTableViewCell
        cell.xib_title.text = models[indexPath.row]
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
                searchResultView?.isHidden = true
                searchingView?.isHidden = false
                QYTools.shared.Log(log: "替换数据源~")
                MPModelTools.getRelatedKeyword(q: text, finished: { (model) in
                    self.searchingView?.model = model
                })
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
extension MPSearchViewController {
    
    /// 获取搜索关键字
    ///
    /// - Parameter models: 模型数组
    /// - Returns: 关键字数组
    private func getSearchKeys(models: [MPSearchKeywordModel]) -> [String] {
        var keys = [String]()
        models.forEach { (model) in
            keys.append(model.data_keyword ?? "")
        }
        return keys
    }
}


