//
//  MPPlayingBigView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/1.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import DOUAudioStreamer
import Cache

private struct Constant {
    static let smallPlayerWidth = SCREEN_HEIGHT * (90/(IPHONEX ? 812 : 667))
    static let sbReduceHeight = SCREEN_WIDTH * (58/375)
    static let smallPlayerHeight = SCREEN_WIDTH * (48/375)
    
    static let MP3Test = "http://cache.musicfm.co/music/mp3/99024167248247705390676698909371.mp3"
    
    static let MP3URL: URL = URL(string: MP3Test)!
    
    static let CurrentPlayListTableName = "CurrentPlayList"
}

class MPPlayingBigView: BaseView {
    
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
    /// 歌词模型
    var lyricsModel: MPLyricsModel! {
        didSet {
            lrcView?.model = lyricsModel
        }
    }
    var lrcView: MPLrcView?
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
//            self.smallStyle()
        }
    }
    @IBOutlet weak var xib_controlBgView: UIView!
    @IBOutlet weak var xib_nextBgView: UIView!
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
    @IBOutlet weak var xib_nextPlay: UILabel!
    @IBOutlet weak var xib_nextSongName: UILabel!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    @IBOutlet weak var xib_lrc: UIButton! {
        didSet {
            // 判断是否开启歌词权限
            if self.currentSouceType == 1, BOOL_OPEN_MP3, BOOL_OPEN_LYRICS {
                xib_lrc.isHidden = false
            }else {
                xib_lrc.isHidden = true
            }
            xib_lrc.touchAreaInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        }
    }
    @IBOutlet weak var xib_slider: UISlider! {
        didSet {
            xib_slider.value = 0
            xib_slider.addTarget(self, action: #selector(sliderDidChange(sender:)), for: .valueChanged)
        }
    }
    /// 播放区域背景View
    @IBOutlet weak var playBgView: UIView!
    @IBOutlet weak var xib_bgImage: UIButton!
    @IBOutlet weak var xib_coverImage: UIImageView! {
        didSet {
            xib_coverImage.md_cornerRadius = 2
            xib_coverImage.contentMode = .scaleAspectFit
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
    
    @IBOutlet weak var xib_fullScreen: UIButton!
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
    private var playerVars: [String : Any] = [ "showinfo": "0", "modestbranding" : "1", "playsinline": "1", "controls": "0", "autohide": "1", "enablejsapi": "1"]
    
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
    
    var needPlay: Int = -1
    
    /// 记录用户是否通过拖拽进度条播放
    var userDragSlider: Bool = false
    
    // MARK: - 重新整理逻辑开始
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
        setupAction()
    }
    
    private func setupStyle() {
        xib_lrc.setTitle(NSLocalizedString("歌词", comment: "").decryptString(), for: .normal)
        xib_nextPlay.text = NSLocalizedString("下一首播放", comment: "").decryptString()
        
        playView = self.ybPlayView
        
        playView.isHidden = true
        xib_coverImage.isHidden = true
        
        if !(SCREEN_HEIGHT > 667) {
            topViewH.constant = defaultTopViewH - Constant.sbReduceHeight
            self.height = SCREEN_HEIGHT + Constant.smallPlayerHeight + StatusBarHeight
        }else {
            if IPHONEX {
                self.height = SCREEN_HEIGHT - TabBarHeight + Constant.smallPlayerHeight + StatusBarHeight
            }else {
                self.height = SCREEN_HEIGHT + Constant.smallPlayerHeight + StatusBarHeight
            }
        }
        
        playerViewTop.constant = StatusBarHeight
        contentViewH.constant = SCREEN_HEIGHT - TabBarHeight - StatusBarHeight
        
//        xib_fullScreen.isHidden = true
    }
    
    private func setupAction() {
        // 顶部控制view点击事件
        xib_topView.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                if btn.tag == 10001 {
                    self.smallStyle()
                }else {
                    // 全屏播放
//                    self.playerVars["playsinline"] = 0
//                    self.playView.playVideo()
//                    isAllowAutorotate = true
//                    self.fullscreen()
//                    let orientation = UIDeviceOrientation.landscapeRight.rawValue
//                    UIDevice.current.setValue(0, forKey: "orientation")
//                    UIDevice.current.setValue(orientation, forKey: "orientation")
                    self.fullScreenStyle()
                }
            }
        }
        
        // 注册一个通知来接收播放通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, queue: nil) { (center) in
            
            // 随机播放
            if let randomMode = center.userInfo?["randomMode"] as? Int, randomMode == 1 {
                self.currentPlayCycleMode = 2
            }
            
            // 随机播放
            if let needPlay = center.userInfo?["needPlay"] as? Int {
                self.needPlay = needPlay
            }else {
                self.needPlay = -1
            }
            
            QYTools.shared.Log(log: "收到播放通知".decryptLog())
            
            // 1.获取当前播放列表
            // 2.获取当前播放列表中被播放标记的下标：如果没有则获取第一首并标记
            self.getPlayLists()
            
        }
    }
    var defaultPlayFrame: CGRect = .zero
    private func fullscreen() {
        playView.setPlaybackQuality(YTPlaybackQuality.large)
//        self.defaultPlayFrame = playView.frame
//        playView.frame = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
    }
    
    // 移除通知
    deinit {
        isAllowAutorotate = false
        NotificationCenter.default.removeObserver(self)
        
        resignFirstResponder()
    }
    
    private func getPlayLists() {
        MPModelTools.getCurrentPlayList(tableName: Constant.CurrentPlayListTableName) { (models, cs) in
            self.model = models
            // 设置随机播放列表
            var t = models
            self.randomModel = t.randomObjects_ck()
            self.currentTrackIndex = self.getCurrentIndexInPlayLists(models: models)
            
            // 3.判断当前被标记的歌曲时MV还是MP3
            // 重置当前下标
            self.currentRandomIndex = self.getRandomIndexByIndex(index: self.currentTrackIndex)
            let song = self.getCurrentSong()
            self.currentSouceType = self.setupCurrentSourceType(song: song)
            // 4.播放MV或者MP3
            self.playMvOrMp3(type: self.currentSouceType)
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
        ressetUI()
        
        Analytics.logEvent("play_start", parameters: nil)
        
        self.bigStyle()
        
        self.playingStatusAction()
        
        if needPlay == -1 {
            if type == 1 {
                playMp3()
            }else {
//                DispatchQueue.global().async {
//                    self.playMv()
//                }
                self.playMv()
            }
        }
        updateView(type: self.currentSouceType)
        
        DispatchQueue.global().async {
            self.setLockScreenDisplay()
        }
    }
    
    private func loadingAnimate() {
        
    }
    
    private func ressetUI() {
        // 重置参数
        xib_play.isSelected = true
        xib_startTime.text = "00:00"
        xib_endTime.text = "00:00"
        xib_slider.value = 0
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
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 暂停MP3
        if streamer != nil {
            self.endPlayer()
        }
        playView.isHidden = false
        
        playView.load(withVideoId: self.getCurrentSong().data_originalId ?? "", playerVars: playerVars)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        debugPrint("\(#function)代码执行时长：%f 毫秒", (endTime - startTime)*1000)
    }
    
    private func updateView(type: Int) {
        // 设置下一首播放
        let song = self.getCurrentSong()
        
        if type == 1 {
//            xib_lrc.isSelected = true
            xib_title.text = song.data_songName
            xib_desc.text = song.data_singerName
            
            // 判断是否开启下载权限
            if BOOL_OPEN_MP3, BOOL_OPEN_MUSIC_DL {
                xib_collect.setImage(#imageLiteral(resourceName: "icon_lock_screen"), for: .normal)
                xib_collect.setImage(#imageLiteral(resourceName: "icon_lock_screen(1)"), for: .selected)
            }else {
                xib_collect.setImage(#imageLiteral(resourceName: "icon_collect_normal"), for: .normal)
                xib_collect.setImage(#imageLiteral(resourceName: "icon_collect_selected"), for: .selected)
            }
        }else {
//            xib_lrc.isSelected = false
            xib_title.text = song.data_title
            xib_desc.text = song.data_channelTitle
            
            xib_collect.setImage(#imageLiteral(resourceName: "icon_collect_normal"), for: .normal)
            xib_collect.setImage(#imageLiteral(resourceName: "icon_collect_selected"), for: .selected)
        }
        
        //设置图片
        xib_coverImage.isHidden = false
        if let img = song.data_artworkBigUrl, img != "" {
            let imgUrl = API.baseImageURL + img
            xib_coverImage.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "placeholder"), options: nil, progressBlock: nil) { (rs) in
                // 设置一张高斯模糊背景
                QYTools.shared.Log(log: rs.debugDescription)
                do {
                    let image = try rs.get().image.byBlurLight()
//                    self.xib_coverImage.backgroundColor = UIColor.init(patternImage: image!)
                    self.xib_bgImage.setBackgroundImage(image, for: .normal)
                }catch {
                    QYTools.shared.Log(log: error.localizedDescription)
                }
                
            }
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
        xib_collect.isSelected = false
        
        // 异步更新当前列表状态
        DispatchQueue.main.async {
            let song = self.getCurrentSong()
            
            if self.currentSouceType == 1, BOOL_OPEN_MP3, BOOL_OPEN_MUSIC_DL {
                if MPModelTools.checkSongExsistInDownloadList(song: song) {
                    self.xib_collect.isSelected = true
                }
            }else {
                if MPModelTools.checkSongExsistInPlayingList(song: song, tableName: MPMyFavoriteViewController.classCode) {
                    self.xib_collect.isSelected = true
                }
            }
            
            self.xib_lrc.isSelected = false
            self.xib_lrc.isEnabled = false
            if self.currentSouceType == 1, let name = song.data_songName, let sid = song.data_songId {
                // 获取歌词信息
                DiscoverCent?.requestSearchLyrics(name: name, songId: sid, complete: { (isSucceed, model, msg) in
                    switch isSucceed {
                    case true:
                        // 将歌词赋值给自定义属性
                        self.lyricsModel = model
                        if let lrcM = model, let lrc = lrcM.data_lyrics {
                            self.xib_lrc.isSelected = true
                            self.xib_lrc.isEnabled = true
                        }
                        break
                    case false:
                        SVProgressHUD.showError(withStatus: msg)
                        break
                    }
                })
            }
        }
        
        // 小窗口播放数据源
        playingView.currentIndex = self.currentPlayOrderMode == 1 ? currentRandomIndex : currentTrackIndex
        playingView.model = self.getCurrentModels()
    }
    
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        switch sender.tag {
        case 10001: // 歌词
            let pv = MPLrcView.md_viewFromXIB() as! MPLrcView
            self.lrcView = pv
            // 设置当前播放时间
            if streamer != nil {
                 self.lyricsModel.data_currentTime = streamer.currentTime
                self.lyricsModel.data_currentStatus = streamer.status == .playing ? 1 : 0
            }
            pv.model = self.lyricsModel
            
            pv.seekToTimeBlock = {(time) in
                if self.streamer != nil {
                    self.streamer.currentTime = time
                }
            }
            
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
            if currentPlayCycleMode == 2 {
                currentPlayCycleMode = 0
            }else {
                currentPlayCycleMode = (currentPlayCycleMode + 1) % 2
            }
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
            if currentSouceType == 1, BOOL_OPEN_MP3, BOOL_OPEN_MUSIC_DL {
                download()
            }else {
                collection()
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
                    SVProgressHUD.show()
                    pv.model = [MPSongModel]()
                    let song = self.getCurrentSong()
                    let id: String = (self.currentSouceType == 1 ? song.data_songId : song.data_originalId) ?? ""
                    MPModelTools.getRelatedSongsModel(id: id, tableName: "", finished: { (model) in
                        SVProgressHUD.dismiss()
                        if let m = model {
                            pv.model = m
                        }
                    })
                }
            }
            
            pv.playByIndexBlock = {(index) in
                // 重置状态
                self.needPlay = -1
                self.playByIndex(index: index)
                self.bigStyle()
            }
            
            break
        default:
            break
        }
    }
    
    /// 收藏
    private func collection() {
        // 添加到我的最爱列表
        let song = self.getCurrentSong()
        if !MPModelTools.checkSongExsistInPlayingList(song: song, tableName: MPMyFavoriteViewController.classCode) {
            // 标记为收藏状态：喜爱列表、当前列表
            song.data_collectStatus = 1
            MPModelTools.saveSongToTable(song: song, tableName: MPMyFavoriteViewController.classCode)
            // 设置为收藏状态
            xib_collect.isSelected = true
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("收藏成功", comment: "").decryptString())
        }else {
            MPModelTools.deleteSongInTable(tableName: MPMyFavoriteViewController.classCode, songs: [song]) {
                // 标记为收藏状态：喜爱列表、当前列表
                song.data_collectStatus = 0
                // 设置为收藏状态
                self.xib_collect.isSelected = false
                // 取消收藏
//                SVProgressHUD.showInfo(withStatus: NSLocalizedString("取消收藏", comment: ""))
            }
            // 更新上传模型
            MPModelTools.updateCloudListModel(type: 2)
        }
    }
    
    /// 下载
    private func download() {
        let song = self.getCurrentSong()
        
//        if (song.data_isDownload) {
//            let dModel = GKDownloadModel()
//            dModel.fileID = song.data_songId
//
//            GKDownloadManager.sharedInstance()?.removeDownloadArr([dModel])
//        }else {
//            MPDownloadTools.downloadMusicWithSongId(model: song)
//            GKDownloadManager.sharedInstance()?.delegate = self
//        }
        
        if !(song.data_isDownload) {
            MPDownloadTools.downloadMusicWithSongId(model: song)
            GKDownloadManager.sharedInstance()?.delegate = self
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
        // 重置状态
        needPlay = -1
        
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
        
        Analytics.logEvent("play_success", parameters: nil)
        
        xib_play.isSelected = true
        // 更新结束时间
        let endtime: TimeInterval = currentSouceType == 1 ? self.streamer.duration : self.playView.duration()
        xib_endTime.text = "\(endtime)".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
        
        // 歌词是否显示显示则播放
        // 设置当前播放时间
        if streamer != nil, self.lyricsModel != nil {
            self.lyricsModel.data_currentTime = streamer.currentTime
            self.lyricsModel.data_currentStatus = streamer.status == .playing ? 1 : 0
            self.lrcView?.model = self.lyricsModel
            
            Analytics.logEvent("play_success_mp3", parameters: nil)
        }
        
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
        
        // 记录用户播放的MP3数量
        if userDragSlider == false {
            // 歌曲数量+1
            USER_PLAY_SONG_COUNT += 1
            // 判断是否可以激活MP3
            if promissionForMP3() {
                // 设置全局开关：激活PM3
                BOOL_OPEN_MP3 = true
                // 用户第一次激活播放mp3功能
                Analytics.logEvent("allow_mp3_activated", parameters: nil)
                
                UserDefaults.standard.set(true, forKey: "mp3_activated")
            }
        }
        
    }
    
}
// MARK: - 歌曲控制相关操作
extension MPPlayingBigView {
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
                            
                            // 更新上传模型
                            MPModelTools.updateCloudListModel(type: 4)
                        }else {
                            SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌单已存在", comment: "").decryptString())
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
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已经收录到歌单了", comment: "").decryptString())
                    // 更新当前歌单图片及数量：+1
                    MPModelTools.updateCountForSongList(songList: songList, finished: {
                        lv.removeFromWindow()
                    })
                    
                    // 更新上传模型
                    MPModelTools.updateCloudListModel(type: 4)
                }else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已经收录到歌单了", comment: "").decryptString())
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
        
        let song = getCurrentSong()
        if let sn = song.data_cache, sn != "", let sid = song.data_songId, sid != "", let oid = song.data_originalId, oid != "" {
            pv.isShowMvOrMp3 = true
        }else {
            pv.isShowMvOrMp3 = false
        }
        
        pv.updateTableViewHeight()
        
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
    }
}

// MARK: - MPSongToolsViewDelegate
extension MPPlayingBigView: MPSongToolsViewDelegate {
    
    func timeOff() {
        QYTools.shared.Log(log: "定时关闭".decryptLog())
        // 关闭弹框
        self.moreView?.removeFromWindow()
        // 缩小当前的View
        self.smallStyle()
        let vc = MPTimeOffViewController()
        HFAppEngine.shared.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func playVideo() {
        QYTools.shared.Log(log: "播放视频".decryptLog())
        // 关闭弹框
        self.moreView?.removeFromWindow()
        // 判断当前是MV还是MP3
        if SourceType == 0 {
            currentSouceType = 1
        }else {
            currentSouceType = 0
        }
        self.playMvOrMp3(type: self.currentSouceType)
    }
    
    func songInfo() {
        QYTools.shared.Log(log: "歌曲信息".decryptLog())
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
                    vc.title = NSLocalizedString("《著作权许可协议》", comment: "").decryptString()
                    vc.url = API.Copyright
                    HFAppEngine.shared.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
                }else {     // 投诉：跳转到一个H5界面
                    let vc = MDWebViewController()
                    vc.title = NSLocalizedString("投诉", comment: "").decryptString()
                    vc.url = API.Complaint
                    HFAppEngine.shared.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

// MARK: - 歌曲控制相关操作
extension MPPlayingBigView {
    
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
            userDragSlider = true
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
        // 异步添加
        DispatchQueue.init(label: "updateRecentlyList").async {
            // 添加到最近播放列表
            if !MPModelTools.checkSongExsistInPlayingList(song: self.getCurrentSong(), tableName: "RecentlyPlay") {
                MPModelTools.saveSongToTable(song: self.getCurrentSong(), tableName: "RecentlyPlay")
                NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_RefreshRecentlyList), object: nil)
            }else {
                // 将已存在的歌曲提前
                MPModelTools.deleteSongInTable(tableName: "RecentlyPlay", songs: [self.getCurrentSong()], finished: {
                    MPModelTools.saveSongToTable(song: self.getCurrentSong(), tableName: "RecentlyPlay")
                    NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_RefreshRecentlyList), object: nil)
                })
            }
            // 更新上传模型
            MPModelTools.updateCloudListModel(type: 1)
        }
    }
}

