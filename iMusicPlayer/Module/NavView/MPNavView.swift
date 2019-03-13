//
//  MPNavView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPNavView: BaseView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH * 48/375)
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
}
