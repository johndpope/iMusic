
//
//  MPTimeOffEndView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/11.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPTimeOffEndView: BaseView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.removeFromWindow()
    }
}
