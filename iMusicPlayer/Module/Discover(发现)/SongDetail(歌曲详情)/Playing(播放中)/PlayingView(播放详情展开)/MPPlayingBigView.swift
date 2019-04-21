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

private struct Constant {
    static let smallPlayerWidth = SCREEN_HEIGHT * (90/(IPHONEX ? 812 : 667))
    static let sbReduceHeight = SCREEN_WIDTH * (58/375)
    static let smallPlayerHeight = SCREEN_WIDTH * (48/375)
    
    static let MP3Test = "http://cache.musicfm.co/music/mp3/99024167248247705390676698909371.mp3"
    
    static let MP3URL: URL = URL(string: MP3Test)!
}

class MPPlayingBigView: BaseView {
    
    // MARK: - MP3属性开始
    
    //更新进度条定时器
    var timer:Timer!
    
    var volumeSlider: UISlider!
    
    var currentTrackIndex = 0 {
        didSet {
            if model.count > 0, streamer != nil {
                updateMp3View()
            }
        }
    }
    
    var streamer: DOUAudioStreamer!
    var audioVisualizer: DOUAudioVisualizer!

    // MARK: - MP3属性结束
    
    
    /// 扩展功能
    var moreView: MPSongExtensionToolsView?
    
    /// YouTube播放View
    var playView: YTPlayerView?
    
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
    @IBOutlet weak var xib_coverImage: UIImageView!
    
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
    var playerVars: [String : Any] = [ "showinfo": "0", "modestbranding" : "1", "playsinline": "1", "controls": "0", "autohide": "1"]
    
    /// 0: 顺序播放  1: 随机播放
    var currentPlayOrderMode: Int = 0 {
        didSet {
            randomMode()
        }
    }
    
    /// 0: 列表循环  1: 单曲循环 2: 只播放当前列表
    var currentPlayCycleMode: Int = 0 {
        didSet {
            setCycleModeImage()
        }
    }
    
    /// 当前播放MV的ID
    var songID: String = ""
    
    var currentSouceType: Int = SourceType
    
    var currentSong: MPSongModel? {
        didSet {
            songID = (currentSouceType == 0 ? currentSong?.data_originalId ?? "" : currentSong?.data_songId ?? "")
            // 设置播放状态
            currentSong?.data_playingStatus = 1
            
            if let sn = currentSong?.data_cache, let sid = currentSong?.data_songId {
                currentSouceType = 1
            }else {
                currentSouceType = 0
            }
            
            if currentSouceType == 0, model.count > 0 {
                updateMVView()
            }
        }
    }
    
    /// 随机播放列表
    var randomModel = [MPSongModel]()
    
    /// 当前播放歌曲所属专辑列表
    var currentAlbum: GeneralPlaylists?
    
    var model = [MPSongModel]() {
        didSet {
            // 将当前播放列表保存到数据库
//            MPModelTools.saveCurrentPlayList(currentList: model)
//            
//            var t = self.model
//            randomModel = t.randomObjects_ck()
            
            randomMode()
            
            configPlayer()
        }
    }
    
    private func randomMode() {
        if currentPlayOrderMode == 1 {  // 随机播放
            // 更新下一首播放
            let index = getIndexFromSongs(song: currentSong!, songs: randomModel)
            currentSong = randomModel[index]
            currentTrackIndex = index
        }else {
            // 更新下一首播放
            let index = getIndexFromSongs(song: currentSong!, songs: model)
            currentSong = model[index]
            currentTrackIndex = index
        }
    }
    
    private func configPlayer() {
        if currentSouceType == 0 {
            playMV()
        }else {
            currentTrackIndex = getIndexFromSongs(song: currentSong!, songs: model)
            self.starPlayer()
        }
    }
    
    private func playMV() {
        // 播放MV
        // *** 这里是要','拼接的字符串不是数组：参数错误导致播放失败
        playerVars["playlist"] = getSongIDs(songs: currentPlayOrderMode == 1 ? randomModel : model).joined(separator: ",")
        
        updateMVView()
    }
    
    private func updateMVView() {
        // 播放MV
        ybPlayView.load(withVideoId: currentSong?.data_originalId ?? "", playerVars: playerVars)
        
        // 设置下一首播放
        let nextSong = getNextSongFromSongs(song: self.currentSong!, songs: currentPlayOrderMode == 1 ? randomModel : model)
        xib_nextSongName.text = nextSong.data_title ?? ""
        
        xib_lrc.isSelected = false
        xib_title.text = currentSong?.data_title
        xib_desc.text = currentSong?.data_channelTitle
        
        xib_coverImage.isHidden = true
        
        updateSmallPlayView()
    }
    
