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
             number = 3
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
            break
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.recentlyIdentifier)!
            break
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.categoryIdentifier)!
            break
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.discoverIdentifier)!
            break
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = SCREEN_WIDTH * (117/375)
        switch indexPath.section {
        case 0:
            height = SCREEN_WIDTH * (220/375)
            break
        case 1:
            height = SCREEN_WIDTH * (180/375)
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
        return shv
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 0
        }
        return 80
    }
    
}
