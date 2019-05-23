//
//  MPCollectSongListHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/15.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPCreateSongListHeaderView: UITableViewCell, ViewClickedDelegate {
    var clickBlock: ((Any?) -> ())?

    @IBOutlet weak var xib_title: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        xib_title.setTitle(NSLocalizedString("新建", comment: "").decryptString(), for: .normal)
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
}