    private func updateMp3View() {
        // 设置下一首播放
        let temps = currentPlayOrderMode == 1 ? randomModel : model
        let song = temps[currentTrackIndex]
        let nextSong = getNextSongFromSongs(song: song, songs: temps)
        xib_nextSongName.text = nextSong.data_songName ?? ""
        
        xib_lrc.isSelected = true
        xib_title.text = song.data_songName
        xib_desc.text = song.data_singerName
        
        //设置图片
        xib_coverImage.isHidden = false
        if let img = song.data_artworkBigUrl, img != "" {
            let imgUrl = API.baseImageURL + img
            xib_coverImage.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "placeholder"))
        }
        
        updateSmallPlayView()
    }
    
    private func updateSmallPlayView() {
        // 异步更新当前列表状态
        DispatchQueue.main.async {
            self.xib_collect.isSelected = MPModelTools.checkSongExsistInPlayingList(song: self.currentSong!, tableName: MPMyFavoriteViewController.classCode)
        }
        
        // 小窗口播放数据源
        playingView.currentIndex = model.getIndexFromArray(song: self.currentSong!, songs: currentPlayOrderMode == 1 ? randomModel : model)
        playingView.model = currentPlayOrderMode == 1 ? randomModel : model
    }
    
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
        case 10005: // 播放模式：列表循环/单曲循环
            currentPlayCycleMode = (currentPlayCycleMode + 1) % 2
            break
        case 10006: // 随机播放
            sender.isSelected = !sender.isSelected
            currentPlayOrderMode = sender.isSelected ? 1 : 0
            currentPlayCycleMode = sender.isSelected ? 2 : 0
            
//            if sender.isSelected {
//                getRandomModel()
//            }
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
            pv.sourceType = self.currentSouceType
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
        
        if currentSouceType == 0 {
            mvBtnDidClicked(sender: sender)
        }else {
            mp3BtnDidClicked(sender: sender)
        }
    }
    
    private func mvBtnDidClicked(sender: UIButton) {
        switch sender.tag {
        case 10002: // 上一曲
            ybPlayView.previousVideo()
            // 刷新当前view
            self.currentSong = getPreSongFromSongs(song: self.currentSong!, songs: currentPlayOrderMode == 1 ? randomModel : model)
            break
        case 10003: // 暂停/播放
            playDidClicked()
            break
        case 10004: // 下一曲
            ybPlayView.nextVideo()
            // 刷新当前view
            self.currentSong = getNextSongFromSongs(song: self.currentSong!, songs: currentPlayOrderMode == 1 ? randomModel : model)
            break
        default:
            break
        }
    }
    
    private func mp3BtnDidClicked(sender: UIButton) {
        switch sender.tag {
        case 10001: // 歌词
            let pv = MPLrcView.md_viewFromXIB() as! MPLrcView
            HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
            break
        case 10002: // 上一曲
            self.actionPrev()
            break
        case 10003: // 暂停/播放
            playDidClicked()
            break
        case 10004: // 下一曲
            self.actionNext()
            break
        default:
            break
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
    
    /// 扩展功能列表
    func extensionTools() {
        let pv = MPSongExtensionToolsView.md_viewFromXIB() as! MPSongExtensionToolsView
        self.moreView = pv
        pv.plistName = "extensionTools"
        pv.delegate = self
        pv.title = (currentSouceType == 0 ? currentSong?.data_title : currentSong?.data_songName) ?? ""
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
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
            let progress = Float(ybPlayView.duration()) * value
            ybPlayView.seek(toSeconds: progress, allowSeekAhead: true)
            //如果当前时暂停状态，则继续播放
            if ybPlayView.playerState() == .paused {
                ybPlayView.playVideo()
            }
        }else {
            //播放器定位到对应的位置
            self.actionSliderProgress()
        }
    }
    
    /// 获取随机播放列表
    private func getRandomModel() {
        self.model = self.model.randomObjects_ck()
    }
    
    /// 设置当前播放模式
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
    
    /// 获取当前歌曲下标
    ///
    /// - Parameters:
    ///   - song: 歌曲
    ///   - songs: 列表
    /// - Returns: 下标
    private func getIndexFromSongs(song: MPSongModel, songs: [MPSongModel]) -> Int {
        var index = 0
        for i in (0..<songs.count) {
            if song == songs[i] {
                index = i
            }
        }
        return index
    }
    
    /// 获取上一首歌曲
    ///
    /// - Parameters:
    ///   - song: 当前播放歌曲
    ///   - songs: 列表
    /// - Returns: 上一首歌曲
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
    /// 获取下一首歌曲
    ///
    /// - Parameters:
    ///   - song: 当前播放歌曲
    ///   - songs: 列表
    /// - Returns: 下一首歌曲
    private func getNextSongFromSongs(song: MPSongModel, songs: [MPSongModel]) -> MPSongModel {
        var index = 0
        for i in (0..<songs.count) {
            if song == songs[i] {
                index = (i+1) % songs.count
            }
        }
        return songs[index]
    }
    
    /// 获取当前列表的歌曲ID集合
    ///
    /// - Parameter songs: 列表
    /// - Returns: ID集合
    private func getSongIDs(songs: [MPSongModel]) -> [String] {
        var ids = [String]()
        songs.forEach { (song) in
            ids.append(song.data_originalId ?? "")
        }
        return ids
    }
    
    private func playingStatusAction() {
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

// MARK: - YTPlayerViewDelegate
extension MPPlayingBigView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        ybPlayView.playVideo()
        // 添加到最近播放列表
        if let s = self.currentSong {
            if !MPModelTools.checkSongExsistInPlayingList(song: s, tableName: "RecentlyPlay") {
                MPModelTools.saveSongToTable(song: s, tableName: "RecentlyPlay")
            }
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        // 更新播放进度
        xib_slider.value = playTime / Float(ybPlayView.duration())
        xib_startTime.text = "\(playTime)".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .playing:
            self.mvPlayingStatusAction()
            break
        case .ended:
            self.mvEndPlayingStatusAction()
            break
        default:
            xib_play.isSelected = false
            break
        }
        
        // 更新小窗播放按钮状态
        playingView.currentStatus = xib_play.isSelected
        
    }
    
    private func mvPlayingStatusAction() {
        xib_play.isSelected = true
        xib_endTime.text = "\(ybPlayView.duration())".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
        self.playingStatusAction()
    }
    
    private func mvEndPlayingStatusAction() {
        xib_play.isSelected = false
        
        if currentPlayCycleMode == 1 {  // 单曲循环
            // 刷新当前view
            self.ybPlayView.load(withVideoId: currentSong?.data_originalId ?? "", playerVars: playerVars)
        }else {
            ybPlayView.nextVideo()
            // 刷新当前view
            self.currentSong = getNextSongFromSongs(song: self.currentSong!, songs: currentPlayOrderMode == 1 ? randomModel : model)
        }
    }
    
}
// MARK: - MPPlayingViewDelegate
extension MPPlayingBigView: MPPlayingViewDelegate {
    
