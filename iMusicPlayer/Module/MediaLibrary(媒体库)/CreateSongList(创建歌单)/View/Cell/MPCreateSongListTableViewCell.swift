//
//  MPDiscoverTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPCreateSongListTableViewCell: UITableViewCell {

    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.viewClipCornerDirection(radius: 2, direct: .left)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

