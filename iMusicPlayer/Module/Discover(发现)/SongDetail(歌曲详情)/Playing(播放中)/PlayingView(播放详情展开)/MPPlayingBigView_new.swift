//
//  MPPlayingBigView_new.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/1.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import DOUAudioStreamer

private struct Constant {
    static let smallPlayerWidth = SCREEN_HEIGHT * (90/(IPHONEX ? 812 : 667))
    static let sbReduceHeight = SCREEN_WIDTH * (58/375)
    static let smallPlayerHeight = SCREEN_WIDTH * (48/375)
    
    static let MP3Test = "http://cache.musicfm.co/music/mp3/99024167248247705390676698909371.mp3"
    
    static let MP3URL: URL = URL(string: MP3Test)!
    
    static let CurrentPlayListTableName = "CurrentPlayList"
}

class MPPlayingBigView_new: BaseView {
    
    // MARK: - MP3属性开始
    
    //更新进度条定时器
    var timer:Timer!
    // 音量滑竿
    var volumeSlider: UISlider!
    // 当前播放歌曲下标
    var currentTrackIndex = 0
    // 当前播放歌曲在随机播放列表下标
    var currentRandomIndex = 0
    // 音频流播放器
    var streamer: DOUAudioStreamer!
    // 音频乐谱图
    var audioVisualizer: DOUAudioVisualizer!
    // MARK: - MP3属性结束
    
    /// 扩展功能View
    var moreView: MPSongExtensionToolsView?
    /// YouTube播放View
    var playView: YTPlayerView!
    /// 小窗播放View
    var playingView: MPPlayingView!
    /// 小窗播放背景View
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
    /// 大窗高度
    @IBOutlet weak var contentViewH: NSLayoutConstraint!
    /// 大窗口与小窗的距离
    @IBOutlet weak var playerViewTop: NSLayoutConstraint!
    /// 是否全屏顶部View
    @IBOutlet weak var xib_topView: MPPlayingNavView!
    var defaultTopViewH: CGFloat = 0
    /// 当前播放区域高度：根据不同屏幕跳转高度
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
    /// 播放区域背景View
    @IBOutlet weak var playBgView: UIView!
    @IBOutlet weak var xib_coverImage: UIImageView! {
        didSet {
            xib_coverImage.md_cornerRadius = 2
            xib_coverImage.contentMode = .scaleAspectFill
        }
    }
    /// YouTube播放控件
    private lazy var ybPlayView: YTPlayerView = {
        let pv = YTPlayerView()
        playView = pv
        pv.backgroundColor = UIColor.clear
        pv.delegate = self
        return pv
    }()
    @IBOutlet weak var xib_startTime: UILabel!
    @IBOutlet weak var xib_endTime: UILabel!
    @IBOutlet weak var xib_play: UIButton!
    @IBOutlet weak var xib_cycleMode: UIButton!
    @IBOutlet weak var xib_orderMode: UIButton!
    @IBOutlet weak var xib_collect: UIButton!
    
    /// YouTube播放器配置
//    var playerVars: [String: Any] = [
//        "autoplay": 0,
//        "autohide": 1,
//        "controls": 0,
//        "enablejsapi": 1,
//        "fs": 0,
//        "origin" : "https://www.youtube.com",
//        "rel": 0,
//        "showinfo": 0,
//        "iv_load_policy": 3
//    ]
    private var playerVars: [String : Any] = [ "showinfo": "0", "modestbranding" : "1", "playsinline": "1", "controls": "0", "autohide": "1"]
    
    /// 0: 顺序播放  1: 随机播放
    var currentPlayOrderMode: Int = 0 {
        didSet {
            xib_orderMode.isSelected = currentPlayOrderMode == 1 ? true : false
            if model.count > 0 {
                if currentPlayOrderMode == 1 {
                    currentRandomIndex = getRandomIndexByIndex(index: currentTrackIndex)
                }
                // 更新下一首播放
                self.updateNextSongName()
            }
        }
    }
    
