//
//  MPSongExtensionToolsView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPSongExtensionToolsView: TableBaseView {
    
    var delegate: MPSongToolsViewDelegate?

    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var xib_title: UILabel!
    
    var title: String = "" {
        didSet {
            xib_title.text = title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 将tableView重新布局
//        self.bringSubviewToFront(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(topLineView.snp.bottom)
            make.bottom.equalTo(bottomLineView.snp.top)
        }
    }
    
}
// MARK: - 点击事件
extension MPSongExtensionToolsView {
    
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
