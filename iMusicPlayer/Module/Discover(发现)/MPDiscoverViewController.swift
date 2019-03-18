//
//  MPDiscoverViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/12.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let discoverIdentifier = "MPDiscoverTableViewCell"
    static let categoryIdentifier = "MPCategoryTableViewCell"
    static let recommendIdentifier = "MPRecommendTableViewCell"
    static let recentlyIdentifier = "MPRecentlyTableViewCell"
}

class MPDiscoverViewController: BaseTableViewController {

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
             number = 5
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
            (cell as! MPRecommendTableViewCell).itemClickedBlock = {[weak self] (index) in
                let vc = MPPlayingViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.recentlyIdentifier)!
            (cell as! MPRecentlyTableViewCell).itemClickedBlock = {[weak self] (index) in
                let vc = MPAlbumListViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.categoryIdentifier)!
            (cell as! MPCategoryTableViewCell).updateCell(model: MPDiscoverModel.categoryDatas[indexPath.row])
            break
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.discoverIdentifier)!
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
            height = SCREEN_WIDTH * (220/375)
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
            if let btn = sender as? UIButton {
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
            
        }
    }
    
}