    /// 0: 列表循环  1: 单曲循环 2: 只播放当前列表
    var currentPlayCycleMode: Int = 0 {
        didSet {
            setCycleModeImage()
        }
    }
    
    private var currentSouceType: Int = SourceType
    
    var currentSong: MPSongModel?
    
    /// 随机播放列表
    var randomModel = [MPSongModel]()
    
    /// 当前播放歌曲所属专辑列表
    var currentAlbum: GeneralPlaylists?
    
    var model = [MPSongModel]()
    
    // MARK: - 重新整理逻辑开始
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
        setupAction()
    }
    
    private func setupStyle() {
        playView.isHidden = true
        xib_coverImage.isHidden = true
        
        if !IPHONEX {
            topViewH.constant = defaultTopViewH - Constant.sbReduceHeight
        }
        
        playerViewTop.constant = StatusBarHeight
        self.height = SCREEN_HEIGHT - TabBarHeight + Constant.smallPlayerHeight + StatusBarHeight
        contentViewH.constant = SCREEN_HEIGHT  - TabBarHeight - StatusBarHeight
    }
    
    private func setupAction() {
        // 顶部控制view点击事件
        xib_topView.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                if btn.tag == 10001 {
                    self.smallStyle()
                }else {
                    // 全屏播放
                    self.playerVars["playsinline"] = 0
                    self.playView.playVideo()
                }
            }
        }
        
        // 注册一个通知来接收播放通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, queue: nil) { (center) in
            
            // 随机播放
            if let randomMode = center.userInfo?["randomMode"] as? Int, randomMode == 1 {
                self.currentPlayCycleMode = 2
            }
            
            QYTools.shared.Log(log: "收到播放通知")
            
            // 1.获取当前播放列表
            // 2.获取当前播放列表中被播放标记的下标：如果没有则获取第一首并标记
            self.getPlayLists()
            
            // 3.判断当前被标记的歌曲时MV还是MP3
            let song = self.getCurrentSong()
            self.currentSouceType = self.setupCurrentSourceType(song: song)
            // 4.播放MV或者MP3
            self.playMvOrMp3(type: self.currentSouceType)
        }
    }
    // 移除通知
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func getPlayLists() {
        MPModelTools.getCurrentPlayList(tableName: Constant.CurrentPlayListTableName) { (models, cs) in
            self.model = models
            // 设置随机播放列表
            var t = models
            self.randomModel = t.randomObjects_ck()
            self.currentTrackIndex = self.getCurrentIndexInPlayLists(models: models)
        }
    }
    
    private func getCurrentIndexInPlayLists(models: [MPSongModel]) -> Int {
        var index = 0
        for i in 0..<models.count {
            if models[i].data_playingStatus == 1 {
                index = i
                break
            }
        }
        return index
    }
    
    private func getCurrentSong() -> MPSongModel {
        let temps = self.getCurrentModels()
        if currentPlayOrderMode == 1 {
            return temps[self.currentRandomIndex]
        }
        return temps[self.currentTrackIndex]
    }
    
    private func getCurrentModels() -> [MPSongModel] {
        let temps = currentPlayOrderMode == 1 ? randomModel : model
        return temps
    }
    
    private func setupCurrentSourceType(song: MPSongModel) -> Int {
        var type = 0
        if let sn = song.data_cache, sn != "", let sid = song.data_songId, sid != "" {
            type = 1
        }else {
            type = 0
        }
        return type
    }
    
    private func playMvOrMp3(type: Int) {
        self.bigStyle()
        if type == 1 {
            playMp3()
        }else {
            playMv()
        }
        updateView(type: self.currentSouceType)
    }
    
    private func playMp3() {
        // 暂停MV
        if playView != nil {
            playView.stopVideo()
        }
        playView.isHidden = true
        self.resetStreamer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction(timer:)), userInfo: nil, repeats: true)
    }
    
    private func playMv() {
        // 暂停MP3
        if streamer != nil {
            self.endPlayer()
        }
        playView.isHidden = false
        
        playView.load(withVideoId: self.getCurrentSong().data_originalId ?? "", playerVars: playerVars)
    }
    
    private func updateView(type: Int) {
        // 设置下一首播放
        let song = self.getCurrentSong()
        
        if type == 1 {
            xib_lrc.isSelected = true
            xib_title.text = song.data_songName
            xib_desc.text = song.data_singerName
        }else {
            xib_lrc.isSelected = false
            xib_title.text = song.data_title
            xib_desc.text = song.data_channelTitle
        }
        
        //设置图片
        xib_coverImage.isHidden = false
        if let img = song.data_artworkBigUrl, img != "" {
            let imgUrl = API.baseImageURL + img
            xib_coverImage.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "placeholder"))
        }
        
        self.updateNextSongName()
        
        self.updateSmallPlayView()
    }
    
    private func updateNextSongName() {
        let temps = getCurrentModels()
        
        var nextSong: MPSongModel!
        if currentPlayOrderMode == 1 {
            nextSong = temps[(currentRandomIndex+1) % temps.count]
        }else {
            nextSong = temps[(currentTrackIndex+1) % temps.count]
        }
        
        let nextType = setupCurrentSourceType(song: nextSong)
        if nextType == 1 {
            xib_nextSongName.text = nextSong.data_songName
        }else {
            xib_nextSongName.text = nextSong.data_title
        }
    }
    
    /// 获取顺序播放列表下标对应歌曲在随机播放列表下面的下标
    ///
    /// - Parameter index: 顺序下标
    /// - Returns: 随机列表下标
    private func getRandomIndexByIndex(index: Int) -> Int {
        // 获取当前歌曲在随机播放列表中的下标：确保是同一首歌曲而不是同一个下标处的歌曲
        let cs = model[currentTrackIndex]
        var index = -1
        for i in 0..<self.randomModel.count {
            let item = self.randomModel[i]
            if item.data_title == cs.data_title {
                index = i
            }
        }
        return index
    }
    
    private func updateSmallPlayView() {
        // 异步更新当前列表状态
        DispatchQueue.main.async {
            let song = self.getCurrentSong()
            self.xib_collect.isSelected = MPModelTools.checkSongExsistInPlayingList(song: song, tableName: MPMyFavoriteViewController.classCode)
        }
        
        // 小窗口播放数据源
        playingView.currentIndex = currentTrackIndex
        playingView.model = self.getCurrentModels()
    }
    
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        switch sender.tag {
        case 10001: // 歌词
            let pv = MPLrcView.md_viewFromXIB() as! MPLrcView
            HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
            break
        case 10002: // 上一曲
            self.mvPrev()
            break
        case 10003: // 暂停/播放
            playDidClicked()
            break
        case 10004: // 下一曲
            self.mvNext()
            break
        case 10005: // 播放模式：列表循环/单曲循环
            currentPlayCycleMode = (currentPlayCycleMode + 1) % 2
            //
            if xib_orderMode.isSelected {
                currentPlayOrderMode = 1
            }else {
                currentPlayOrderMode = 0
            }
            break
        case 10006: // 随机播放
            sender.isSelected = !sender.isSelected
            currentPlayOrderMode = sender.isSelected ? 1 : 0
            currentPlayCycleMode = sender.isSelected ? 2 : 0
            break
        case 10007: // 收藏
            // 添加到我的最爱列表
            let song = self.getCurrentSong()
            if !MPModelTools.checkSongExsistInPlayingList(song: song, tableName: MPMyFavoriteViewController.classCode) {
                // 标记为收藏状态：喜爱列表、当前列表
                song.data_collectStatus = 1
                MPModelTools.saveSongToTable(song: song, tableName: MPMyFavoriteViewController.classCode)
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
            pv.sourceType = self.currentSouceType
            HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
            pv.updateRelateSongsBlock = {(type) in
                if type == 0 {
                    pv.model = self.model
                }else if type == 1 {
                    let song = self.getCurrentSong()
                    let id: String = (self.currentSouceType == 1 ? song.data_songId : song.data_originalId) ?? ""
                    MPModelTools.getRelatedSongsModel(id: id, tableName: "", finished: { (model) in
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
    
    private func mvPrev() {
        if currentPlayOrderMode == 1 {
            let temp = currentRandomIndex == 0 ? model.count : currentRandomIndex
            currentRandomIndex = (temp-1) % model.count
        }else {
            let temp = currentTrackIndex == 0 ? model.count : currentTrackIndex
            currentTrackIndex = (temp-1) % model.count
        }
        let song = self.getCurrentSong()
        self.currentSouceType = setupCurrentSourceType(song: song)
        playMvOrMp3(type: self.currentSouceType)
        
    }
    
    private func playDidClicked() {
        if currentSouceType == 0 {
            if playView.playerState() == YTPlayerState.playing {
                playView.pauseVideo()
            }else {
                playView.playVideo()
            }
        }else {
            self.actionPlayPause()
        }
    }
    
    private func mvNext() {
        if currentPlayOrderMode == 1 {
            currentRandomIndex = (currentRandomIndex + 1) % model.count
        }else {
            currentTrackIndex = (currentTrackIndex + 1) % model.count
        }
        let song = self.getCurrentSong()
        self.currentSouceType = setupCurrentSourceType(song: song)
        playMvOrMp3(type: self.currentSouceType)
    }
    
    /// 状态开始播放
    private func startPlaying() {
        xib_play.isSelected = true
        self.playingStatusAction()
    }
    /// 状态结束播放
    private func endPlaying() {
        xib_play.isSelected = false
        if currentPlayCycleMode == 1 {  // 单曲循环
            let song = self.getCurrentSong()
            if let csID = song.data_originalId {
                if currentSouceType == 0 {
                    self.playView.load(withVideoId: csID, playerVars: playerVars)
                }else {
                    self.resetStreamer()
                }
            }
        }else {
            self.mvNext()
        }
    }
    
}
// MARK: - 歌曲控制相关操作
extension MPPlayingBigView_new {
    /// 添加歌曲到歌单
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
            if let tn = songList.data_title {
                let song = self.getCurrentSong()
                if !MPModelTools.checkSongExsistInSongList(song: song, songList: songList) {
                    MPModelTools.saveSongToTable(song: song, tableName: tn)
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
    
    /// 扩展功能列表
    func extensionTools() {
        let pv = MPSongExtensionToolsView.md_viewFromXIB() as! MPSongExtensionToolsView
        self.moreView = pv
        pv.plistName = "extensionTools"
        pv.delegate = self
        pv.title = (currentSouceType == 0 ? self.getCurrentSong().data_title : self.getCurrentSong().data_songName) ?? ""
        
        pv.isShowMvOrMp3 = currentSouceType == 1 ? true : false
        
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
    }
}

// MARK: - MPSongToolsViewDelegate
extension MPPlayingBigView_new: MPSongToolsViewDelegate {
    
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
        // 判断当前是MV还是MP3
        if SourceType == 0 {
            currentSouceType = 1
        }else {
            currentSouceType = 0
        }
        self.playMvOrMp3(type: self.currentSouceType)
    }
    
    func songInfo() {
        QYTools.shared.Log(log: "歌曲信息")
        // 关闭弹框
        self.moreView?.removeFromWindow()
        let pv = MPSongInfoView.md_viewFromXIB() as! MPSongInfoView
        pv.updateView(model: self.getCurrentSong())
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
        
        pv.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                
                // 关闭弹框
                self.moreView?.removeFromWindow()
                // 缩小当前的View
                self.smallStyle()
                
                pv.removeFromWindow()
                
                if btn.tag == 10001 {    // 协议
                    let vc = MDWebViewController()
                    vc.title = NSLocalizedString("《著作权许可协议》", comment: "")
                    vc.url = API.Copyright
                    HFAppEngine.shared.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
                }else {     // 投诉：跳转到一个H5界面
                    let vc = MDWebViewController()
                    vc.title = NSLocalizedString("投诉", comment: "")
                    vc.url = API.Complaint
                    HFAppEngine.shared.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

// MARK: - 歌曲控制相关操作
extension MPPlayingBigView_new {
    
    /// 滑动滑竿控制播放
    ///
    /// - Parameter sender: 滑竿
    @objc func sliderDidChange(sender: UISlider) {
        if currentSouceType == 0 {
            let value = sender.value
            let progress = Float(playView.duration()) * value
            playView.seek(toSeconds: progress, allowSeekAhead: true)
            //如果当前时暂停状态，则继续播放
            if playView.playerState() == .paused {
                playView.playVideo()
            }
        }else {
            //播放器定位到对应的位置
            self.actionSliderProgress()
        }
    }
    
    /// 设置当前播放模式
    private func setCycleModeImage() {
        switch currentPlayCycleMode {
        case 0:
            xib_cycleMode.setImage(UIImage(named: "icon_play_order-1"), for: .normal)
            currentPlayOrderMode = 0
            break
        case 1:
            xib_cycleMode.setImage(UIImage(named: "icon_play_single"), for: .normal)
            currentPlayOrderMode = 0
            break
        case 2:
            xib_cycleMode.setImage(UIImage(named: "icon_play_order_off"), for: .normal)
            currentPlayOrderMode = 1
            break
        default:
            break
        }
    }
    
    private func playingStatusAction() {
        // 更新结束时间
        let endtime: TimeInterval = currentSouceType == 1 ? self.streamer.duration : self.playView.duration() ?? 0.0
        xib_endTime.text = "\(endtime)".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
        
        // 异步添加
        DispatchQueue.global().async {
            // 添加到最近播放列表
            if !MPModelTools.checkSongExsistInPlayingList(song: self.getCurrentSong(), tableName: "RecentlyPlay") {
                MPModelTools.saveSongToTable(song: self.getCurrentSong(), tableName: "RecentlyPlay")
            }
        }
        
    }
}

// MARK: - YTPlayerViewDelegate
extension MPPlayingBigView_new: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        // 更新播放进度
        xib_slider.value = playTime / Float(playerView.duration())
        xib_startTime.text = "\(playTime)".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .playing:
            self.startPlaying()
            break
        case .ended:
            self.endPlaying()
            break
        default:
            xib_play.isSelected = false
            break
        }
        
        // 更新小窗播放按钮状态
        playingView.currentStatus = xib_play.isSelected
    }
    
}
// MARK: - MPPlayingViewDelegate：小窗控制事件回调
extension MPPlayingBigView_new: MPPlayingViewDelegate {
    /// 上一首
    ///
    /// - Parameters:
    ///   - view: -
    ///   - index: 下标
    func playingView(pre view: MPPlayingView, index: Int) {
        self.playByIndex(index: index)
    }
    /// 下一首
    ///
    /// - Parameters:
    ///   - view: -
    ///   - index: 下标
    func playingView(next view: MPPlayingView, index: Int) {
        self.playByIndex(index: index)
    }
    
    private func playByIndex(index: Int) {
        currentTrackIndex = index
        self.currentSouceType = setupCurrentSourceType(song: self.getCurrentSong())
        playMvOrMp3(type: self.currentSouceType)
        
        self.smallStyle()
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
}

// MARK: - 扩展大小窗口切换时样式切换
extension MPPlayingBigView_new {
    
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
        
        // 发送一个通知
        NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_ChangeTableViewBottom), object: nil)
        
    }
    
    func bigStyle() {
        playBgView.addSubview(playView)
        playView.snp.makeConstraints { (make) in
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

// MARK: - 播放MP3
extension MPPlayingBigView_new {
    
    private func endPlayer() {
        timer.invalidate()
        streamer.stop()
        self.cancelStreamer()
        //
        xib_play.isSelected = false
        xib_slider.value = 0
        xib_startTime.text = "00:00"
        xib_endTime.text = "00:00"
    }

    private func cancelStreamer() {
        if streamer != nil {
            streamer.pause()
            streamer.removeObserver(self, forKeyPath: "status")
            streamer.removeObserver(self, forKeyPath: "duration")
            streamer.removeObserver(self, forKeyPath: "bufferingRatio")
            streamer = nil
        }
    }
    
    private func resetStreamer() {
        self.cancelStreamer()
        if model.count == 0 {
            // 重置UI
        }else {
            let music = self.getCurrentSong()
            
            if music.data_audioFileURL == nil {
                music.data_audioFileURL = URL(string: music.data_cache ?? Constant.MP3Test)
            }
            
            streamer = DOUAudioStreamer(audioFile: music)
            streamer.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            streamer.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
            streamer.addObserver(self, forKeyPath: "bufferingRatio", options: .new, context: nil)
            
            streamer.play()
            
            self.updateBufferingStatus()
            self.setupHintForStreamer()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            self.perform(#selector(self.updateStatus), on: .main, with: nil, waitUntilDone: false)
        }else if keyPath == "duration" {
            self.perform(#selector(self.timerAction), on: .main, with: nil, waitUntilDone: false)
        }else if keyPath == "bufferingRatio" {
            self.perform(#selector(self.updateBufferingStatus), on: .main, with: nil, waitUntilDone: false)
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @objc private func updateBufferingStatus() {
        // 更新UI
        if streamer.bufferingRatio >= 1.0 {
            QYTools.shared.Log(log: "sha256: \(streamer.sha256)")
        }
    }
    
    private func setupHintForStreamer() {
        var nextIndex = currentTrackIndex + 1
        if nextIndex >= model.count - 1 {
            nextIndex = 0
        }
        DOUAudioStreamer.setHintWith(self.getCurrentModels()[nextIndex])
    }
    
    @objc private func updateStatus() {
        switch streamer.status {
        case .playing:
            self.startPlaying()
            break
//        case .paused:
//            break
//        case .idle:
//            break
        case .finished:
            self.endPlaying()
            break
//        case .buffering:
//            break
//        case .error:
//            break
        default:
            xib_play.isSelected = false
            break
        }
        
        // 更新小窗播放按钮状态
        playingView.currentStatus = xib_play.isSelected
    }

    @objc private func timerAction(timer: Timer) {
        guard streamer != nil else {
            return
        }
        if streamer.duration == 0.0 {
            xib_slider.setValue(0.0, animated: false)
        }else {
            xib_slider.setValue(Float(streamer.currentTime / streamer.duration), animated: true)
            // 更新时间
            let st = "\(streamer.currentTime)".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
            xib_startTime.text = st
            let et = "\(streamer.duration)".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
            xib_endTime.text = et
        }
    }
    
    private func actionPlayPause() {
        if streamer.status == .paused || streamer.status == .idle {
            streamer.play()
        }else {
            streamer.pause()
        }
    }
    
    private func actionPrev() {
        let temp = currentTrackIndex == 0 ? model.count : currentTrackIndex
        currentTrackIndex = (temp-1) % model.count
//        if --currentTrackIndex <= 0 {
//            currentTrackIndex = model.count - 1
//        }
        self.resetStreamer()
    }
    
    private func actionNext() {
        currentTrackIndex = (currentTrackIndex + 1) % model.count
//        if ++currentTrackIndex >= model.count - 1 {
//            currentTrackIndex = 0
//        }
        self.resetStreamer()
    }
    
    private func actionStop() {
        streamer.stop()
    }
    
    private func actionSliderProgress() {
        streamer.currentTime = streamer.duration * Double(xib_slider.value)
    }
    
    private func actionSliderVolume(sender: UISlider) {
        DOUAudioStreamer.setVolume(Double(sender.value))
    }
    
}

