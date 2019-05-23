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
    static let sectionHeight = SCREEN_WIDTH * (60/375)
}

class MPCreateSongListViewController: BaseTableViewController {
    
    var model = [GeneralPlaylists]() {
        didSet {
            tableView.reloadData()
            if model.count == 0 {
                noDataView.isHidden = false
            }else {
                noDataView.isHidden = true
            }
        }
    }
    
    var currentIndex: Int = 0
    
    var extensionView: MPSongExtensionToolsView?
    
    var noDataView: MPNoDataView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(NotCenter.NC_RefreshLocalModels), object: nil, queue: nil) { (center) in
            self.refreshData()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    override func refreshData() {
        super.refreshData()
        
//        if let localModel = DiscoverCent?.data_CloudListUploadModel, let model = localModel.data_customlist {
//            self.model = model
//        }else {
//            MPModelTools.getCollectListModel(tableName: MPCreateSongListViewController.classCode) { (model) in
//                if let m = model {
//                    self.model = m
//                    self.saveListToCloudModel(m: m)
//                }
//            }
//        }
        
        MPModelTools.getCollectListModel(tableName: MPCreateSongListViewController.classCode) { (model) in
            if let m = model {
                self.model = m
//                self.saveListToCloudModel(m: m)
            }
        }
    }
    
//    private func saveListToCloudModel(m: [GeneralPlaylists]) {
//        DispatchQueue.init(label: "SaveListToCloud").async {
//            // 保存到上传模型
//            if DiscoverCent?.data_CloudListUploadModel.data_customlist?.count ?? 0 > m.count {
//                DiscoverCent?.data_CloudListUploadModel.data_customlistReset = 1
//                
//                DiscoverCent?.data_CloudListUploadModel.data_customlist = m
//                // 将歌单里面的数据赋值到data_data
//                for i in 0..<m.count {
//                    let item = m[i]
//                    MPModelTools.getSongInTable(tableName: item.data_title ?? "") { (model) in
//                        if let m = model {
//                            item.data_data = m
//                        }
//                    }
//                    DiscoverCent?.data_CloudListUploadModel.data_customlist?[i] = item
//                }
//            }else {
//                DiscoverCent?.data_CloudListUploadModel.data_customlistReset = 0
//                // 只需要赋值增加的项
//                let location = DiscoverCent?.data_CloudListUploadModel.data_customlist?.count ?? 0
//                let length = m.count-location
//                guard var clist = DiscoverCent?.data_CloudListUploadModel.data_customlist else {
//                    return
//                }
//                clist += ((m as NSArray).subarray(with: NSRange(location: location, length: length)) as? [GeneralPlaylists])!
//                // 将歌单里面的数据赋值到data_data
//                for i in location..<m.count {
//                    let item = m[i]
//                    MPModelTools.getSongInTable(tableName: item.data_title ?? "") { (model) in
//                        if let m = model {
//                            item.data_data = m
//                        }
//                    }
//                    DiscoverCent?.data_CloudListUploadModel.data_customlist?[i] = item
//                }
//            }
//        }
//    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("我的歌单", comment: "").decryptString(), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
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
        
        setupNoDataView(image: "pic_noresault", text: NSLocalizedString("暂无歌单", comment: "").decryptString())
    }
    
    private func setupNoDataView(image: String, text: String) {
        // 添加无数据提示View
        let sv = MPNoDataView.md_viewFromXIB() as! MPNoDataView
        let x: CGFloat = 20
        let width = (tableView.width - 40)
        let height = SCREEN_WIDTH * (180/375)
        let hvH = tableView.tableHeaderView?.height ?? 0
        let y = (SCREEN_HEIGHT-NavBarHeight-TabBarHeight - height - hvH) * 1/2
        sv.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
        sv.updateView(image: image, text: text)
        sv.isHidden = true
        noDataView = sv
        tableView.addSubview(sv)
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        let hv = MPCreateSongListHeaderView.md_viewFromXIB() as! MPCreateSongListHeaderView
        hv.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: Constant.sectionHeight))
        hv.clickBlock = {(sender) in
            if let _ = sender as? UIButton {
                let pv = MPCreateSongListView.md_viewFromXIB(cornerRadius: 4) as! MPCreateSongListView
                HFAlertController.showCustomView(view: pv)
                pv.clickBlock = {(sender) in
                    if let btn = sender as? UIButton {
                        if btn.tag == 10001 {
                            // 取消
                            pv.removeFromWindow()
                        }else {
                            guard let sName = pv.xib_songListName.text, sName != "" else {
                                SVProgressHUD.showInfo(withStatus: NSLocalizedString("请输入歌单名称", comment: "").decryptString())
                                return
                            }
                            if MPModelTools.createSongList(songListName: sName) {
                                self.refreshData()
                                // 更新上传模型
                                MPModelTools.updateCloudListModel(type: 4)
                            }else {
                                SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌单已存在", comment: "").decryptString())
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
        
        pv.updateTableViewHeight()
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
    }
    
    /// 修改名称
    func modifyAlbumName() {
        
        extensionView?.removeFromWindow()
        
        let tempM = model[currentIndex]
        let tableName = tempM.data_title ?? ""
        
        let pv = MPCreateSongListView.md_viewFromXIB() as! MPCreateSongListView
        
        pv.xib_title.text = NSLocalizedString("更改名称", comment: "").decryptString()
        pv.xib_songListName.placeholder = NSLocalizedString("请输入歌单名称", comment: "").decryptString()
        pv.xib_songListName.text = tempM.data_title
        // 给旧名称赋值
        tempM.data_oldTitle = pv.xib_songListName.text
        
        HFAlertController.showCustomView(view: pv)
        pv.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                if btn.tag == 10001 {
                    // 取消
                    pv.removeFromWindow()
                }else {
                    tempM.data_title = pv.xib_songListName.text
                    MPModelTools.updateCountForSongList(songList: tempM, tableName: tableName, finished: {
                        self.refreshData()
                        
                        MPModelTools.updateCloudListModel(type: 4)
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
        var alert: HFAlertController?
        let config = MDAlertConfig()
        config.title = NSLocalizedString("删除", comment: "").decryptString() + "\n"
        config.desc = NSLocalizedString("确定要删除歌单", comment: "").decryptString() + (tempM.data_title ?? "") + NSLocalizedString("吗？", comment: "").decryptString()
        config.negativeTitle = NSLocalizedString("取消", comment: "").decryptString()
        config.positiveTitle = NSLocalizedString("OK", comment: "").decryptString()
        config.negativeTitleColor = Color.ThemeColor
        config.positiveTitleColor = Color.ThemeColor
        alert = HFAlertController.alertController(config: config, ConfirmCallBack: {
            // 删除本地模型数据并刷新
            MPModelTools.deleteCollectListModel(songList: tempM, tableName: MPCreateSongListViewController.classCode, finished: {
                self.refreshData()
                MPModelTools.updateCloudListModel(type: 4)
            })
        }) {
            // 取消
            alert?.dismiss(animated: true, completion: nil)
        }
        HFAppEngine.shared.currentViewController()?.present(alert!, animated: true, completion: nil)
    }
    
}
