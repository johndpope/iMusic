//
//  MPEditSongListDetailViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPEditSongListDetailTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
    static let topHeight = SCREEN_WIDTH * (48/375)
}

class MPEditSongListDetailViewController: BaseTableViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewH: NSLayoutConstraint! {
        didSet {
            topViewH.constant = NavBarHeight
        }
    }
    @IBOutlet weak var xib_selectAll: UIButton!
    
    /// 刷新专辑信息回调
    var updateAlbumBlock: ((_ album: GeneralPlaylists)->Void)?
    
    var songListModel: GeneralPlaylists?
    
    var selectModel = [MPSongModel]()
    
    var model = [MPSongModel]()
    
    var dragger: TableViewDragger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configDragger()
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        view.sendSubviewToBack(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.bottom.equalTo(self.view.safeArea.bottom).offset(-Constant.rowHeight)
            make.top.equalToSuperview().offset(topViewH.constant)
        }

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
        
        // 将tableView往下挤
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: Constant.topHeight)))
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        switch sender.tag {
        case 10001:   // 全选
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                self.selectAll()
            }else {
                self.normalAll()
            }
            break
        case 10002:   // 完成
            self.dismiss(animated: true, completion: nil)
            break
        case 10003: // 下一首播放
            nextPlay()
            break
        case 10004: // 添加到歌单
            addToSongList()
            break
        case 10005: // 删除
            deleteSelModels()
            break
        default:
            break
        }
    }
    
    
}
extension MPEditSongListDetailViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPEditSongListDetailTableViewCell
        cell.updateCell(model: model[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.model[indexPath.row].data_isSelected = self.model[indexPath.row].data_isSelected == 1 ? 0 : 1
        tableView.reloadRows(at: [indexPath], with: .automatic)
        // 添加到选中模型中
        self.addToSelectModels(model: model[indexPath.row])
        checkSelectAll()
    }
}
// MARK: - 操作是否选中
extension MPEditSongListDetailViewController {
    
    /// // 删除当前模型和本地模型：刷新数据
    private func deleteSelModels() {
        if selectModel.count == 0 {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("请选择", comment: ""))
            return
        }else {
            var alert: HFAlertController?
            let config = MDAlertConfig()
            config.title = NSLocalizedString("删除", comment: "") + "\n"
            config.desc = NSLocalizedString("您确定要刪除吗？", comment: "")
            config.negativeTitle = NSLocalizedString("取消", comment: "")
            config.positiveTitle = NSLocalizedString("OK", comment: "")
            config.negativeTitleColor = Color.ThemeColor
            config.positiveTitleColor = Color.ThemeColor
            alert = HFAlertController.alertController(config: config, ConfirmCallBack: {
                // 确定
                // 本地删除
                MPModelTools.deleteSongInTable(tableName: self.songListModel?.data_title ?? "", songs: self.selectModel, finished: {
                    // 当前列表删除
                    let temps: NSMutableArray = NSMutableArray(array: self.model)
                    temps.removeObjects(in: self.selectModel)
                    self.model = temps as! [MPSongModel]
                    self.tableView.reloadData()
                    alert?.dismiss(animated: true, completion: nil)
                    
                    // 更新当前专辑信息：数量图片等
                    self.updateAlbumModel(count: (self.songListModel?.data_tracksCount ?? 0) - self.selectModel.count)
                    
                    MPModelTools.updateCloudListModel(type: 4)
                })
            }) {
                // 取消
                alert?.dismiss(animated: true, completion: nil)
            }
            HFAppEngine.shared.currentViewController()?.present(alert!, animated: true, completion: nil)
        }
        
    }
    
    /// 添加到选中模型
    ///
    /// - Parameter model: 待添加的模型
    private func addToSelectModels(model: MPSongModel) {
        var isExsist = false
        self.selectModel.forEach { (item) in
            if model.data_title == item.data_title {
                isExsist = true
            }
        }
        if !isExsist, model.data_isSelected == 1 {
            self.selectModel.append(model)
        }else {
            if model.data_isSelected == 0 {
                let temps: NSMutableArray = NSMutableArray(array: selectModel)
                temps.remove(model)
                selectModel = temps as! [MPSongModel]
            }
        }
    }
    
    /// 是否需要全选
    private func checkSelectAll() {
        var count = 0
        model.forEach { (item) in
            if item.data_isSelected == 1 {
                count++
            }
        }
        if count == model.count {
            self.selectAll()
        }else {
            xib_selectAll.isSelected = false
        }
    }
    
    /// 全选
    private func selectAll() {
        model.forEach { (item) in
            item.data_isSelected = 1
        }
        selectModel = model
        xib_selectAll.isSelected = true
        tableView.reloadData()
    }
    
    /// 反选
    private func normalAll() {
        model.forEach { (item) in
            item.data_isSelected = 0
        }
        selectModel.removeAll()
        xib_selectAll.isSelected = false
        tableView.reloadData()
    }
}

