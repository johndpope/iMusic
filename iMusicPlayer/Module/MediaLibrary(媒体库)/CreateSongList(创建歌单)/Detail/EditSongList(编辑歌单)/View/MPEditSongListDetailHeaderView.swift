//
//  MPEditSongListDetailHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPEditSongListDetailHeaderView: BaseView {

    @IBOutlet weak var xib_selectAll: UIButton!
    @IBOutlet weak var xib_finished: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        xib_selectAll.setTitle(NSLocalizedString("全选", comment: "").decryptString(), for: .normal)
        xib_finished.setTitle(NSLocalizedString("完成", comment: "").decryptString(), for: .normal)
    }
    
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: SCREEN_WIDTH, height: 48)
//    }
    // 自动适配导航栏宽度
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
}
