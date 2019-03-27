//
//  MPPlayingViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/15.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

private struct Constant {
    
    static let playerVars = [
        "playsinline" : 1,  // 是否全屏
        "showinfo" : 0, // 是否显示标题和上传者信息
        "modestbranding" : 1,   //是否显示鼠标
        "controls" : 0,
        "autohide" : 1,
        ] as [String : Any]
}

class MPPlayingViewController: BaseViewController {

    @IBOutlet weak var topViewH: NSLayoutConstraint!
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
    
    @IBOutlet weak var playView: YTPlayerView! {
        didSet {
            playView.delegate = self
        }
    }
    
    @IBOutlet weak var xib_startTime: UILabel!
    
    @IBOutlet weak var xib_endTime: UILabel!
    
    @IBOutlet weak var xib_play: UIButton!
    @IBOutlet weak var xib_cycleMode: UIButton!
    @IBOutlet weak var xib_orderMode: UIButton!
    var playerVars: [String : Any] = [
        "playsinline" : 1,  // 是否全屏
        "showinfo" : 0, // 是否显示标题和上传者信息
        "modestbranding" : 1,   //是否显示鼠标
        "controls" : 0,
        "iv_load_policy": 3,
        "autoplay": 1,
        "autohide" : 1,
        ]
    
    var currentPlayOrderMode: Int = 0 // 0: 顺序播放  1: 随机播放
    var currentPlayCycleMode: Int = 0 // 0: 列表循环  1: 单曲循环 2: 只播放当前列表
    
    var songID: String = ""
    
    var currentSong: MPSongModel? {
        didSet {
            songID = currentSong?.data_originalId ?? ""
        }
    }
    
    var model = [MPSongModel]() {
        didSet {
            if let s = currentSong {
                var index = (getIndexFromSongs(song: s, songs: model) + 1)
                index = index > (model.count - 1) ? model.count - 1 : index
                if SourceType == 0 {
                    nextSongName = model[index].data_title ?? NSLocalizedString("当前列表已播完", comment: "")
                }else {
                    nextSongName = model[index].data_songName ?? NSLocalizedString("当前列表已播完", comment: "")
                }
            }
            
            playerVars["playlist"] = getSongIDs(songs: model)
            
        }
    }
    
    var nextSongName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.titleView?.backgroundColor = UIColor.red
        let nv = MPPlayingNavView.md_viewFromXIB() as! MPPlayingNavView
        nv.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                if btn.tag == 10001 {
                    self.dismiss(animated: true, completion: nil)
                }else {
                    // 全屏播放
                    
                }
            }
        }
        self.navigationItem.titleView = nv
        // 更新视图
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.playingView?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate.playingView?.isHidden = false
    }
    
    override func setupStyle() {
        super.setupStyle()
        if !IPHONEX {
            topViewH.constant -= 58*2
        }
    }

    @IBAction func btn_DidClicked(_ sender: UIButton) {
        switch sender.tag {
        case 10001: // 歌词
            let pv = MPLrcView.md_viewFromXIB() as! MPLrcView
            HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
            break
        case 10002: // 上一曲
            playView.previousVideo()
            break
        case 10003: // 暂停/播放
            if playView.playerState() == YTPlayerState.playing {
                playView.pauseVideo()
                sender.isSelected = false
            }else {
                playView.playVideo()
                sender.isSelected = true
                
            }
            break
        case 10004: // 下一曲
            playView.nextVideo()
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
extension MPPlayingViewController {
    func addToSongList() {
        let pv = MPAddToSongListView.md_viewFromXIB() as! MPAddToSongListView
        // 新建歌单
        pv.createSongListBlock = {
            let pv = MPCreateSongListView.md_viewFromXIB(cornerRadius: 4) as! MPCreateSongListView
            pv.md_btnDidClickedBlock = {(sender) in
                if sender.tag == 10001 {
                    if let sv = pv.superview {
                        sv.removeFromSuperview()
                    }
                }else {
                    // 新建歌单操作
                    SVProgressHUD.showInfo(withStatus: "正在新建歌单~")
                    if let sv = pv.superview {
                        sv.removeFromSuperview()
                    }
                }
            }
            HFAlertController.showCustomView(view: pv)
        }
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
    }
    
    func extensionTools() {
        let pv = MPSongExtensionToolsView.md_viewFromXIB() as! MPSongExtensionToolsView
        pv.plistName = "extensionTools"
        pv.delegate = self
        pv.title = (SourceType == 0 ? currentSong?.data_title : currentSong?.data_songName) ?? ""
        HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
    }
}
extension MPPlayingViewController: MPSongToolsViewDelegate {
    
    func timeOff() {
        QYTools.shared.Log(log: "定时关闭")
    }
    
    func playVideo() {
        QYTools.shared.Log(log: "播放视频")
    }
    
    func songInfo() {
        QYTools.shared.Log(log: "歌曲信息")
    }
}

extension MPPlayingViewController {
    
    @objc func sliderDidChange(sender: UISlider) {
        let value = sender.value
        let progress = Float(currentSong?.data_durationInSeconds ?? 0) * value
        playView.seek(toSeconds: progress, allowSeekAhead: true)
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
    
    private func updateView() {
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
        xib_nextSongName.text = nextSongName
        
        // 设置时间
        xib_startTime.text = "0".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
        xib_endTime.text = "\(currentSong?.data_durationInSeconds ?? 0)".md_dateDistanceTimeWithBeforeTime(format: "mm:ss")
        
        // 播放MV
//        playView.load(withVideoId: currentSong?.data_originalId ?? "")
        playView.load(withVideoId: currentSong?.data_originalId ?? "", playerVars: playerVars)
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
extension MPPlayingViewController: YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        xib_slider.value = playTime / Float((currentSong?.data_durationInSeconds ?? 0))
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
            break
        case .paused:
            xib_play.isSelected = false
            break
        case .ended:
            xib_play.isSelected = false
            // 获取下一首歌曲继续播放
//            currentSong = getNextSongFromSongs(song: currentSong!, songs: self.model)
//            updateView()
//            playView.playVideo()
            playView.nextVideo()
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
    }
    
    
}
