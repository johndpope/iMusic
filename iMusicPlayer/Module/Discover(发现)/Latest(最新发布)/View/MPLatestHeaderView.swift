//
//  MPLatestHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPLatestHeaderView: BaseView {
    
    var sgmDidChangeBlock: (()->Void)?
    
//    type=Japan。欧美：hl=Europe 韩国：Korea
    var currentType = "Japan"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(90/375)))
    }
    
    @IBAction func segmentDidChange(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            currentType = "Japan"
            break
        case 1:
            currentType = "Europe"
            break
        case 2:
            currentType = "Korea"
            break
        default:
            break
        }
        if let b = sgmDidChangeBlock {
            b()
        }
    }
    
    @IBAction func randomPlay(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
}
