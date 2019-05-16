//
//  MPTimeOffPopView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPTimeOffPopView: UITableViewCell, ViewClickedDelegate {

    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_time: UITextField!
    @IBOutlet weak var xib_minutes: UILabel!
    @IBOutlet weak var xib_timeDesc: UILabel!
    @IBOutlet weak var xib_cancel: UIButton!
    @IBOutlet weak var xib_submit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        xib_title.text = NSLocalizedString("自定义", comment: "")
        xib_time.placeholder = NSLocalizedString("时间", comment: "")
        xib_minutes.text = NSLocalizedString("分钟后", comment: "")
        xib_timeDesc.text = NSLocalizedString("不能超过1440分钟", comment: "")
        xib_cancel.setTitle(NSLocalizedString("取消", comment: ""), for: .normal)
        xib_submit.setTitle(NSLocalizedString("确定", comment: ""), for: .normal)
    }

    var clickBlock: ((Any?) -> ())?
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
}
