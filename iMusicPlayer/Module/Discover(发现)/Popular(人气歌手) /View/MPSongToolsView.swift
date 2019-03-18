//
//  MPSongToolsView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/15.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPSongToolsView: TableBaseView {

    var delegate: MPSongToolsViewDelegate?
    
    @IBOutlet weak var topLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 将tableView重新布局
        //        self.bringSubviewToFront(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(topLineView.snp.bottom)
        }
    }
    
}

@objc protocol MPSongToolsViewDelegate {
    @objc optional func addToSongList()
    @objc optional func nextPlay()
    @objc optional func addToPlayList()
    
    @objc optional func timeOff ()
    @objc optional func playVideo()
    @objc optional func songInfo()
}

// MARK: - 点击事件
extension MPSongToolsView {
    
    /// 添加到歌单
    @objc func addToSongList() {
        if let d = self.delegate {
            d.addToSongList!()
        }
    }
    /// 下一首播放
    @objc func nextPlay() {
        if let d = self.delegate {
            d.nextPlay!()
        }
    }
    /// 添加到播放列表
    @objc func addToPlayList() {
        if let d = self.delegate {
            d.addToPlayList!()
        }
    }
    
    /// 定时关闭
    @objc func timeOff() {
        if let d = self.delegate {
            d.timeOff!()
        }
    }
    /// 播放视频
    @objc func playVideo() {
        if let d = self.delegate {
            d.playVideo!()
        }
    }
    /// 歌曲信息
    @objc func songInfo() {
        if let d = self.delegate {
            d.songInfo!()
        }
    }
}
