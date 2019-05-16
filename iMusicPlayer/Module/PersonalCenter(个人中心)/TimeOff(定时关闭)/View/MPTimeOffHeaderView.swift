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
    
    var model: String = NSLocalizedString("定时到达后，歌曲将被暂停播放", comment: "") {
        didSet {
            xib_title.text = model
        }
    }
    
}
