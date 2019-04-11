//
//  MPTimeOffHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPTimeOffHeaderView: UITableViewCell {

    @IBOutlet weak var xib_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var model: String = NSLocalizedString("计时结束后，将暂停播放歌曲", comment: "") {
        didSet {
            xib_title.text = model
        }
    }
    
}