extension MPEditSongListDetailViewController {
    
    /// 添加到歌单列表
    func addToSongList() {
        if selectModel.count == 0 {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("请选择", comment: ""))
            return
        }
        
        let lv = MPAddToSongListView.md_viewFromXIB() as! MPAddToSongListView
        MPModelTools.getCollectListModel(tableName: MPCreateSongListViewController.classCode) { (model) in
            if let m = model {
                lv.model = m
            }
        }
        // 新建歌单
        lv.createSongListBlock = {
            let pv = MPCreateSongListView.md_viewFromXIB(cornerRadius: 4) as! MPCreateSongListView
            pv.clickBlock = {(sender) in
                if let btn = sender as? UIButton {
                    if btn.tag == 10001 {
                        pv.removeFromWindow()
                    }else {
                        // 新建歌单操作
                        if MPModelTools.createSongList(songListName: pv.xib_songListName.text ?? "") {
                            // 刷新数据
                            MPModelTools.getCollectListModel(tableName: MPCreateSongListViewController.classCode) { (model) in
                                if let m = model {
                                    lv.model = m
                                }
                            }
                            
                            // 更新上传模型
                            MPModelTools.updateCloudListModel(type: 4)
                        }else {
                            SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌单已存在", comment: ""))
                        }
                        pv.removeFromWindow()
                    }
                }
            }
            HFAlertController.showCustomView(view: pv)
        }
        // 加入歌单
        lv.addSongListBlock = {(songList) in
            if let tn = songList.data_title {
                self.selectModel.forEach({ (song) in    // 循环添加歌曲
                    if !MPModelTools.checkSongExsistInSongList(song: song, songList: songList) {
                        MPModelTools.saveSongToTable(song: song, tableName: tn)
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("成功添加歌单", comment: ""))
                        // 更新当前歌单图片及数量：+1
                        MPModelTools.updateCountForSongList(songList: songList, finished: {
                            lv.removeFromWindow()
                        })
                        
                        // 更新上传模型
                        MPModelTools.updateCloudListModel(type: 4)
                    }else {
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已经收录到歌单了", comment: ""))
                    }
                })
            }
        }
        
        HFAlertController.showCustomView(view: lv, type: HFAlertType.ActionSheet)
    }
    
    /// 下一首播放
    func nextPlay() {
        if selectModel.count == 0 {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("请选择", comment: ""))
            return
        }
        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
            if pv.model.count > 0, let cs = pv.currentSong {
                let currentPlayingList = pv.model
                self.selectModel.forEach({ (song) in // 循环添加到下一首播放
                    var exsist = false
                    // 添加到播放列表的下一首: 判断是否在列表中：在则调换到下一首，不在则添加到下一首
                    currentPlayingList.forEach({ (item) in
                        if song.data_title == item.data_title {
                            exsist = true
                        }
                    })
                    if !exsist {
                        let index = self.getIndexFromSongs(song: cs, songs: currentPlayingList)
                        let nextIndex = (index + 1) % currentPlayingList.count
                        pv.model.insert(song, at: nextIndex)
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("已添加，下一首播放", comment: ""))
                    }else {
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已经收录到歌单了", comment: ""))
                    }
                })
            }else {
                // 直接添加选中歌曲到播放列表并开始播放
                self.play()
            }
        }
    }
    
    /// 添加到播放列表
    ///
    /// - Parameter song: -
    func addToPlayList(song: MPSongModel) {
        // 添加到播放列表: 判断是否在列表中：不在则添加
        if !MPModelTools.checkSongExsistInPlayingList(song: song) {
            MPModelTools.getCurrentPlayList { (model, currentPlaySong) in
                var m = model
                m.append(song)
//                if var m = model {
//                    m.append(song)
//                }
            }
        }else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已经收录到歌单了", comment: ""))
        }
    }
    
    // 获取当前下标
    private func getIndexFromSongs(song: MPSongModel, songs: [MPSongModel]) -> Int {
        var index = 0
        for i in (0..<songs.count) {
            if song == songs[i] {
                index = i
            }
        }
        return index
    }
    
}
// MARK: - 播放歌曲
extension MPEditSongListDetailViewController {
    