    /// 下一首
    ///
    /// - Parameters:
    ///   - view: -
    ///   - index: 下标
    func playingView(pre view: MPPlayingView, index: Int) {
        if currentSouceType == 0 {
            ybPlayView.previousVideo()
            // 刷新当前view
            self.currentSong = (currentPlayOrderMode == 1 ? randomModel : model)[index]
        }else {
            self.actionPrev()
        }
    }
    
    func playingView(next view: MPPlayingView, index: Int) {
        if currentSouceType == 0 {
            ybPlayView.nextVideo()
            // 刷新当前view
            self.currentSong = (currentPlayOrderMode == 1 ? randomModel : model)[index]
        }else {
            self.actionNext()
        }
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
        if currentSouceType == 0 {
            if ybPlayView.playerState() == YTPlayerState.playing {
                ybPlayView.pauseVideo()
            }else {
                ybPlayView.playVideo()
            }
        }else {
            self.actionPlayPause()
        }
    }
    
    private func playByIndex(index: Int) {
        currentSong = (currentPlayOrderMode == 1 ? randomModel : model)[index]
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

// MARK: - 播放MP3
extension MPPlayingBigView {
    
    private func starPlayer() {
        self.resetStreamer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction(timer:)), userInfo: nil, repeats: true)
        // 设置当前音量
        self.updateMp3View()
    }
    
    private func endPlayer() {
        timer.invalidate()
        streamer.stop()
        self.cancelStreamer()
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
            let music = (currentPlayOrderMode == 1 ? randomModel : model)[currentTrackIndex]
            
            // 更新UI
            
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
        if streamer .bufferingRatio >= 1.0 {
            QYTools.shared.Log(log: "sha256: \(streamer.sha256)")
        }
    }
    
    private func setupHintForStreamer() {
        var nextIndex = currentTrackIndex + 1
        if nextIndex >= model.count - 1 {
            nextIndex = 0
        }
        DOUAudioStreamer.setHintWith((currentPlayOrderMode == 1 ? randomModel : model)[nextIndex])
    }
    
    @objc private func updateStatus() {
        switch streamer.status {
        case .playing:
            mp3PlayingStatusAction()
            break
//        case .paused:
//            break
//        case .idle:
//            break
        case .finished:
            mp3EndPlayingStatusAction()
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
    
    private func mp3PlayingStatusAction() {
        xib_play.isSelected = true
        self.playingStatusAction()
    }
    
    private func mp3EndPlayingStatusAction() {
        xib_play.isSelected = false
        
        if currentPlayCycleMode == 1 {  // 单曲循环
            self.resetStreamer()
        }else {
            self.actionNext()
        }
    }

    @objc private func timerAction(timer: Timer) {
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
        if --currentTrackIndex == 0 {
            currentTrackIndex = 0
        }
        self.resetStreamer()
    }
    
    private func actionNext() {
        if ++currentTrackIndex >= model.count - 1 {
            currentTrackIndex = 0
        }
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

