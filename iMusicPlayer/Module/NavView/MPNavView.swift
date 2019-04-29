//
//  MPNavView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPNavView: BaseView {

    @IBOutlet weak var xib_image: UIButton! {
        didSet {
            xib_image.md_cornerRadius = xib_image.height/2
            xib_image.imageView?.contentMode = .scaleAspectFit
        }
    }
    
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
