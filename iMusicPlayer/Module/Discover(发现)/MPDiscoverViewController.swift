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
        
    }

    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.recommendIdentifier
        self.identifier = Constant.recentlyIdentifier
        self.identifier = Constant.discoverIdentifier
        self.identifier = Constant.categoryIdentifier
    
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
                self?.play(index: index)
                
            }
            break
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.recentlyIdentifier)!
            (cell as! MPRecentlyTableViewCell).model = self.currentAlbum
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
                        self?.play()
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
    private func play(index: Int = -1) {
        // 显示当前的播放View
        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
            if let m = self.model?.data_recommendations  {
                var cs: MPSongModel?
                // 循序不能倒过来
                if index != -1 {
                    cs = m[index]
                }else {
                    cs = m.first
                }
                pv.currentSong = cs
                pv.model = m
                // 构造当前播放专辑列表模型
                let tempImg = cs?.data_artworkBigUrl ?? ""
                let img = (tempImg == "" ? (cs?.data_artworkUrl ?? "") : tempImg) == "" ? "pic_album_default" : (tempImg == "" ? (cs?.data_artworkUrl ?? "") : tempImg)
                let json: [String : Any] = ["id": 0, "title": "Top 100", "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": img, "tracksCount": m.count, "recentlyType": 7]
//                let album = GeneralPlaylists(JSON: json)
                let album = Mapper<GeneralPlaylists>().map(JSON: json)
                pv.currentAlbum = album
                pv.bigStyle()
            }
        }
    }
}
