//
//  MPSearchViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import FirebaseAnalytics

private struct Constant {
    static let identifier = "MPSearchTableViewCell"
    static let tableName = "MPSearchViewController"
    static let rowHeight: CGFloat = SCREEN_WIDTH * (45/375)
    
    static let HeaderNotTagH: CGFloat =  17*2 + 13*3 + 32
}

class MPSearchViewController: BaseTableViewController {
    
    var itemClickedBlock: ((_ title: String) -> Void)?
    
    var searchingView: MPSearchingView?
    var searchResultView: MPSearchResultView?
    var searchResultTableView: UITableView?
    var searchView: MPSearchNavView?
    
    var headerView: MPSearchHeaderView?
    
    var duration: String = "any"  // 时长：any, short, medium, long
    var filter: String = ""  // 选择："", official, preview, 可多选： "official, preview"
    var order: String = "relevance"  // 排序：relevance, date, videoCount
    var sgmIndex: Int = 0
    
    var mp3Start = 0
    var nextPageTokenVideo: String = ""
    var nextPageTokenPlaylist: String = ""
    
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
                    hv.height = contentH + Constant.HeaderNotTagH
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
            self?.search(title: title)
        }
        
        super.viewDidLoad()
        
        refreshData()
    }
    
    override func refreshData() {
        super.refreshData()
//        NSArray.bg_drop(Constant.tableName)
        self.models = MPModelTools.getHistoryModels().reversed()
        
        MPModelTools.getSearchKeywordModel(tableName: MPSearchKeywordModel.classCode) { (models) in
            if let m = models {
                self.keywordModel = m
            }
        }
        // 用户发起一次搜索
        Analytics.logEvent("start_search", parameters: nil)
        
        MPModelTools.getSearchResult(q: self.keyword, duration: self.duration, filter: self.filter, order: self.order, tableName: "", finished: { (model) in
            self.searchResultTableView?.mj_header.endRefreshing()
            self.searchResultTableView?.mj_footer.resetNoMoreData()
            if let m = model {
                Analytics.logEvent("search_sucess", parameters: nil)
                self.searchResultView?.model = m
                self.nextPageTokenVideo = m.data_nextPageTokenVideo ?? ""
                self.nextPageTokenPlaylist = m.data_nextPageTokenPlaylist ?? ""
            }else {
                Analytics.logEvent("search_failed", parameters: nil)
                
                if SourceType == 1 {
                    Analytics.logEvent("search_failed_mp3", parameters: nil)
                }else {
                    Analytics.logEvent("search_failed_yt", parameters: nil)
                }
                
            }
        })
    }
    
    override func pageTurning() {
        super.pageTurning()
        
        if SourceType == 1 {
            if sgmIndex == 0 {
                pageTurningSong()
            }else if sgmIndex == 1 {
                pageTurningMv()
            }else if sgmIndex == 2 {
                pageTurningList()
            }
        }else {
            if sgmIndex == 0 {
                pageTurningMv()
            }else if sgmIndex == 1 {
                pageTurningList()
            }
        }
        
    }
    
    private func pageTurningSong() {
        mp3Start += 20
        DiscoverCent?.requestSearchMp3(q: self.keyword, duration: duration, filter: filter, order: order, size: 20, page: mp3Start, complete: { (isSucceed, model, msg) in
            self.searchResultTableView?.mj_footer.endRefreshing()
            switch isSucceed {
            case true:
                if let m = model?.data_songs, m.count > 0 {
                    QYTools.shared.Log(log: "获取到下一页数据")
                    if let oms = self.searchResultView?.model?.data_songs {
                        let temps = oms + m
                        let tempM = self.searchResultView?.model
                        tempM?.data_songs = temps
                        self.searchResultView?.model = tempM
                    }
                }else {
                    self.searchResultTableView?.mj_footer.endRefreshingWithNoMoreData()
                    self.mp3Start -= 20
                }
                break
            case false:
                SVProgressHUD.showError(withStatus: msg)
                self.mp3Start -= 20
                break
            }
        })
    }
    
    private func pageTurningMv() {
        if nextPageTokenVideo == "" {
            self.searchResultTableView?.mj_footer.endRefreshingWithNoMoreData()
            return
        }
        DiscoverCent?.requestSearchMV(q: self.keyword, duration: duration, filter: filter, order: order, size: 20, pageToken: nextPageTokenVideo, complete: { (isSucceed, model, msg) in
            self.searchResultTableView?.mj_footer.endRefreshing()
            switch isSucceed {
            case true:
                if let m = model?.data_videos, m.count > 0 {
                    QYTools.shared.Log(log: "获取到下一页数据")
                    if let oms = self.searchResultView?.model?.data_videos {
                        self.nextPageTokenVideo = model?.data_nextPageTokenVideo ?? ""
                        let temps = oms + m
                        let tempM = self.searchResultView?.model
                        tempM?.data_videos = temps
                        self.searchResultView?.model = tempM
                    }
                }else {
                    self.searchResultTableView?.mj_footer.endRefreshingWithNoMoreData()
                }
                break
            case false:
                SVProgressHUD.showError(withStatus: msg)
                break
            }
        })
    }
    
    private func pageTurningList() {
        if nextPageTokenPlaylist == "" {
            self.searchResultTableView?.mj_footer.endRefreshingWithNoMoreData()
            return
        }
        DiscoverCent?.requestSearchList(q: self.keyword, duration: duration, filter: filter, order: order, size: 20, pageToken: nextPageTokenPlaylist, complete: { (isSucceed, model, msg) in
            self.searchResultTableView?.mj_footer.endRefreshing()
            switch isSucceed {
            case true:
                if let m = model?.data_playlists, m.count > 0 {
                    QYTools.shared.Log(log: "获取到下一页数据")
                    if let oms = self.searchResultView?.model?.data_playlists {
                        self.nextPageTokenPlaylist = model?.data_nextPageTokenPlaylist ?? ""
                        let temps = oms + m
                        let tempM = self.searchResultView?.model
                        tempM?.data_playlists = temps
                        self.searchResultView?.model = tempM
                    }
                }else {
                    self.searchResultTableView?.mj_footer.endRefreshingWithNoMoreData()
                }
                break
            case false:
                SVProgressHUD.showError(withStatus: msg)
                break
            }
        })
    }
    
    override func setupStyle() {
        super.setupStyle()
       
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.identifier
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPSearchHeaderView.md_viewFromXIB() as! MPSearchHeaderView
        headerView = hv
        tableView.tableHeaderView = hv
        let temps = ["AKB48", "三浦大知", "星野源", "西野カナ", "中島愛", "米津玄师", "Winds" , "星野源", "杨超越", "星野源", "西野カナ", "中島愛", "米津玄师", "Winds" , "星野源", "杨超越"]
        hv.updateTags(tags: temps) { (tagv) in
            let contentH = tagv.intrinsicContentSize.height
            hv.height = contentH + Constant.HeaderNotTagH
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
        cell.clickBlock = {(sender) in
            if let _ = sender as? UIButton { // 删除当前本地模型并刷新
                // 更新本地模型
                MPModelTools.deleteHistoryModel(model: self.models[indexPath.row])
                self.refreshData()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 获取当前数据源的标题
        let text = models[indexPath.row]
        if let b = itemClickedBlock {
            b(text)
        }
    }
}
extension MPSearchViewController: MPSearchNavViewDelegate {
    
    /// 键盘点击搜索
    ///
    /// - Parameter text: 搜索关键词
    func keyboardSearch(_ text: String) {
        self.search(title: text)
    }
    
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
    
    private func search(title: String) {
        if title != "" {
            // 添加到历史搜索
            if models.contains(title) {
                let marr = NSMutableArray(array: models)
                marr.remove(title)
                marr.add(title)
                MPModelTools.saveHistoryModel(model: marr as! [String])
                self.refreshData()
            }else {
                models.append(title)
                MPModelTools.saveHistoryModel(model: models)
                self.refreshData()
            }
            // 数据回填
            self.searchView?.setupData(model: title)
            if self.searchResultView != nil {
                // 替换数据源
                self.searchResultView?.isHidden = false
                self.searchingView?.isHidden = true
                QYTools.shared.Log(log: "替换数据源~")
                
                //                    MPModelTools.getRelatedKeyword(q: title, finished: { (model) in
                //                        self?.searchingView?.model = model
                //                    })
                
                // 获取搜索结果数据
                self.keyword = title
            }else {
                QYTools.shared.Log(log: "新增结果数据View~")
                // 新增结果列表
                let rv = MPSearchResultView()
                self.searchResultView = rv
                self.searchResultTableView = rv.tableView
                rv.delegate = self
                self.view.addSubview(rv)
                rv.snp.makeConstraints { (make) in
                    make.left.right.top.bottom.equalToSuperview()
                }
                // 设置筛选条件的代理
                self.searchResultView?.itemClickedBlock = {(duration, filter, order, sgmIndex) in
                    self.duration = duration
                    self.filter = filter
                    self.order = order
                    self.sgmIndex = sgmIndex
                    // 判断是否需要时长和选择
                    if SourceType == 1 {
                        if sgmIndex == 2 {
                            self.duration = "any"
                            self.filter = ""
                        }
                    }else {
                        if sgmIndex == 1 {
                            self.duration = "any"
                            self.filter = ""
                        }
                    }
                    
                    self.refreshData()
                }
                // 获取搜索结果数据
                self.keyword = title
            }
        }else {
            self.searchResultView?.isHidden = true
        }
    }
    
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
// MARK: - 刷新搜索结果View
extension MPSearchViewController: MPSearchResultViewDelegate {
    func refreshData(_ searchResultView: MPSearchResultView) {
        self.refreshData()
    }
    
    func pageTurning(_ searchResultView: MPSearchResultView) {
        self.pageTurning()
    }
}
