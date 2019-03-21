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
        self.navigationItem.titleView?.backgroundColor = UIColor.red
        let nv = MPPlayingNavView.md_viewFromXIB() as! MPPlayingNavView
        nv.md_btnDidClickedBlock = {(sender) in
            if sender.tag == 10001 {
                self.dismiss(animated: true, completion: nil)
            }else {
                // 全屏播放
                
            }
        }
        self.navigationItem.titleView = nv
        
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
            addToSongList()
            break
        case 10009: // 附加功能
            extensionTools()
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
