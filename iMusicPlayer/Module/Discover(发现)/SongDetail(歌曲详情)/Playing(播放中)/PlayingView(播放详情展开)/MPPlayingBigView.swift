//
//  MPPlayingBigView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/1.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

private struct Constant {
    static let smallPlayerWidth = SCREEN_HEIGHT * (90/(IPHONEX ? 812 : 667))
    static let sbReduceHeight = SCREEN_WIDTH * (58/375)
    static let smallPlayerHeight = SCREEN_WIDTH * (48/375)
}

class MPPlayingBigView: BaseView {
    
    var moreView: MPSongExtensionToolsView?
    
    var playView: YTPlayerView?
    
    var playingView: MPPlayingView!

    @IBOutlet weak var xib_playingView: UIView! {
        didSet {
            let pv = MPPlayingView()
            playingView = pv
            playingView.delegate = self
            xib_playingView.addSubview(pv)
            pv.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            self.smallStyle()
        }
    }
    
    @IBOutlet weak var contentViewH: NSLayoutConstraint!
    @IBOutlet weak var playerViewTop: NSLayoutConstraint!
    @IBOutlet weak var xib_topView: MPPlayingNavView!
    
    var defaultTopViewH: CGFloat = 0
    @IBOutlet weak var topViewH: NSLayoutConstraint! {
        didSet {
            defaultTopViewH = topViewH.constant
        }
    }
    @IBOutlet weak var xib_nextSongName: UILabel!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    @IBOutlet weak var xib_lrc: UIButton!
    @IBOutlet weak var xib_slider: UISlider! {
        didSet {
            xib_slider.value = 0
            xib_slider.addTarget(self, action: #selector(sliderDidChange(sender:)), for: .valueChanged)
        }
    }
    
    @IBOutlet weak var playBgView: UIView!
    
    private lazy var ybPlayView: YTPlayerView = {
        let pv = YTPlayerView()
        playView = pv
        pv.backgroundColor = UIColor.red
        pv.delegate = self
        return pv
    }()
    
    @IBOutlet weak var xib_startTime: UILabel!
    
    @IBOutlet weak var xib_endTime: UILabel!
    
    @IBOutlet weak var xib_play: UIButton!
    @IBOutlet weak var xib_cycleMode: UIButton!
    @IBOutlet weak var xib_orderMode: UIButton!
    @IBOutlet weak var xib_collect: UIButton!
//    , "autoplay": "0"
    var playerVars: [String : Any] = [ "showinfo": "0", "modestbranding" : "1", "playsinline": "1", "controls": "0", "autohide": "1"]
    
    var currentPlayOrderMode: Int = 0  // 0: 顺序播放  1: 随机播放
    
    var currentPlayCycleMode: Int = 0 // 0: 列表循环  1: 单曲循环 2: 只播放当前列表
    
    var songID: String = ""
    
    var currentSong: MPSongModel? {
        didSet {
            songID = currentSong?.data_originalId ?? ""
            // 设置播放状态
            currentSong?.data_playingStatus = 1
        }
    }
    
    var randomModel = [MPSongModel]()
    
    var model = [MPSongModel]() {
        didSet {
            // 将当前播放列表保存到数据库
            MPModelTools.saveCurrentPlayList(currentList: model)
            
            if currentPlayOrderMode == 1 {  // 随机播放
                var t = self.model
                randomModel = t.randomObjects_ck()
            }
            
            // *** 这里是要','拼接的字符串不是数组：参数错误导致播放失败
            playerVars["playlist"] = getSongIDs(songs: currentPlayOrderMode == 1 ? randomModel : model).joined(separator: ",")
            updateView()
        }
    }
    
    var currentAlbum: GeneralPlaylists?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
        xib_topView.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                if btn.tag == 10001 {
                    self.smallStyle()
                }else {
                    // 全屏播放
                    self.playerVars["playsinline"] = 0
                    self.ybPlayView.playVideo()
                }
            }
        }
    }
    
    func setupStyle() {
        if !IPHONEX {
            topViewH.constant = defaultTopViewH - Constant.sbReduceHeight
        }
        
        playerViewTop.constant = StatusBarHeight
        self.height = SCREEN_HEIGHT - TabBarHeight + Constant.smallPlayerHeight + StatusBarHeight
        contentViewH.constant = SCREEN_HEIGHT  - TabBarHeight - StatusBarHeight
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        switch sender.tag {
        case 10001: // 歌词
            let pv = MPLrcView.md_viewFromXIB() as! MPLrcView
            HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
            break
        case 10002: // 上一曲
            ybPlayView.previousVideo()
            // 刷新当前view
            self.currentSong = getPreSongFromSongs(song: self.currentSong!, songs: currentPlayOrderMode == 1 ? randomModel : model)
            self.updateView(type: 1)
            break
        case 10003: // 暂停/播放
            playDidClicked()
            break
        case 10004: // 下一曲
            ybPlayView.nextVideo()
            // 刷新当前view
            self.currentSong = getNextSongFromSongs(song: self.currentSong!, songs: currentPlayOrderMode == 1 ? randomModel : model)
            self.updateView(type: 1)
            break
        case 10005: // 播放模式：列表循环/单曲循环
            currentPlayCycleMode = (currentPlayCycleMode + 1) % 2
            setCycleModeImage()
            break
        case 10006: // 随机播放
            sender.isSelected = !sender.isSelected
            currentPlayOrderMode = sender.isSelected ? 1 : 0
            
            currentPlayCycleMode = sender.isSelected ? 2 : 0
            setCycleModeImage()
            
            if sender.isSelected {
                getRandomModel()
                updateView()
            }
            
            break
        case 10007: // 收藏
            // 添加到我的最爱列表
            if !MPModelTools.checkSongExsistInPlayingList(song: self.currentSong!, tableName: MPMyFavoriteViewController.classCode) {
                // 标记为收藏状态：喜爱列表、当前列表
                self.currentSong?.data_collectStatus = 1
                MPModelTools.saveSongToTable(song: self.currentSong!, tableName: MPMyFavoriteViewController.classCode)
                // 设置为收藏状态
                xib_collect.isSelected = true
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲收藏成功", comment: ""))
            }else {
                // 取消收藏
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已经收藏", comment: ""))
            }
            break
        case 10008: // 添加到歌单
            addToSongList()
            break
        case 10009: // 附加功能
            extensionTools()
            break
        case 10010: // 播放列表
            let pv = MPPlayingListsPopView.md_viewFromXIB() as! MPPlayingListsPopView
            pv.model = self.model
            HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
            pv.updateRelateSongsBlock = {(type) in
                if type == 0 {
                    pv.model = self.model
                }else if type == 1 {
                    MPModelTools.getRelatedSongsModel(id: self.songID, tableName: "", finished: { (model) in
                        if let m = model {
                            pv.model = m
                        }
                    })
                }
            }
            break
        default:
            break
        }
    }
}
// MARK: - 歌曲控制相关操作
extension MPPlayingBigView {
    func addToSongList() {
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
            if let song = self.currentSong, let tn = songList.data_title {
                if !MPModelTools.checkSongExsistInSongList(song: song, songList: songList) {
                    MPModelTools.saveSongToTable(song: self.currentSong!, tableName: tn)
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲添加成功", comment: ""))
                    // 更新当前歌单图片及数量：+1
                    MPModelTools.updateCountForSongList(songList: songList, finished: {
                        lv.removeFromWindow()
                    })
                }else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已在该歌单中", comment: ""))
                }
            }
        }
        
        HFAlertController.showCustomView(view: lv, type: HFAlertType.ActionSheet)
    }
    
    func extensionTools() {
        let pv = MPSongExtensionToolsView.md_viewFromXIB() as! MPSongExtensionToolsView
        self.moreView = pv
        pv.plistName = "extensionTools"
        pv.delegate = self
        pv.title = (SourceType == 0 ? currentSong?.data_title : currentSong?.data_songName) ?? ""
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
    }
}
// MARK: - MPSongToolsViewDelegate
extension MPPlayingBigView: MPSongToolsViewDelegate {
    
