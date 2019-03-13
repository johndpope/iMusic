//
//  MPBaseSectionHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

enum MPBaseSectionHeaderViewType {
    case recommend  // 推荐
    case recently   // 最近
    case choiceness // 精选
}

class MPBaseSectionHeaderView: BaseView {

    @IBOutlet weak var xib_top100: UILabel!
    
    @IBOutlet weak var xib_arrowRight: UIImageView!
    
    var fromType: MPBaseSectionHeaderViewType = .recently {
        didSet {
            if fromType == .recommend {
                xib_top100.isHidden = false
                xib_arrowRight.isHidden = true
            }else if fromType == .choiceness {
                xib_top100.isHidden = true
                xib_arrowRight.isHidden = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