// MARK: - YTPlayerViewDelegate
extension MPPlayingBigView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
        UIView.animate(withDuration: 0.25) {
            self.playBgView.bringSubviewToFront(self.playView)
        }
        
        Analytics.logEvent("play_success_yt", parameters: nil)
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        // 更新播放进度
        xib_slider.value = playTime / Float(playerView.duration())
        xib_startTime.text = "\(playTime)".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .buffering:
            xib_play.isSelected = true
            break
        case .playing:
            self.startPlaying()
            break
        case .ended:
            self.endPlaying()
            break
        case .unstarted, .unknown:
            QYTools.shared.Log(log: "播放失败")
            self.mvNext()
            break
        default:
            xib_play.isSelected = false
            Analytics.logEvent("play_failed", parameters: nil)
            Analytics.logEvent("play_failed_yt", parameters: nil)
            break
        }
        
        // 更新小窗播放按钮状态
        playingView.currentStatus = xib_play.isSelected
    }
    
}
// MARK: - MPPlayingViewDelegate：小窗控制事件回调
extension MPPlayingBigView: MPPlayingViewDelegate {
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
        if self.currentPlayOrderMode == 1 {
            self.currentRandomIndex = index
        }else {
            self.currentTrackIndex = index
        }
        self.currentSouceType = setupCurrentSourceType(song: self.getCurrentSong())
        playMvOrMp3(type: self.currentSouceType)
        