    func timeOff() {
        QYTools.shared.Log(log: "定时关闭")
        // 关闭弹框
        self.moreView?.removeFromWindow()
        // 缩小当前的View
        self.smallStyle()
        let vc = MPTimeOffViewController()
        HFAppEngine.shared.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func playVideo() {
        QYTools.shared.Log(log: "播放视频")
    }
    
    func songInfo() {
        QYTools.shared.Log(log: "歌曲信息")
        // 关闭弹框
        self.moreView?.removeFromWindow()
        let pv = MPSongInfoView.md_viewFromXIB() as! MPSongInfoView
        pv.updateView(model: self.currentSong!)
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
        
        pv.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                
                // 关闭弹框
                self.moreView?.removeFromWindow()
                // 缩小当前的View
                self.smallStyle()
                
                pv.removeFromWindow()
                
                if btn.tag == 10001 {    // 协议
                    let path = Bundle.main.path(forResource: "policy", ofType: "plist")
                    if let p = path, let policys = NSDictionary(contentsOfFile: p) {
                        let vc = MDWebViewController()
                        vc.title = NSLocalizedString("隐私政策", comment: "")
                        vc.text = policys["policy_1"] as! String
                        HFAppEngine.shared.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
                    }
                }else {     // 投诉
                    
                }
            }
        }
    }
}
// MARK: - 歌曲控制相关操作
extension MPPlayingBigView {
    
