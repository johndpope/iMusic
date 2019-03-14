//
//  MPPopularHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import TagListView

class MPPopularHeaderView: BaseView {

    private let countryTags = [NSLocalizedString("全部", comment: ""), NSLocalizedString("日本", comment: ""), NSLocalizedString("韩国", comment: ""), NSLocalizedString("欧美", comment: "")]
    @IBOutlet weak var xib_countryTagList: TagListView!
    
    
    private let categoryTags = [NSLocalizedString("全部", comment: ""), NSLocalizedString("男歌手", comment: ""), NSLocalizedString("女歌手", comment: ""), NSLocalizedString("组合", comment: "")]
    @IBOutlet weak var xib_categoryTagList: TagListView!
    
    @IBOutlet weak var xib_nameBgView: UIView! {
        didSet {
            xib_nameBgView.layer.borderWidth = 1
            xib_nameBgView.layer.borderColor = Color.FontColor_bbb.cgColor
            xib_nameBgView.layer.cornerRadius = 2
            xib_nameBgView.layer.masksToBounds = true
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        xib_countryTagList.addTags(countryTags)
        xib_categoryTagList.addTags(categoryTags)
        
        xib_countryTagList.tagViews.first!.isSelected = true
        xib_categoryTagList.tagViews.first!.isSelected = true
        
    }

}
