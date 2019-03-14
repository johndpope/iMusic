//
//  MPLatestHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPSongListHeaderView: UITableViewCell {

    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.md_cornerRadius = xib_image.height/2
            xib_image.md_borderColor = Color.ThemeColor
        }
    }
    @IBOutlet weak var xib_random: UIButton! {
        didSet {
            xib_random.md_cornerRadius = xib_random.height/2
            xib_random.md_borderColor = Color.ThemeColor
        }
    }
    @IBOutlet weak var xib_collect: UIButton! {
        didSet {
            xib_collect.md_cornerRadius = xib_collect.height/2
            xib_collect.md_borderColor = Color.FontColor_666
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
