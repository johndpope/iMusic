//
//  MPRankingViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPCollectSongListTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (90/375)
}

class MPCollectSongListViewController: BaseTableViewController {
    
    var model = [GeneralPlaylists]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
    }
    
    override func refreshData() {
        super.refreshData()
        MPModelTools.getCollectListModel(tableName: MPCollectSongListViewController.classCode) { (model) in
            if let m = model {
                self.model = m
                self.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("我收藏的歌单", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
        addRightItem(imageName: "nav_icon_search")
    }
    
    override func clickLeft() {
        super.clickLeft()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func clickRight(sender: UIButton) {
        super.clickRight(sender: sender)
        
        let vc = MPSearchViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.identifier
        
    }
    
}
extension MPCollectSongListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPCollectSongListTableViewCell
        cell.selectionStyle = .none
        cell.updateCell(model: model[indexPath.row], type: 1)
        cell.clickBlock = {(sender) in
            self.deleteSongList(index: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MPSongListViewController()
        vc.headerSongModel = model[indexPath.row]
        vc.type = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension MPCollectSongListViewController {
    /// 删除歌单
    func deleteSongList(index: Int) {
        let tempM = model[index]
        QYTools.shared.Log(log: "删除歌单")
        var alert: HFAlertController?
        let config = MDAlertConfig()
        config.title = NSLocalizedString("删除歌单\n", comment: "")
        config.desc = NSLocalizedString("确定要删除歌单\(tempM.data_title ?? "")吗？", comment: "")
        config.negativeTitle = NSLocalizedString("取消", comment: "")
        config.positiveTitle = NSLocalizedString("OK", comment: "")
        config.negativeTitleColor = Color.ThemeColor
        config.positiveTitleColor = Color.ThemeColor
        alert = HFAlertController.alertController(config: config, ConfirmCallBack: {
            // 删除本地模型数据并刷新
            MPModelTools.deleteCollectListModel(songList: tempM, tableName: MPCollectSongListViewController.classCode, finished: {
                self.refreshData()
            })
        }) {
            // 取消
            alert?.dismiss(animated: true, completion: nil)
        }
        HFAppEngine.shared.currentViewController()?.present(alert!, animated: true, completion: nil)
    }
}
