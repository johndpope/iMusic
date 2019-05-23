//
//  MPLatestHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPMyFavoriteHeaderView: UITableViewCell, ViewClickedDelegate {
    
    var clickBlock: ((Any?) -> ())?
    
    @IBOutlet weak var xib_random: UIButton!
    
    var count: Int = 0 {
        didSet {
            let title = NSLocalizedString("随机播放", comment: "").decryptString() + "(\(count)\(NSLocalizedString("首", comment: "").decryptString()))"
            xib_random.setTitle(title, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let title = NSLocalizedString("随机播放", comment: "").decryptString()
        xib_random.setTitle(title, for: .normal)
    }
    
    @IBAction func randomPlay(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
}
