//
//  MPMediaLibraryViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/12.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let mediaLibraryIdentifier = "MPMediaLibraryTableViewCell"
    static let categoryIdentifier = "MPCategoryTableViewCell"
}

class MPMediaLibraryViewController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.mediaLibraryIdentifier
        self.identifier = Constant.categoryIdentifier
        
    }
    
}
extension MPMediaLibraryViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number = 3
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
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.categoryIdentifier)!
            (cell as! MPCategoryTableViewCell).updateCell(model: MPMediaLibraryModel.categoryDatas[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = SCREEN_WIDTH * (52/375)
        if indexPath.section == 0 {
            height = SCREEN_WIDTH * (52/375)
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
            shv.updateView(model: NSLocalizedString("最近播放", comment: ""))
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
        case 0:
            let vc = MPMyFavoriteViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 1:
            let vc = MPCreateSongListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2:
            let vc = MPCollectSongListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
    
}
