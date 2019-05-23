//
//  MPUserSettingHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPUserSettingHeaderView: BaseView {

    @IBOutlet weak var xib_logout: UIButton!
    
    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.md_cornerRadius = xib_image.height/2
            xib_image.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet weak var xib_loginBgView: UIView!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    @IBOutlet weak var xib_showInfo: UILabel!
    
    @IBOutlet weak var xib_googleLogin: UIButton! {
        didSet {
            xib_googleLogin.layer.borderWidth = 1
            xib_googleLogin.layer.borderColor = Color.ThemeColor.cgColor
            xib_googleLogin.layer.cornerRadius = xib_googleLogin.height/2
            xib_googleLogin.layer.masksToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        xib_showInfo.text = NSLocalizedString("歌单将保持在账号内，即使更换了设备歌单也不会丢失。", comment: "").decryptString()
        xib_googleLogin.setTitle(NSLocalizedString("使用 Google 账号进行登录", comment: "").decryptString(), for: .normal)
        
        normalStyle()
    }

    func normalStyle() {
        xib_image.image = #imageLiteral(resourceName: "img_photo_default")
        xib_loginBgView.isHidden = true
        
        xib_logout.isEnabled = false
        
        xib_googleLogin.isHidden = false
        xib_showInfo.isHidden = false
    }
    
    private func loginStyle() {
        xib_loginBgView.isHidden = false
        
        xib_logout.isEnabled = true
        xib_googleLogin.isHidden = true
        xib_showInfo.isHidden = true
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
    
    func updateView(model: MPUserSettingHeaderViewModel) {
        
        self.loginStyle()
        
        //设置图片
        let img = model.picture
        if img != "" {
            let imgUrl = API.baseImageURL + img
            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
            
            NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_RefreshUserPicture), object: nil)
            
        }
        
        xib_title.text = model.name
        
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            xib_desc.text = NSLocalizedString("@" + appName, comment: "")
        }
    }
    
}

class MPUserSettingHeaderViewModel: NSObject, NSCoding {
    var picture: String
    var name: String
    var email: String
    var uid: String
    var did: String
    
    init(picture: String, name: String, email: String, uid: String, did: String) {
        self.picture = picture
        self.name = name
        self.email = email
        self.uid = uid
        self.did = did
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.picture, forKey: "picture")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.uid, forKey: "uid")
        aCoder.encode(self.did, forKey: "did")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.picture = aDecoder.decodeObject(forKey: "picture") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.email = aDecoder.decodeObject(forKey: "email") as! String
        self.uid = aDecoder.decodeObject(forKey: "uid") as! String
        self.did = aDecoder.decodeObject(forKey: "did") as! String
    }
    
}
