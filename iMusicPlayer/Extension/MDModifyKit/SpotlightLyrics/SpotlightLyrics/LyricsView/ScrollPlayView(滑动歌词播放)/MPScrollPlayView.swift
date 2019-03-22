//
//  MPScrollPlayView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/22.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPScrollPlayView: BaseView {

    @IBOutlet weak var xib_time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        xib_time.text = "00:00"
    }
    
    func updateTime(model: String) {
        xib_time.text = model
    }
    
    @IBAction func play(_ sender: UIButton) {
        if let b = md_btnDidClickedBlock {
            b(sender)
        }
    }
}
