//
//  MPSongInfoView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/11.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPSongInfoView: BaseView {

    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    @IBOutlet weak var xib_uploader: UILabel!
    @IBOutlet weak var xib_protocol: MDRightIconButton!
    @IBOutlet weak var xib_complaint: MDRightIconButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        xib_uploader.text = NSLocalizedString("上传者", comment: "").decryptString()
        xib_protocol.setTitle(NSLocalizedString("《著作权许可协议》", comment: "").decryptString(), for: .normal)
        xib_complaint.setTitle(NSLocalizedString("投诉", comment: "").decryptString(), for: .normal)
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
    
    func updateView(model: MPSongModel) {
        var type = -1
       if let sid = model.data_songId, sid != "", let cache = model.data_cache, cache != "" {
            type = 1
        }else {
            type = 0
        }
        
        if type == 0 {
            xib_title.text = model.data_title
            xib_desc.text = model.data_channelTitle
        }else {
            xib_title.text = model.data_songName
            xib_desc.text = model.data_singerName
        }
    }
    
}
