//
//  MPEditSongListHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPEditSongListHeaderView: UITableViewCell {

    @IBOutlet weak var xib_random: UIButton!
    
    var count: Int = 0 {
        didSet {
            let title = NSLocalizedString("随机播放", comment: "") + "\(count)" + NSLocalizedString("首", comment: "")
            xib_random.setTitle(title, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = md_btnDidClickedBlock {
            b(sender)
        }
    }
}