    /// 播放选中歌曲列表
    ///
    /// - Parameter index: -
    private func play(index: Int = -1) {
        // 显示当前的播放View
//        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
//            var cs: MPSongModel?
//            // 循序不能倒过来
//            if index != -1 {
//                cs = selectModel[index]
//            }else {
//                cs = selectModel.first
//            }
//            pv.currentSong = cs
//            pv.model = selectModel
//            pv.currentAlbum = songListModel
//            pv.smallStyle()
//        }
        
        // 保存最近播放专辑
        songListModel?.data_songs = selectModel
        MPModelTools.saveRecentlyAlbum(album: songListModel!)
        
        selectModel[index].data_playingStatus = 1
        
        MPModelTools.saveCurrentPlayList(currentList: selectModel)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, userInfo: ["randomMode" : 0])
        
    }
    
    /// 更新专辑信息
    ///
    /// - Parameter count: 专辑单曲数量
    private func updateAlbumModel(count: Int = -1) {
        // 更新当前专辑信息：数量图片等
        let tempM = self.songListModel
        if count != -1 {
            tempM?.data_tracksCount = count
        }
        tempM?.data_img = self.model.first?.data_artworkUrl ?? "pic_album_default"
        MPModelTools.updateCountForSongList(songList: tempM!, finished: {
            QYTools.shared.Log(log: "专辑信息更新成功")
            if let b = self.updateAlbumBlock {
                b(tempM!)
            }
        })
    }
}
// MARK: - 拖动效果实现
extension MPEditSongListDetailViewController: TableViewDraggerDataSource, TableViewDraggerDelegate {
    
    /// 配置拖动控制器
    private func configDragger() {
        dragger = TableViewDragger(tableView: tableView)
        dragger.availableHorizontalScroll = true
        dragger.dataSource = self
        dragger.delegate = self
        dragger.alphaForCell = 0.7
    }
    
    func dragger(_ dragger: TableViewDragger, moveDraggingAt indexPath: IndexPath, newIndexPath: IndexPath) -> Bool {
        let item = model[indexPath.row]
        model.remove(at: indexPath.row)
        model.insert(item, at: newIndexPath.row)
        tableView.moveRow(at: indexPath, to: newIndexPath)
        // 数据库更新本地数据：
        updateModels(at: indexPath, to: newIndexPath)
        return true
    }
    
    /// 更新本地模型
    ///
    /// - Parameters:
    ///   - at: 当前位置
    ///   - to: 移动后位置
    private func updateModels(at: IndexPath, to: IndexPath) {
        // 删除当前位置元素
//        if NSArray.bg_deleteObject(withName: songListModel?.data_title ?? "", index: at.row) {
//            // 插入数据没有提供方法
//        }
        
        // 删除原来的数据并重新保存到数据表中
        let tbn = songListModel?.data_title ?? ""
        NSArray.bg_dropAsync(tbn) { (finished) in
            if finished {
                if (self.model as NSArray).bg_save(withName: tbn) {
                    QYTools.shared.Log(log: "本地模型更新成功")
                    self.updateAlbumModel()
                }
            }
        }
        
    }
    
}
