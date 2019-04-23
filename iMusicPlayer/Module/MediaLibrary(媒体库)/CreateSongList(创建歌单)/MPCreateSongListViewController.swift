//
//  MPRankingViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import ObjectMapper

private struct Constant {
    static let identifier = "MPCollectSongListTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (90/375)
}

class MPCreateSongListViewController: BaseTableViewController {
    
    var model = [GeneralPlaylists]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentIndex: Int = 0
    
    var extensionView: MPSongExtensionToolsView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    override func refreshData() {
        super.refreshData()
//        NSArray.bg_delete(MPCreateSongListViewController.classCode, row: 1)
        MPModelTools.getCollectListModel(tableName: MPCreateSongListViewController.classCode) { (model) in
            if let m = model {
                self.model = m
//                self.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("我创建的歌单", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
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
        tableView.backgroundColor = UIColor.white
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        let hv = MPCreateSongListHeaderView.md_viewFromXIB() as! MPCreateSongListHeaderView
        hv.clickBlock = {(sender) in
            if let _ = sender as? UIButton {
                let pv = MPCreateSongListView.md_viewFromXIB() as! MPCreateSongListView
                HFAlertController.showCustomView(view: pv)
                pv.clickBlock = {(sender) in
                    if let btn = sender as? UIButton {
                        if btn.tag == 10001 {
                            // 取消
                            pv.removeFromWindow()
                        }else {
                            if MPModelTools.createSongList(songListName: pv.xib_songListName.text ?? "") {
                                self.refreshData()
                            }else {
                                SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌单已存在", comment: ""))
                            }
                            pv.removeFromWindow()
                        }
                    }
                }
            }
        }
        tableView.tableHeaderView = hv
    }
    
}
extension MPCreateSongListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPCollectSongListTableViewCell
        cell.selectionStyle = .none
        cell.updateCell(model: model[indexPath.row], type: 0)
        cell.clickBlock = {(sender) in
            self.currentIndex = indexPath.row
            // 弹出菜单
            self.extensionTools(title: self.model[indexPath.row].data_title ?? "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MPEditSongListViewController()
        vc.songListModel = model[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
// MARK: - MPSongToolsViewDelegate
extension MPCreateSongListViewController: MPSongToolsViewDelegate {
    
    /// 扩展功能
    ///
    /// - Parameter title: 弹出标题
    private func extensionTools(title: String) {
        let pv = MPSongExtensionToolsView.md_viewFromXIB() as! MPSongExtensionToolsView
        extensionView = pv
        pv.plistName = "createSLExtensionTools"
        pv.delegate = self
        pv.title = title
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
    }
    
    /// 修改名称
    func modifyAlbumName() {
        
        extensionView?.removeFromWindow()
        
        let tempM = model[currentIndex]
        let tableName = tempM.data_title ?? ""
        
        let pv = MPCreateSongListView.md_viewFromXIB() as! MPCreateSongListView
        
        pv.xib_title.text = NSLocalizedString("修改名称", comment: "")
        pv.xib_songListName.placeholder = NSLocalizedString("请输入名称", comment: "")
        pv.xib_songListName.text = tempM.data_title
        
        HFAlertController.showCustomView(view: pv)
        pv.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                if btn.tag == 10001 {
                    // 取消
                    pv.removeFromWindow()
                }else {
                    tempM.data_title = pv.xib_songListName.text
                    MPModelTools.updateCountForSongList(songList: tempM, tableName: tableName, finished: {
                        QYTools.shared.Log(log: "修改名称成功")
                        self.refreshData()
                    })
                    pv.removeFromWindow()
                }
            }
        }
    }
    
    /// 删除歌单
    func deleteSongList() {
        
        extensionView?.removeFromWindow()
        
        let tempM = model[currentIndex]
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
            MPModelTools.deleteCollectListModel(songList: tempM, tableName: MPCreateSongListViewController.classCode, finished: {
                self.refreshData()
            })
        }) {
            // 取消
            alert?.dismiss(animated: true, completion: nil)
        }
        HFAppEngine.shared.currentViewController()?.present(alert!, animated: true, completion: nil)
    }
    
}
