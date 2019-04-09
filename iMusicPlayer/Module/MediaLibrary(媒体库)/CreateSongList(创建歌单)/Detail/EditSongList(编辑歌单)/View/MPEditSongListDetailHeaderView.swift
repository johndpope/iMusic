//
//  MPEditSongListDetailHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPEditSongListDetailHeaderView: BaseView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: SCREEN_WIDTH, height: 48)
//    }
    // 自动适配导航栏宽度
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
}
