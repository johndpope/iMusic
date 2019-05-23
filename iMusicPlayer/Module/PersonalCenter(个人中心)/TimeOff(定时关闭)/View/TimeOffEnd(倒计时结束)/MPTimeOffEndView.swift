
//
//  MPTimeOffEndView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/11.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPTimeOffEndView: BaseView {

    @IBOutlet weak var xib_endTime: UIButton!
    @IBOutlet weak var xib_desc: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        xib_endTime.setTitle(NSLocalizedString("时间到了", comment: "").decryptString(), for: .normal)
        xib_desc.text = NSLocalizedString("音乐已被暂停", comment: "").decryptString()
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.removeFromWindow()
    }
}
