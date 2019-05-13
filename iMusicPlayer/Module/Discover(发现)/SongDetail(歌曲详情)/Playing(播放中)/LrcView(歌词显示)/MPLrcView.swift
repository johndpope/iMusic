//
//  MPLrcView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/21.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPLrcView: BaseView {
    
    var seekToTimeBlock: ((_ time: TimeInterval) -> Void)?
    
    var model: MPLyricsModel? {
        didSet {
            if let lrcs = model?.data_lyrics {
                lyricsView.lyrics = lrcs
                // 设置歌词可以滑动到开始和结束位置
                lyricsView.contentInset = UIEdgeInsets(top: lrcView.height / 2, left: 0, bottom: lrcView.height / 2, right: 0)
                
                lyricsView.scroll(toTime: model?.data_currentTime ?? 0.0, animated: true)
                self.seekToTime(time: model?.data_currentTime ?? 0.0)
            }else {
                lyricsView.lyrics = ""
                self.pause()
            }
        }
    }

    var lyricsView = LyricsView()
    
    @IBOutlet weak var lrcView: UIView! {
        didSet {
            let lyricsView = LyricsView()
            self.lyricsView = lyricsView
            lrcView.addSubview(lyricsView)
            lyricsView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            // 添加滚动时播放View
            lyricsView.addScrollPlayView()
            
            // 传入LRC字符串并设置显示样式
//            let lyricsString = "[al:Down the way]\n[ar:Angus & Julia]\n[by:Scott Rong]\n[re:https://github.com/jayasme/SpotlightLyrics]\n[00:47.580]Goodbye to my Santa Monica dream\n[00:54.880]Fifteen kids in the backyard drinking wine\n[01:03.590]You tell me stories of the sea\n[01:12.000]And the ones you left behind\n[01:19.260]Goodbye to the roses on your street\n[01:26.410]Goodbye to the paintings on the wall\n[01:34.510]Goodbye to the children we'll never meet\n[01:43.520]And the ones we left behind\n[01:51.490]And the ones we left behind\n[01:57.540]I'm somewhere, you're somewhere\n[02:05.310]I'm nowhere, you're nowhere\n[02:13.140]You're somewhere, you're somewhere\n[02:20.910]I could go there but I don't\n[02:30.890]Rob's in the kitchen making pizza\n[02:37.660]Somewhere down in Battery Park\n[02:46.730]I'm singing songs about the future\n[02:54.630]Wondering where you are\n[03:02.680]I could call you on the telephone\n[03:10.480]But do I really want to know?\n[03:18.210]You're making love now to the lady down the road\n[03:24.430]No I don't, I don't want to know\n[03:32.940]I'm somewhere, you're somewhere\n[03:40.810]I'm nowhere, you're nowhere\n[03:48.600]You're somewhere, you're somewhere\n[03:56.340]I could go there but I don't\n[04:37.110]Goodbye to my Santa Monica dream\n[04:44.980]Fifteen kids in the backyard drinking wine\n[04:52.570]You will tell me stories of the sea\n[05:02.410]And the ones you left behind\n[05:10.600]And the ones we left behind\n"
//            lyricsView.lyrics = lyricsString
            lyricsView.lyrics = ""
            lyricsView.lyricFont = UIFont.systemFont(ofSize: 13)
            lyricsView.lyricTextColor = Color.FontColor_666
            lyricsView.lyricHighlightedFont = UIFont.systemFont(ofSize: 13)
            lyricsView.lyricHighlightedTextColor = Color.ThemeColor
            
            lyricsView.seekToTimeBlock = {(time) in
                if let b = self.seekToTimeBlock {
                    b(time)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func play() {
        // 播放
        lyricsView.timer.play()
    }
    
    func pause() {
        // 暂停
        lyricsView.timer.pause()
    }
    
    func seekToTime(time: TimeInterval) {
        // 跳转到指定的时间
        lyricsView.timer.seek(toTime: time)
        if model?.data_currentStatus == 1 {
            lyricsView.timer.play()
        }else {
            lyricsView.timer.pause()
        }
    }
    
    func repeatPlay() {
        // 重新播放
        lyricsView.timer.seek(toTime: 0)
        lyricsView.timer.play()
    }

    @IBAction func close(_ sender: UIButton) {
        if let sv = self.superview {
            sv.removeFromSuperview()
            self.lyricsView.removeScrollPlayView()
        }
    }
}
