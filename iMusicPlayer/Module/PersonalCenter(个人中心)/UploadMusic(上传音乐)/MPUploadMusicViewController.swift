//
//  MPUploadMusicViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPUploadMusicViewController: BaseViewController {
    @IBOutlet weak var xib_songName: UITextField!
    @IBOutlet weak var xib_songerName: UITextField!
    @IBOutlet weak var xib_songPath: UITextField!
    @IBOutlet weak var xib_coverPath: UITextField!
    @IBOutlet weak var xib_lrcPath: UITextField!
    @IBOutlet weak var xib_mvPath: UITextField!
    @IBOutlet weak var xib_agreeBtn: UIButton!
    
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
            submit()
            break
        default:
            break
        }
    }
}

extension MPUploadMusicViewController {
    
    func submit() {
        guard let songName = xib_songName.text else {
            return
        }
        guard let songPath = xib_songPath.text else {
            return
        }
        
        if songName == "" {
            SVProgressHUD.showInfo(withStatus:  NSLocalizedString("请输入歌曲名称", comment: ""))
            return
        }
        
        if songPath == "" {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("请输入歌曲URL", comment: ""))
            return
        }
        
        if !xib_agreeBtn.isSelected {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("请勾选用户协议", comment: ""))
            return
        }
        
        let songerName = xib_songerName.text ?? ""
        let coverPath = xib_coverPath.text ?? ""
        let lrcPath = xib_lrcPath.text ?? ""
        let mvPath = xib_mvPath.text ?? ""
        
        if let obj = UserDefaults.standard.value(forKey: "UserInfoModel") as? Data, let m = NSKeyedUnarchiver.unarchiveObject(with: obj) as? MPUserSettingHeaderViewModel  {
            let uid = m.uid
            DiscoverCent?.requestUploadMP3(uid: uid, artistName: songerName, coverUrl: coverPath, lyricsUrl: lrcPath, musicName: songName, musicUrl: songPath, videoUrl: mvPath, complete: { (isSucceed, msg) in
                switch isSucceed {
                case true:
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("已成功上传", comment: ""))
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: NSLocalizedString("上传出现错误。请重试", comment: ""))
                    break
                }
            })
        }else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("登录了以后，您可以：", comment: ""))
        }
        
    }
    
    func clearText() {
        xib_songName.text = ""
        xib_songerName.text = ""
        xib_songPath.text = ""
        xib_coverPath.text = ""
        xib_lrcPath.text = ""
        xib_mvPath.text = ""
    }
    
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