        self.smallStyle()
    }
    
    func playingView(toDetail view: MPPlayingView) {
        self.bigStyle()
    }
    
    func playingView(download view: MPPlayingView) {
        QYTools.shared.Log(log: "下载".decryptLog())
        if currentSouceType == 1, BOOL_OPEN_MP3, BOOL_OPEN_MUSIC_DL {
            self.download()
        }else {
            self.collection()
        }
    }
    
    func playingView(play view: MPPlayingView, status: Bool) {
        QYTools.shared.Log(log: "播放".decryptLog())
        playDidClicked()
    }
}

// MARK: - 扩展大小窗口切换时样式切换
extension MPPlayingBigView {
    
    func hiddenStyle() {
        self.top = window!.frame.height
    }
    
    func smallStyle() {
        self.top = SCREEN_HEIGHT - TabBarHeight - Constant.smallPlayerHeight
        xib_playingView.insertSubview(playView, at: 0)
        playView.snp.makeConstraints { (make) in
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
        
        if playView.playerState() != .playing, playView.playerState() != .paused {
            playBgView.sendSubviewToBack(playView)
        }
    }
    
    func fullScreenStyle() {
//        playView.snp.remakeConstraints { (make) in
//            make.left.right.top.bottom.equalTo(appDelegate.window!)
//        }
//        xib_controlBgView.isHidden = true
//        xib_nextBgView.isHidden = true
        
//        playView.webView?.delegate = self
        
//        let js = "document.getElementById('player').style = 'background-color: red'"
//        QYTools.shared.Log(log: js)
//        playView.webView?.stringByEvaluatingJavaScript(from: js)
        
        self.playView.subviews.first?.bl_landscape(animated: true, animations: nil) {
            QYTools.shared.Log(log: "完成")
            let view = UIButton(title: "Done", backImage: nil, color: UIColor.white, image: "", size: 15)
            view.backgroundColor = UIColor.clear
            view.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
//            self.playView.subviews.first?.superview?.addSubview(view)
//            self.playView.subviews.first?.superview?.bringSubviewToFront(view)
            appDelegate.window?.addSubview(view)
//            appDelegate.window?.bringSubviewToFront(view)
            view.add_BtnClickHandler({ (tag) in
                self.playView.subviews.first?.bl_protrait(animated: true, animations: nil, complete: {
                    QYTools.shared.Log(log: "完成")
                    view.removeFromSuperview()
                })
            })
            
            self.playView.setPlaybackQuality(YTPlaybackQuality.auto)
        }
    }
}

extension MPPlayingBigView: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let js = "if(document.getElementsByTagName('player').length>0)document.getElementsByTagName('player').length;"
        let rs: NSString = webView.stringByEvaluatingJavaScript(from: js)! as NSString
        if (rs.length & rs.integerValue) != 0 {
            self.bl_landscape(animated: true, animations: nil) {
                QYTools.shared.Log(log: "完成")
            }
        }
    }
}

