//
//  MPSRMVTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/20.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPSRMVTableViewCell: UITableViewCell {
    
    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.md_cornerRadius = 4
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
