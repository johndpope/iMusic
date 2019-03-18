//
//  MPPlayingViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/15.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPPlayingViewController: BaseViewController {

    @IBOutlet weak var topViewH: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            break
        case 10002: // 上一曲
            break
        case 10003: // 暂停/播放
            break
        case 10004: // 下一曲
            break
        case 10005: // 播放模式：列表循环/单曲循环
            break
        case 10006: // 随机播放
            break
        case 10007: // 收藏
            break
        case 10008: // 添加到歌单
            break
        case 10009: // 附加功能
            break
        case 10010: // 播放列表
            let pv = MPPlayingListsPopView.md_viewFromXIB() as! MPPlayingListsPopView
            HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
            break
        default:
            break
        }
    }
}