// MARK: - 播放MP3
extension MPPlayingBigView {
    
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
            // 为空时会奔溃
            // music.audioFileURL()
            streamer = DOUAudioStreamer(audioFile: music) 
            streamer.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            streamer.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
            streamer.addObserver(self, forKeyPath: "bufferingRatio", options: .new, context: nil)
            
            streamer.play()
            
            self.updateBufferingStatus()
            self.setupHintForStreamer()
            
            QYTools.shared.Log(log: "缓冲路径：\(streamer.cachedPath)")
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
            // 只有MP3状态下才会缓存
            if BOOL_OPEN_MP3 {
                addCache()
            }
        }
    }
    
    private func addCache() {
        // 缓存完成记录到列表中
        let cacheModel = self.getCurrentSong()
        
        // 自己缓存音乐数据
        MPCacheTools.cacheMusic(path: streamer.cachedPath)
        cacheModel.data_cachePath = MPCacheTools.cachePath(path: streamer.cachedPath)
        
        // 保存到缓存数据表
        if !MPModelTools.checkSongExsistInPlayingList(song: cacheModel, tableName: "CacheList") {
            MPModelTools.saveSongToTable(song: cacheModel, tableName: "CacheList")
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
        case .buffering:
            xib_play.isSelected = true
            break
//        case .error:
//            break
        default:
            xib_play.isSelected = false
            Analytics.logEvent("play_failed", parameters: nil)
            Analytics.logEvent("play_failed_mp3", parameters: nil)
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

// MARK: - 用户权限控制
import FirebaseRemoteConfig
import FirebaseAnalytics

extension MPPlayingBigView {
    
    /// 判断用户是否达到开启MP3权限
    ///
    /// - Returns: -
    func promissionForMP3() -> Bool {
        
        // 判断是否可以有激活权限
        if STATUS_OF_DEVICE_AUTH != "accept" {
            return false
        }
        
        //        - 1.用户开机时间：超过3600s
        let uptime = UIDevice.getLaunchSystemTime()
        if uptime < 3600 {
            return false
        }
        //        - 2.用户安装应用时间：
        let installTime = UIDevice.getAppInstallTime()
        let fsAppInstallSeconds = RemoteConfig.remoteConfig().configValue(forKey: "float_min_act_hours_as_old_user").numberValue?.doubleValue ?? 0
        if installTime < fsAppInstallSeconds {
            return false
        }
        //        - 3.用户播放歌曲数量：
        let fsCompleteSongsCount = RemoteConfig.remoteConfig().configValue(forKey: "int_min_completed_songs_as_old_user").numberValue?.intValue ?? 0
        if USER_PLAY_SONG_COUNT < fsCompleteSongsCount {
            return false
        }
        
//        return (true && BOOL_OPEN_MP3_FS)
        return true
    }
}

// MARK: - 下载相关代理事件
extension MPPlayingBigView: GKDownloadManagerDelegate {
    func gkDownloadManager(_ downloadManager: GKDownloadManager!, downloadModel: GKDownloadModel!, stateChanged state: GKDownloadManagerState) {
        if state == .finished {
            xib_collect.isSelected = true
        }else if state == .failed {
            QYTools.shared.Log(log: "下载失败".decryptLog())
        }
    }
}

//    MARK: 设置锁屏信息显示
extension MPPlayingBigView {
    
    func setLockScreenDisplay() {
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        ressetRemoteControl()
        
        let model = self.getCurrentSong()
        
        var info = Dictionary<String, Any>()
        info[MPMediaItemPropertyTitle] = model.data_title//歌名
        info[MPMediaItemPropertyArtist] = model.data_channelTitle//作者
        //        [info setObject:self.model.filename forKey:MPMediaItemPropertyAlbumTitle];//专辑名
        info[MPMediaItemPropertyAlbumArtist] = model.data_channelTitle//专辑作者
        do {
            if let url = URL(string: model.data_artworkUrl ?? "") {
                if let img = UIImage(data: try Data.init(contentsOf: url)) {
                    info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: img)//显示的图片
                }
            }
        }catch {
            print(error)
        }
        
        info[MPMediaItemPropertyPlaybackDuration] = model.data_durationInSeconds//总时长
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0//播放速率
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
//        MPNowPlayingInfoCenter.default().playbackState = .playing
        
        lockRemoteControl()
        // 设置后台播放：显示到系统AirPlay上显示
        playingBackground()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        debugPrint("\(#function)代码执行时长：%f 毫秒", (endTime - startTime)*1000)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
//    override func remoteControlReceived(with event: UIEvent?) {
//        NotificationCenter.default.post(name: NSNotification.Name.init("songRemoteControlNotification"), object: self, userInfo: ["eventSubtype" : event?.subtype])
//    }
    
    func lockRemoteControl() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.previousTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.mvPrev()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.nextTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.mvNext()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.playDidClicked()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.playDidClicked()
            return MPRemoteCommandHandlerStatus.success
        }
    }
    
    //    MARK: 后台播放
    func playingBackground() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.allowAirPlay)
        try? session.setActive(true)
    }
    
    func ressetRemoteControl() {
        
        becomeFirstResponder()
//        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.previousTrackCommand.removeTarget(self)
        commandCenter.nextTrackCommand.removeTarget(self)
        commandCenter.pauseCommand.removeTarget(self)
        commandCenter.playCommand.removeTarget(self)
    }
    
    /*
    /**/
    //远程控制命令中心 iOS 7.1 之后  详情看官方文档：https://developer.apple.com/documentation/mediaplayer/mpremotecommandcenter
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    //   MPFeedbackCommand对象反映了当前App所播放的反馈状态. MPRemoteCommandCenter对象提供feedback对象用于对媒体文件进行喜欢, 不喜欢, 标记的操作. 效果类似于网易云音乐锁屏时的效果
    
    //添加喜欢按钮
    MPFeedbackCommand *likeCommand = commandCenter.likeCommand;
    likeCommand.enabled = YES;
    likeCommand.localizedTitle = @"喜欢";
    [likeCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
    NSLog(@"喜欢");
    return MPRemoteCommandHandlerStatusSuccess;
    }];
    //添加不喜欢按钮，假装是“上一首”
    MPFeedbackCommand *dislikeCommand = commandCenter.dislikeCommand;
    dislikeCommand.enabled = YES;
    dislikeCommand.localizedTitle = @"上一首";
    [dislikeCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
    NSLog(@"上一首");
    return MPRemoteCommandHandlerStatusSuccess;
    }];
    //标记
    MPFeedbackCommand *bookmarkCommand = commandCenter.bookmarkCommand;
    bookmarkCommand.enabled = YES;
    bookmarkCommand.localizedTitle = @"标记";
    [bookmarkCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
    NSLog(@"标记");
    return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //    commandCenter.togglePlayPauseCommand 耳机线控的暂停/播放
    __weak typeof(self) weakSelf = self;
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
    [weakSelf.player pause];
    return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
    [weakSelf.player play];
    return MPRemoteCommandHandlerStatusSuccess;
    }];
    //    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
    //        NSLog(@"上一首");
    //        return MPRemoteCommandHandlerStatusSuccess;
    //    }];
    
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
    NSLog(@"下一首");
    return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //快进
    //    MPSkipIntervalCommand *skipBackwardIntervalCommand = commandCenter.skipForwardCommand;
    //    skipBackwardIntervalCommand.preferredIntervals = @[@(54)];
    //    skipBackwardIntervalCommand.enabled = YES;
    //    [skipBackwardIntervalCommand addTarget:self action:@selector(skipBackwardEvent:)];
    
    //在控制台拖动进度条调节进度（仿QQ音乐的效果）
    [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
    CMTime totlaTime = weakSelf.player.currentItem.duration;
    MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
    [weakSelf.player seekToTime:CMTimeMake(totlaTime.value*playbackPositionEvent.positionTime/CMTimeGetSeconds(totlaTime), totlaTime.timescale) completionHandler:^(BOOL finished) {
    }];
    return MPRemoteCommandHandlerStatusSuccess;
    }];
 */
}

