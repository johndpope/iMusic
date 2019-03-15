//
//  MPAddToSongListTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/15.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPAddToSongListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameCenterConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var xib_songCount: UILabel!
    
    var type: Int = 0 {
        didSet {
            if type == 1 {
                nameCenterConstraints.constant = 0
                xib_songCount.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCell() {
        
    }
    
}