    @objc func sliderDidChange(sender: UISlider) {
        let value = sender.value
        let progress = Float(currentSong?.data_durationInSeconds ?? 0) * value
        ybPlayView.seek(toSeconds: progress, allowSeekAhead: true)
        xib_play.isSelected = true
    }
    
    private func getRandomModel() {
        self.model = self.model.randomObjects_ck()
    }
    
    private func setCycleModeImage() {
        switch currentPlayCycleMode {
        case 0:
            xib_cycleMode.setImage(UIImage(named: "icon_play_order-1"), for: .normal)
            xib_orderMode.isSelected = false
            currentPlayOrderMode = 0
            break
        case 1:
            xib_cycleMode.setImage(UIImage(named: "icon_play_single"), for: .normal)
            xib_orderMode.isSelected = false
            currentPlayOrderMode = 0
            break
        case 2:
            xib_cycleMode.setImage(UIImage(named: "icon_play_order_off"), for: .normal)
            xib_orderMode.isSelected = true
            currentPlayOrderMode = 1
            break
        default:
            break
        }
    }
    
    private func updateView(type: Int = -1) {
        if SourceType == 0 {
            xib_lrc.isSelected = false
            xib_title.text = currentSong?.data_title
            xib_desc.text = currentSong?.data_channelTitle
        }else {
            xib_lrc.isSelected = true
            xib_title.text = currentSong?.data_songName
            xib_desc.text = currentSong?.data_singerName
        }
        // 设置下一首播放
        let nextSong = getNextSongFromSongs(song: self.currentSong!, songs: currentPlayOrderMode == 1 ? randomModel : model)
        if SourceType == 0 {
            xib_nextSongName.text = nextSong.data_title ?? ""
        }else {
            xib_nextSongName.text = nextSong.data_songName ?? ""
        }
        
        // 设置时间
        xib_startTime.text = "0".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
        xib_endTime.text = "\(currentSong?.data_durationInSeconds ?? 0)".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
        
        // 播放MV
        ybPlayView.load(withVideoId: currentSong?.data_originalId ?? "", playerVars: playerVars)
//        ybPlayView1.load(withVideoId: currentSong?.data_originalId ?? "", playerVars: playerVars)
        
        // 异步更新当前列表状态
        DispatchQueue.main.async {
            self.xib_collect.isSelected = MPModelTools.checkSongExsistInPlayingList(song: self.currentSong!, tableName: MPMyFavoriteViewController.classCode)
        }
        
        // 小窗口播放数据源
        playingView.currentIndex = model.getIndexFromArray(song: self.currentSong!, songs: currentPlayOrderMode == 1 ? randomModel : model)
        playingView.model = currentPlayOrderMode == 1 ? randomModel : model
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
    
    private func getPreSongFromSongs(song: MPSongModel, songs: [MPSongModel]) -> MPSongModel {
        var index = 0
        for i in (0..<songs.count) {
            if song == songs[i] {
                let temp = i == 0 ? songs.count : i
                index = (temp-1) % songs.count
            }
        }
        return songs[index]
    }
    
    private func getNextSongFromSongs(song: MPSongModel, songs: [MPSongModel]) -> MPSongModel {
        var index = 0
        for i in (0..<songs.count) {
            if song == songs[i] {
                index = (i+1) % songs.count
            }
        }
        return songs[index]
    }
    
    private func getSongIDs(songs: [MPSongModel]) -> [String] {
        var ids = [String]()
        songs.forEach { (song) in
            ids.append(song.data_originalId ?? "")
        }
        return ids
    }
}

// MARK: - YTPlayerViewDelegate
extension MPPlayingBigView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        ybPlayView.playVideo()
        if let s = self.currentSong {
            if !MPModelTools.checkSongExsistInPlayingList(song: s, tableName: "RecentlyPlay") {
                MPModelTools.saveSongToTable(song: s, tableName: "RecentlyPlay")
            }
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        
        xib_slider.value = playTime / Float(ybPlayView.duration())
        xib_startTime.text = "\(playTime)".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        // 判断当前播放模式
        if currentPlayOrderMode == 1 { // 随机播放
            if currentPlayCycleMode == 0 {
                
            }else if currentPlayCycleMode == 1 {
                
            }else {
                
            }
        }else { // 顺序播放
            
        }
        
        switch state {
        case .buffering:
            xib_play.isSelected = false
            break
        case .playing:
            xib_play.isSelected = true
            
            // 把当前的专辑添加到最近播放
            if let a = currentAlbum {
                let index = MPModelTools.getCollectListExsistIndex(model: a, tableName: "RecentlyAlbum", condition: a.data_title ?? "")
                if index == -1 {
                    MPModelTools.saveCollectListModel(model: a, tableName: "RecentlyAlbum")
                }else {
                    // 删除原来的并将当前的插入到第一位
                    let sql = String(format: "where %@=%@",bg_sqlKey("index"),bg_sqlValue("\(index)"))
                    if NSArray.bg_delete("RecentlyAlbum", where: sql) {
                        // 添加到最后一项：获取的时候倒序即可
                        NSArray.bg_addObject(withName: "RecentlyAlbum", object: a)
                    }
                }
            }
            
            break
        case .paused:
            xib_play.isSelected = false
            break
        case .ended:
            xib_play.isSelected = false
            // 获取下一首歌曲继续播放
            //            currentSong = getNextSongFromSongs(song: currentSong!, songs: self.model)
            //            updateView()
            //            ybPlayView.playVideo()
            ybPlayView.nextVideo()
            // 刷新当前view
            self.currentSong = getNextSongFromSongs(song: self.currentSong!, songs: currentPlayOrderMode == 1 ? randomModel : model)
            self.updateView(type: 1)
            break
        case .queued:
            xib_play.isSelected = false
            break
        case .unknown:
            xib_play.isSelected = false
            break
        case .unstarted:
            xib_play.isSelected = false
            break
        default:
            break
        }
        
        // 更新小窗播放按钮状态
        playingView.currentStatus = xib_play.isSelected
        
    }
    
    
}
// MARK: - MPPlayingViewDelegate
extension MPPlayingBigView: MPPlayingViewDelegate {
    
