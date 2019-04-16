//
//  MPPlayingBigView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/1.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import StreamingKit

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
    
    //音频播放器
    var audioPlayer: STKAudioPlayer!
    
    //播放列表
    var queue = [MPSongModel]()
    
    //当前播放音乐索引
    var currentIndex: Int = -1 {
        didSet {
            if audioPlayer != nil, currentIndex >= 0 {
//                resetAudioPlayer()
//                playWithQueue(queue: queue, index: currentIndex)
                updateMp3View()
            }
        }
    }
    
    //是否循环播放
    var loop:Bool = false
    
    //当前播放状态
    var state:STKAudioPlayerState = [] {
        didSet {
            playingView.currentStatus = (state == .playing) ? true : false
        }
    }

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
    var currentPlayOrderMode: Int = 0
    
    /// 0: 列表循环  1: 单曲循环 2: 只播放当前列表
    var currentPlayCycleMode: Int = 0
    
    /// 当前播放MV的ID
    var songID: String = ""
    
    var currentSong: MPSongModel? {
        didSet {
            songID = currentSong?.data_originalId ?? ""
            // 设置播放状态
            currentSong?.data_playingStatus = 1
            if SourceType == 0, model.count > 0 {
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
            MPModelTools.saveCurrentPlayList(currentList: model)
            
            if currentPlayOrderMode == 1 {  // 随机播放
                var t = self.model
                randomModel = t.randomObjects_ck()
            }
            
            configPlayer()
        }
    }
    
    private func configPlayer() {
        if SourceType == 0 {
            playMV()
        }else {
            // 添加队列到音频播放器
            if audioPlayer != nil {
                stop()
            }
            resetAudioPlayer()
            queue = model
            currentIndex = getIndexFromSongs(song: currentSong!, songs: model)
            
//            play(file: queue[currentIndex])
//            playWithQueue(queue: queue, index: currentIndex)
            
//            audioPlayer.play
//            NSURL* url = [NSURL URLWithString:@"http://www.abstractpath.com/files/audiosamples/sample.mp3"];
//
//            STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
//
//            [audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
            
            let url: URL = URL(string: queue[currentIndex].data_cache ?? Constant.MP3Test)!
            let ds = STKAudioPlayer.dataSource(from: url)
            
            
            //            [audioPlayer appendFrameFilterWithName:@"MyCustomFilter" block:^(UInt32 channelsPerFrame, UInt32 bytesPerFrame, UInt32 frameCount, void* frames)
            //                {
            //                ...
            //                }];
            audioPlayer.addFrameFilter(withName: "", afterFilterWithName: "") { (channelsPerFrame, bytesPerFrame, frameCount, frames) in
                QYTools.shared.Log(log: "\(channelsPerFrame)")
            }
            
            audioPlayer.setDataSource(ds, withQueueItemId: queue[currentIndex])
            
            //设置一个定时器，每三秒钟滚动一次
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                         selector: #selector(tick), userInfo: nil, repeats: true)
        }
        
        // 设置时间
        xib_startTime.text = "0".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
        xib_endTime.text = "\(currentSong?.data_durationInSeconds ?? 0)".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
    }
    
    private func playMV() {
        // 播放MV
        // *** 这里是要','拼接的字符串不是数组：参数错误导致播放失败
        playerVars["playlist"] = getSongIDs(songs: currentPlayOrderMode == 1 ? randomModel : model).joined(separator: ",")
        
        // 播放MV
        ybPlayView.load(withVideoId: currentSong?.data_originalId ?? "", playerVars: playerVars)
        
        updateMVView()
    }
    
    private func playMp3() {
        //先重置当前播放器：在继续播放不然会报错（死循环）
        resetAudioPlayer()
//        playWithQueue(queue: queue, index: currentIndex)
    }
    
    private func updateMVView() {
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
        let song = queue[currentIndex]
        let nextSong = getNextSongFromSongs(song: song, songs: currentPlayOrderMode == 1 ? randomModel : model)
        xib_nextSongName.text = nextSong.data_songName ?? ""
        
        xib_lrc.isSelected = true
        xib_title.text = currentSong?.data_songName
        xib_desc.text = currentSong?.data_singerName
        
        //设置图片
        xib_coverImage.isHidden = false
        if let img = currentSong?.data_artworkBigUrl, img != "" {
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
            setCycleModeImage()
            break
        case 10006: // 随机播放
            sender.isSelected = !sender.isSelected
            currentPlayOrderMode = sender.isSelected ? 1 : 0
            
            currentPlayCycleMode = sender.isSelected ? 2 : 0
            setCycleModeImage()
            
            if sender.isSelected {
                getRandomModel()
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
        
        if SourceType == 0 {
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
            prev()
            break
        case 10003: // 暂停/播放
            playDidClicked()
            break
        case 10004: // 下一曲
            next()
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
        pv.title = (SourceType == 0 ? currentSong?.data_title : currentSong?.data_songName) ?? ""
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
    }
}
// MARK: - 歌曲控制相关操作
extension MPPlayingBigView {
    
    /// 滑动滑竿控制播放
    ///
    /// - Parameter sender: 滑竿
    @objc func sliderDidChange(sender: UISlider) {
        if SourceType == 0 {
            let value = sender.value
            let progress = Float(ybPlayView.duration()) * value
            ybPlayView.seek(toSeconds: progress, allowSeekAhead: true)
            //如果当前时暂停状态，则继续播放
            if ybPlayView.playerState() == .paused {
                ybPlayView.playVideo()
            }
        }else {
            //播放器定位到对应的位置
            let value = sender.value
            let progress = Float(audioPlayer.duration) * value
            audioPlayer.seek(toTime: Double(progress))
            //如果当前时暂停状态，则继续播放
            if state == .paused {
                audioPlayer.resume()
            }
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
        // 判断当前播放模式
        if currentPlayOrderMode == 1 { // 随机播放
            if currentPlayCycleMode == 0 {
                
            }else if currentPlayCycleMode == 1 {
                
            }else {
                
            }
        }else { // 顺序播放
            
        }
        switch state {
        case .playing:
            xib_play.isSelected = true
            xib_endTime.text = "\(ybPlayView.duration())".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
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
        case .ended:
            xib_play.isSelected = false
            ybPlayView.nextVideo()
            // 刷新当前view
            self.currentSong = getNextSongFromSongs(song: self.currentSong!, songs: currentPlayOrderMode == 1 ? randomModel : model)
            break
        default:
            xib_play.isSelected = false
            break
        }
        
        // 更新小窗播放按钮状态
        playingView.currentStatus = xib_play.isSelected
        
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
        if SourceType == 0 {
            ybPlayView.previousVideo()
            // 刷新当前view
            self.currentSong = (currentPlayOrderMode == 1 ? randomModel : model)[index]
        }else {
            currentIndex = index
//            playWithQueue(queue: queue, index: currentIndex)
        }
    }
    
    func playingView(next view: MPPlayingView, index: Int) {
        if SourceType == 0 {
            ybPlayView.nextVideo()
            // 刷新当前view
            self.currentSong = (currentPlayOrderMode == 1 ? randomModel : model)[index]
        }else {
            currentIndex = index
//            playWithQueue(queue: queue, index: currentIndex)
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
        if SourceType == 0 {
            if ybPlayView.playerState() == YTPlayerState.playing {
                ybPlayView.pauseVideo()
            }else {
                ybPlayView.playVideo()
            }
        }else {
            //在暂停和继续两个状态间切换
            if self.state == .paused {
                audioPlayer.resume()
            }else{
                audioPlayer.pause()
            }
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

    //重置播放器
    func resetAudioPlayer() {
        var options = STKAudioPlayerOptions()
        options.flushQueueOnSeek = true
        options.enableVolumeMixer = true
        audioPlayer = STKAudioPlayer(options: options)
        
        audioPlayer.meteringEnabled = true
        audioPlayer.equalizerEnabled = true
        audioPlayer.volume = 1
        audioPlayer.delegate = self
    }
    
    //开始播放歌曲列表（默认从第一首歌曲开始播放）
    func playWithQueue(queue: [MPSongModel], index: Int = 0) {
        guard index >= 0 && index < queue.count else {
            return
        }
        self.queue = queue
        audioPlayer.clearQueue()
        
        let url = URL(string: queue[index].data_cache ?? "")
        audioPlayer.play(url ?? Constant.MP3URL)
        
        for i in 1 ..< queue.count {
            audioPlayer.queue(URL(string: queue[Int((index + i) % queue.count)].data_cache ?? "") ?? Constant.MP3URL)
        }
        currentIndex = index
        loop = false
    }
    
    //停止播放
    func stop() {
        audioPlayer.stop()
        audioPlayer.clearQueue()
        audioPlayer.dispose()
        queue = []
        currentIndex = -1
    }
    
    //单独播放某个歌曲
    func play(file: MPSongModel) {
        audioPlayer.play(URL(string: file.data_cache ?? "") ?? Constant.MP3URL)
    }
    
    //下一曲
    func next() {
        guard queue.count > 0 else {
            return
        }
        currentIndex = (currentIndex + 1) % queue.count
//        playWithQueue(queue: queue, index: currentIndex)
    }
    
    //上一曲
    func prev() {
        currentIndex = max(0, currentIndex - 1)
//        playWithQueue(queue: queue, index: currentIndex)
    }
    
    //定时器响应，更新进度条和时间
   @objc func tick() {
        if state == .playing {
            //更新进度条进度值
            self.xib_slider.value = Float(audioPlayer.progress / audioPlayer.duration)
            
            //一个小算法，来实现00：00这种格式的播放时间
            let all:Int=Int(audioPlayer.progress)
            let m:Int=all % 60
            let f:Int=Int(all/60)
            var time:String=""
            if f<10{
                time="0\(f):"
            }else {
                time="\(f)"
            }
            if m<10{
                time+="0\(m)"
            }else {
                time+="\(m)"
            }
            //更新播放时间
            self.xib_startTime.text = time
        }
    }
    
}

//Audio Player相关代理方法
extension MPPlayingBigView: STKAudioPlayerDelegate {
    
    //开始播放歌曲
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        QYTools.shared.Log(log: #function)
        
        QYTools.shared.Log(log: "更新界面")
//        if let index = (queue.index { URL(string: $0.data_cache ?? "") == queueItemId as? URL }) {
//            currentIndex = index
//        }
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, logInfo line: String) {
        QYTools.shared.Log(log: #function)
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didCancelQueuedItems queuedItems: [Any]) {
        QYTools.shared.Log(log: #function)
    }
    
    //缓冲完毕
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        QYTools.shared.Log(log: #function)
        
        let music: MPSongModel = queueItemId as! MPSongModel
//        audioPlayer.queue(STKAudioPlayer.dataSource(from: URL(string: music.data_cache ?? Constant.MP3Test)!), withQueueItemId: queueItemId)
        
        QYTools.shared.Log(log: "更新界面：是否循环播放当前歌曲")
        
//        [self->audioPlayer queueDataSource:[STKAudioPlayer dataSourceFromURL:queueId.url] withQueueItemId:[[SampleQueueId alloc] initWithUrl:queueId.url andCount:queueId.count + 1]];
        // 开始播放音乐：更新界面
    }
    
    //播放状态变化
    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        QYTools.shared.Log(log: #function)
        
        QYTools.shared.Log(log: "更新界面")
//        self.state = state
//        if state != .stopped && state != .error && state != .disposed {
//        }
    }
    
    //播放结束
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        QYTools.shared.Log(log: #function)
        
        QYTools.shared.Log(log: "更新界面")
//        if let index = (queue.index {
//            URL(string: $0.data_cache ?? Constant.MP3Test) == audioPlayer.currentlyPlayingQueueItemId() as? URL
//        }) {
//            currentIndex = index
//        }
//
//        //自动播放下一曲
//        if stopReason == .eof {
//            next()
//        } else if stopReason == .error {
//            stop()
//            resetAudioPlayer()
//        }
    }
    
    //发生错误
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        QYTools.shared.Log(log: #function)
        
        QYTools.shared.Log(log: "更新界面")
//        print("Error when playing music \(errorCode)")
//        resetAudioPlayer()
    }
    
    
    
}

