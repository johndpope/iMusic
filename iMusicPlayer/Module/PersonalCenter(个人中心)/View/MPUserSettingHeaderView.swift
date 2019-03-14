//
//  MPUserSettingHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPUserSettingHeaderView: BaseView {

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
    }

}
