//
//  MPRankingTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPPopularTableViewCell: UITableViewCell {

    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.layer.cornerRadius = xib_image.height/2
            xib_image.layer.masksToBounds = true
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
