//
//  MPPlayingNavView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/21.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPPlayingNavView: BaseView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: SCREEN_WIDTH, height: 64)
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
}
