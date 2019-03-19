//
//  MPEditSongListHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPEditSongListHeaderView: UITableViewCell {

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
