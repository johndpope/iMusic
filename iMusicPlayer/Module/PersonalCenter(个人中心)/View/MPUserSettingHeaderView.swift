//
//  MPUserSettingHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPUserSettingHeaderView: BaseView {

    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.md_cornerRadius = xib_image.height/2
            xib_image.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet weak var xib_loginBgView: UIView!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    
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
        normalStyle()
    }

    func normalStyle() {
        xib_image.image = #imageLiteral(resourceName: "img_photo_default")
        xib_loginBgView.isHidden = true
    }
    
    private func loginStyle() {
        xib_loginBgView.isHidden = false
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
        }
        
        xib_title.text = model.name
        
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            xib_desc.text = NSLocalizedString("@" + appName, comment: "")
        }
    }
    
}

class MPUserSettingHeaderViewModel {
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
}
