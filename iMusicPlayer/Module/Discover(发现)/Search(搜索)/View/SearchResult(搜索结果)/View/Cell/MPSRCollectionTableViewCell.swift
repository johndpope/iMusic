//
//  MPSRCollectionTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/20.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPSRCollectionTableViewCell: UITableViewCell {

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
