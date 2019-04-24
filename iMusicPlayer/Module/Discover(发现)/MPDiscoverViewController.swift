//
//  MPDiscoverViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/12.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import ObjectMapper

private struct Constant {
    static let discoverIdentifier = "MPDiscoverTableViewCell"
    static let categoryIdentifier = "MPCategoryTableViewCell"
    static let recommendIdentifier = "MPRecommendTableViewCell"
    static let recentlyIdentifier = "MPRecentlyTableViewCell"
    
    static let playerViewHeight = SCREEN_WIDTH * (48/375)
    static let smallPlayerHeight = SCREEN_WIDTH * (48/375)
}

class MPDiscoverViewController: BaseTableViewController {

    var model: MPDiscoverModel? {
        didSet {
            if let m = model {
                tableView.reloadData()
            }
        }
    }
    
    var currentAlbum = [GeneralPlaylists]() {
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.recommendIdentifier
        self.identifier = Constant.recentlyIdentifier
        self.identifier = Constant.discoverIdentifier
        self.identifier = Constant.categoryIdentifier
    
        tableView.mj_footer = nil
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         refreshData()
        
    }

    override func refreshData() {
        super.refreshData()
        // 刷新数据
//        NSArray.bg_drop("RecentlyAlbum")
        // 获取最近播放数据
        MPModelTools.getCollectListModel(tableName: "RecentlyAlbum") { (models) in
            if let m = models {
                // 倒序显示最新的在前面
                self.currentAlbum = m.reversed()
            }
        }
        
//        MPDiscoverModel.bg_drop(MPDiscoverModel.classCode)
        MPModelTools.getDiscoverModel { (model) in
            self.model = model
            self.tableView.mj_header.endRefreshing()
        }
    }
    
}
extension MPDiscoverViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number = 5
        switch section {
        case 0:
            number = 1
            break
        case 1:
             number = 1
            break
        case 2:
             number = MPDiscoverModel.categoryDatas.count
            break
        case 3:
            if let count = model?.data_generalPlaylists?.count {
                number = count
            }
            break
        default:
            break
        }
        return number
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.recommendIdentifier)!
            if let cellModel = model?.data_recommendations {
                (cell as! MPRecommendTableViewCell).models = cellModel
            }
            (cell as! MPRecommendTableViewCell).itemClickedBlock = {[weak self] (index) in
//                let vc = MPPlayingViewController()
//                if let m = self?.model?.data_recommendations  {
//                    // 循序不能倒过来
//                    vc.currentSong = m[index]
//                    vc.model = m
//                }
//                let nav = UINavigationController(rootViewController: vc)
//                self?.present(nav, animated: true, completion: nil)
                
                // 显示当前的播放View
                if let m = self?.model?.data_recommendations  {
                    self?.play(index: index, model: m)
                }
                
            }
            break
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.recentlyIdentifier)!
            (cell as! MPRecentlyTableViewCell).model = self.currentAlbum
            
            (cell as! MPRecentlyTableViewCell).playClickedBlock = {[weak self] (index) in
                // 播放什么？？
            }
            
            (cell as! MPRecentlyTableViewCell).itemClickedBlock = {[weak self] (index) in
                
                if let album = self?.currentAlbum[index].data_recentlyType {
                    switch album {
                    case 1: // 最近播放
                        let vc = MPMyFavoriteViewController()
                        vc.fromType = .Recently
                        self?.navigationController?.pushViewController(vc, animated: true)
                        break
                    case 2: // 最新发布
                        let vc = MPLatestViewController()
                        self?.navigationController?.pushViewController(vc, animated: true)
                        break
                    case 3: // 我的最爱
                        let vc = MPMyFavoriteViewController()
                        vc.fromType = .Favorite
                        self?.navigationController?.pushViewController(vc, animated: true)
                        break
                    case 4: // 歌手
                        let vc = MPSongListViewController()
                        vc.headerSongModel = self?.currentAlbum[index]
                        // 判断是歌手还是歌单
                        vc.type = 2
                        self?.navigationController?.pushViewController(vc, animated: true)
                        break
                    case 5: // 歌单
                        let vc = MPSongListViewController()
                        vc.headerSongModel = self?.currentAlbum[index]
                        // 判断是歌手还是歌单
                        vc.type = 1
                        self?.navigationController?.pushViewController(vc, animated: true)
                        break
                    case 6: // 排行榜
                        let vc = MPRankingViewController()
                        vc.tempModels = self?.model?.data_charts
                        self?.navigationController?.pushViewController(vc, animated: true)
                        break
                    case 7: // Top 100
                        if let m = self?.model?.data_recommendations {
                            self?.play(model: m)
                        }
                        break
                    case 8: // 自己创建的歌单
                        let vc = MPEditSongListViewController()
                        vc.songListModel = self?.currentAlbum[index]
                        self?.navigationController?.pushViewController(vc, animated: true)
                        break
                    default:
                        break
                    }
                }
            }
            break
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.categoryIdentifier)!
            (cell as! MPCategoryTableViewCell).updateCell(model: MPDiscoverModel.categoryDatas[indexPath.row])
            break
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.discoverIdentifier)!
            if let models = model?.data_generalPlaylists {
                (cell as! MPDiscoverTableViewCell).updateCell(model: models[indexPath.row])
                (cell as! MPDiscoverTableViewCell).clickBlock = {(sender) in
                    if let btn = sender as? UIButton {
                        MPModelTools.getSongListByIDModel(playlistId: models[indexPath.row].data_id, tableName: "") { (model) in
                            if let m = model {
                                self.play(model: m)
                            }
                        }
                    }
                }
            }
            break
        default:
            break
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = SCREEN_WIDTH * (117/375)
        switch indexPath.section {
        case 0:
            height = SCREEN_WIDTH * (260/375)
            break
        case 1:
            height = self.currentAlbum.count == 0 ? 0 : SCREEN_WIDTH * (220/375)
            break
        case 2:
            height = SCREEN_WIDTH * (60/375)
            break
        case 3:
            height = SCREEN_WIDTH * (117/375)
            break
        default:
            break
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let shv = MPBaseSectionHeaderView.md_viewFromXIB() as! MPBaseSectionHeaderView
        var ft: MPBaseSectionHeaderViewType = .recommend
        if section == 1 {
            ft = .recently
        }else if section == 3 {
            ft = .choiceness
        }
        shv.fromType = ft
        
        shv.clickBlock = {(sender) in
            if let _ = sender as? UIButton {
                let vc = MPChoicenessViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        return shv
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 0.001
        }
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         // 每日推荐点击
        if indexPath.section == 0 {
            
        }
        // 最近播放点击
       else if indexPath.section == 1 {
            
        }
        // 分类列表点击
        else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let vc = MPLatestViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case 1:
                let vc = MPRankingViewController()
                vc.tempModels = model?.data_charts
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case 2:
                let vc = MPPopularViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case 3:
                let vc = MPStyleGenreViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            default:
                break
            }
        }
         // 精选歌单点击
        else if indexPath.section == 3 {
            if let models = model?.data_generalPlaylists {
                let vc = MPSongListViewController()
                vc.headerSongModel = models[indexPath.row]
                vc.type = 1
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
// MARK: - 获取数据
extension MPDiscoverViewController {
    private func play(index: Int = -1, model: [MPSongModel]) {
        // 显示当前的播放View
//        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
//            var cs: MPSongModel?
//            // 循序不能倒过来
//            if index != -1 {
//                cs = model[index]
//                // 构造当前播放专辑列表模型
//                let tempImg = cs?.data_artworkBigUrl ?? ""
//                let img = (tempImg == "" ? (cs?.data_artworkUrl ?? "") : tempImg) == "" ? "pic_album_default" : (tempImg == "" ? (cs?.data_artworkUrl ?? "") : tempImg)
//                let json: [String : Any] = ["id": 0, "title": "Top 100", "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": img, "tracksCount": model.count, "recentlyType": 7]
//                //                let album = GeneralPlaylists(JSON: json)
//                let album = Mapper<GeneralPlaylists>().map(JSON: json)
//                pv.currentAlbum = album
//            }else {
//                cs = model.first
//            }
//            pv.currentSong = cs
//            pv.model = model
//
//            pv.bigStyle()
//        }
        
        model[index == -1 ? 0 : index].data_playingStatus = 1
        
        // 设置当前播放列表
        MPModelTools.saveCurrentPlayList(currentList: model)
        
        // 发送一个通知播放
        NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_PlayCurrentList), object: nil)
        
    }
}
