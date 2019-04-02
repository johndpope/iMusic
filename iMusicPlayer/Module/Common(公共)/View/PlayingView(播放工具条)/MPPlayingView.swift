//
//  MPPlayingView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/21.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

private struct Constant {
    static let identifier = "MPPlayingViewCollectionViewCell"
    static let rowHeight = SCREEN_WIDTH * (48/375)
}

class MPPlayingView: BaseView {
    
    var playerVars: [String : Any] = [
        "playsinline" : 1,
        "showinfo" : 0,
        "rel" : 1,
        "modestbranding" : 1,
        "controls" : 0,
    ]
    
    private lazy var ybPlayView: YTPlayerView = {
        let pv = YTPlayerView()
        pv.frame = CGRect(origin: .zero, size: CGSize(width: 90, height: 48))
        pv.backgroundColor = UIColor.red
        pv.delegate = self
        return pv
    }()
    
    var currentSong: MPSongModel?

    var model = [MPSongModel]() {
        didSet {
            collectionView.reloadData()
            // 将当前播放列表保存到数据库
            MPModelTools.saveCurrentPlayList(currentList: model)
            playerVars["playlist"] = getSongIDs(songs: model)
            
            ybPlayView.load(withVideoId: currentSong?.data_originalId ?? "", playerVars: playerVars)

        }
    }
    
    var currentStatus: Bool = false
    
    // MARK: - TableView
    private lazy var collectionView: UICollectionView  = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.layout = layout
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(UINib(nibName: Constant.identifier, bundle: nil), forCellWithReuseIdentifier: Constant.identifier)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = UIColor.white
        cv.bounces = true
        cv.isPagingEnabled = true
        
        cv.addSubview(ybPlayView)
        return cv
    }()
    
    /// 向外提供布局变量
    open var layout: UICollectionViewFlowLayout?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
//        ybPlayView.snp.makeConstraints({ (make) in
//            make.top.left.equalToSuperview()
//            let height = collectionView.height
//            let width = height * (48/90)
//            make.size.equalTo(CGSize(width: 90, height: 48))
//        })
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
extension MPPlayingView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.identifier, for: indexPath) as! MPPlayingViewCollectionViewCell
        cell.updateCell(model: model[indexPath.row])
        cell.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                switch btn.tag {
                case 10001: // 播放详情
                    // 隐藏播放View
                    //            appDelegate.playingView?.isHidden = true
                    // 显示当前的播放View
                    if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView, let window = UIApplication.shared.delegate?.window! {
                        pv.isHidden = false
                        pv.currentSong = self.currentSong
                        pv.model =  self.model
                        window.bringSubviewToFront(pv)
                    }
                    break
                case 10002: // 下载、收藏
                    
                    break
                case 10003: // 暂停、播放
                    if self.ybPlayView.playerState() == YTPlayerState.playing {
                        self.ybPlayView.pauseVideo()
                    }else {
                        self.ybPlayView.playVideo()
                    }
                    break
                default:
                    break
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: SCREEN_WIDTH, height: Constant.rowHeight)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension MPPlayingView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        ybPlayView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        // 判断当前播放模式
        switch state {
        case .buffering:
            currentStatus = false
            break
        case .playing:
            currentStatus = true
            break
        case .paused:
            currentStatus = false
            break
        case .ended:
            currentStatus = false
            // 获取下一首歌曲继续播放
            //            currentSong = getNextSongFromSongs(song: currentSong!, songs: self.model)
            //            updateView()
            //            playView.playVideo()
            ybPlayView.nextVideo()
            break
        case .queued:
            currentStatus = false
            break
        case .unknown:
            currentStatus = false
            break
        case .unstarted:
            currentStatus = false
            break
        default:
            break
        }
    }
    
}
extension MPPlayingView {
    private func getSongIDs(songs: [MPSongModel]) -> [String] {
        var ids = [String]()
        songs.forEach { (song) in
            ids.append(song.data_originalId ?? "")
        }
        return ids
    }
}
