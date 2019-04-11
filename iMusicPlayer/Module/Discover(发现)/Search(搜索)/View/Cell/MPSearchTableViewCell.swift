//
//  MPSearchTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPSearchTableViewCell: UITableViewCell, ViewClickedDelegate {
    
    var clickBlock: ((Any?) -> ())?

    @IBOutlet weak var xib_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
    
}
