//
//  MPMediaLibraryViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/12.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let mediaLibraryIdentifier = "MPMediaLibraryOutTableViewCell"
    static let categoryIdentifier = "MPCategoryTableViewCell"
    static let sectionOneTitle = "最近播放"
    
    static let playerViewHeight = SCREEN_WIDTH * (48/375)
    static let smallPlayerHeight = SCREEN_WIDTH * (48/375)
}

class MPMediaLibraryViewController: BaseTableViewController {
    
    var model = [MPSongModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册一个通知来接收是否需要调整tableView的底部边距：小窗播放时需要调整
        NotificationCenter.default.addObserver(forName: NSNotification.Name(NotCenter.NC_ChangeTableViewBottom), object: nil, queue: nil) { (center) in
            QYTools.shared.Log(log: "调整底部边距通知")
            //            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constant.smallPlayerHeight, right: 0)
            self.tableView.snp.updateConstraints({ (make) in
                make.bottom.equalTo(self.view.safeArea.bottom).offset(-Constant.smallPlayerHeight)
            })
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(NotCenter.NC_RefreshRecentlyList), object: nil, queue: nil) { (center) in
            QYTools.shared.Log(log: "刷新数据")
            self.refreshData()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(NotCenter.NC_RefreshLocalModels), object: nil, queue: nil) { (center) in
            QYTools.shared.Log(log: "刷新数据")
            self.refreshData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func refreshData() {
        super.refreshData()
       
//        if let localModel = DiscoverCent?.data_CloudListUploadModel, let model = localModel.data_history {
//            self.model = model.reversed()
//        }else {
//            MPModelTools.getSongInTable(tableName: "RecentlyPlay") { (model) in
//                if let m = model {
//                    self.model = m.reversed()
//                }
//            }
//        }
        
        MPModelTools.getSongInTable(tableName: "RecentlyPlay") { (model) in
            if let m = model {
                self.model = m.reversed()
            }
        }
        
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.mediaLibraryIdentifier
        self.identifier = Constant.categoryIdentifier
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
    }
    
}
extension MPMediaLibraryViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number = 1
        if section == 1 {
            number = MPMediaLibraryModel.categoryDatas.count
        }
        return number
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        cell.selectionStyle = .none
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.mediaLibraryIdentifier)!
            (cell as! MPMediaLibraryOutTableViewCell).model = self.model
            (cell as! MPMediaLibraryOutTableViewCell).itemClickedBlock = {(index) in
                QYTools.shared.Log(log: "\(index)")
            }
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.categoryIdentifier)!
            (cell as! MPCategoryTableViewCell).updateCell(model: MPMediaLibraryModel.categoryDatas[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = SCREEN_WIDTH * (172/375)
        if indexPath.section == 0 {
            height = self.model.count == 0 ? 0 : SCREEN_WIDTH * (172/375)
        }else {
            height = SCREEN_WIDTH * (60/375)
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let shv = MPBaseSectionHeaderView.md_viewFromXIB() as! MPBaseSectionHeaderView
        var ft: MPBaseSectionHeaderViewType = .recommend
        if section == 0 {
            ft = .choiceness
            shv.fromType = ft
            shv.updateView(model: NSLocalizedString(Constant.sectionOneTitle, comment: ""))
        }
        shv.clickBlock = {(sender) in
            if let _ = sender as? UIButton {
                let vc = MPMyFavoriteViewController()
                vc.fromType = .Recently
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return shv
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 80
        }
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // 我的最爱
            let vc = MPMyFavoriteViewController()
            vc.fromType = .Favorite
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 1: // 我的下载
            let vc = MPMyFavoriteViewController()
            vc.fromType = .Download
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2: //离线歌曲
            let vc = MPMyFavoriteViewController()
            vc.fromType = .Cache
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 3: // 创建的歌单
            let vc = MPCreateSongListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 4: // 收藏的歌单
            let vc = MPCollectSongListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
    
}
