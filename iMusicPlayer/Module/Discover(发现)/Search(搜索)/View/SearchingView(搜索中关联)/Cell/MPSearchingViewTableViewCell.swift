//
//  MPSearchingViewTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/20.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPSearchingViewTableViewCell: UITableViewCell {

    @IBOutlet weak var xib_title: UILabel!
    
    var title: String = "" {
        didSet {
            xib_title.text = title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
