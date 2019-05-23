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
    
    @IBOutlet weak var xib_segment: UISegmentedControl!
    @IBOutlet weak var xib_random: UIButton!
    
    //    type=Japan。欧美：hl=Europe 韩国：Korea
    var currentType = "Japan"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(90/375)))
        
        xib_random.setTitle(NSLocalizedString("随机播放", comment: "").decryptString(), for: .normal)
        xib_segment.setTitle(NSLocalizedString("日本", comment: "").decryptString(), forSegmentAt: 0)
        xib_segment.setTitle(NSLocalizedString("欧美", comment: "").decryptString(), forSegmentAt: 1)
        xib_segment.setTitle(NSLocalizedString("韩国", comment: "").decryptString(), forSegmentAt: 2)
        
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