    func playingView(pre view: MPPlayingView, index: Int) {
        ybPlayView.previousVideo()
        // 刷新当前view
        self.currentSong = (currentPlayOrderMode == 1 ? randomModel : model)[index]
        self.updateView(type: 1)
    }
    
    func playingView(next view: MPPlayingView, index: Int) {
        ybPlayView.nextVideo()
        // 刷新当前view
        self.currentSong = (currentPlayOrderMode == 1 ? randomModel : model)[index]
        self.updateView(type: 1)
    }
    
    func playingView(toDetail view: MPPlayingView) {
        QYTools.shared.Log(log: "跳转")
       
        self.bigStyle()
    }
    
    func playingView(download view: MPPlayingView) {
        QYTools.shared.Log(log: "下载")
    }
    
    func playingView(play view: MPPlayingView, status: Bool) {
        QYTools.shared.Log(log: "播放")
        playDidClicked()
    }
    
    private func playDidClicked() {
        if ybPlayView.playerState() == YTPlayerState.playing {
            ybPlayView.pauseVideo()
        }else {
            ybPlayView.playVideo()
        }
    }
    
    private func playByIndex(index: Int) {
        currentSong = (currentPlayOrderMode == 1 ? randomModel : model)[index]
        updateView()
    }
}

// MARK: - 扩展大小窗口切换时样式切换
extension MPPlayingBigView {
    
    func hiddenStyle() {
        self.top = window!.frame.height
    }
    
    func smallStyle() {
        self.top = SCREEN_HEIGHT - TabBarHeight - Constant.smallPlayerHeight
        xib_playingView.insertSubview(ybPlayView, at: 0)
        ybPlayView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(Constant.smallPlayerWidth)
        }
        
        // 显示当前的tabbar
        if let rvc = window?.rootViewController as? UITabBarController {
            let tabbar = rvc.tabBar
            tabbar.top = SCREEN_HEIGHT - TabBarHeight
        }
    }
    
    func bigStyle() {
        playBgView.addSubview(ybPlayView)
        ybPlayView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.top = -(Constant.smallPlayerHeight+StatusBarHeight)
        
        // 隐藏当前的tabbar
        if let rvc = window?.rootViewController as? UITabBarController {
            let tabbar = rvc.tabBar
            tabbar.top = SCREEN_HEIGHT
        }
    }
}
