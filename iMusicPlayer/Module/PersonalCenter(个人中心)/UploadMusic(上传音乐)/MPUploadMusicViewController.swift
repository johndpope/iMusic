//
//  MPUploadMusicViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPUploadMusicViewController: BaseViewController {

    @IBOutlet weak var xib_submit: UIButton! {
        didSet {
            xib_submit.md_borderColor = Color.ThemeColor
            xib_submit.md_cornerRadius  = 22
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func btn_DidClicked(_ sender: UIButton) {
        switch sender.tag {
        case 10001: // 选择音乐文件
            searchMusic()
            break
        case 10002: // 选择封面图片
            seletCover()
            break
        case 10003: // 选择歌词文件
            break
        case 10004: // 勾选协议
            sender.isSelected = !sender.isSelected
            break
        case 10005: // 查看协议
            let path = Bundle.main.path(forResource: "policy", ofType: "plist")
            if let p = path, let policys = NSDictionary(contentsOfFile: p) {
                let vc = MDWebViewController()
                vc.title = NSLocalizedString("隐私权政策", comment: "")
                vc.text = policys["policy_1"] as! String
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 10006: // 提交
            break
        default:
            break
        }
    }
}

extension MPUploadMusicViewController {
    
    func searchMusic() {
        //从ipod库中读出音乐文件
        let everything =  MPMediaQuery()
        let itemsFromGenericQuery = everything.items
        for song in itemsFromGenericQuery! {
            //获取音乐名称
            let songTitle = song.value(forProperty: MPMediaItemPropertyTitle)
            print("songTitle==\(songTitle!)")
            //获取作者名称
            let songArt = song.value(forProperty: MPMediaItemPropertyArtist)
            print("songArt=\(songArt!)")
            //获取音乐路径
            let songUrl = song.value(forProperty: MPMediaItemPropertyAssetURL)
            print("songUrl==\(songUrl!)")
        }
    }
    
   
    func seletCover() {
        let manager = HXPhotoManager(type: HXPhotoManagerSelectedType.photo)
         let config = HXPhotoConfiguration()
         // 设置后才会走选择图片代理
         config.requestImageAfterFinishingSelection = true
         
         // 在这里设置为单选模式
         config.singleSelected = true
         // 单选模式下选择图片时是否直接跳转到编辑界面
         config.singleJumpEdit = true
         // 是否可移动的裁剪框
         config.movableCropBox = true
         // 可移动的裁剪框是否可以编辑大小
         config.movableCropBoxEditSize = true
         
         manager?.configuration = config
        self.hx_presentAlbumListViewController(with: manager, delegate: self)
    }
}
extension MPUploadMusicViewController: HXAlbumListViewControllerDelegate {
    func albumListViewController(_ albumListViewController: HXAlbumListViewController!, didDoneAllImage imageList: [UIImage]!) {
        QYTools.shared.Log(log: "获取图片回调:\(imageList)")
    }
}
