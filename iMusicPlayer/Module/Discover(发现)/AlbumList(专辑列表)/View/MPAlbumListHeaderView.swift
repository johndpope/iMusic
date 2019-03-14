//
//  MPLatestHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPAlbumListHeaderView: UITableViewCell {

    @IBOutlet weak var xib_random: UIButton! {
        didSet {
            xib_random.layer.cornerRadius = xib_random.height/2
            xib_random.layer.masksToBounds = true
            xib_random.layer.borderColor = Color.ThemeColor.cgColor
            xib_random.layer.borderWidth = 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
