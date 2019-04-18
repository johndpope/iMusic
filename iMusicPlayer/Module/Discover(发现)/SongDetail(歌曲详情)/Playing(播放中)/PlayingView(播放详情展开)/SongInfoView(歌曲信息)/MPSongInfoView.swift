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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
    
    func updateView(model: MPSongModel) {
        var type = -1
        if let _ = model.data_songId, let _ = model.data_cache {
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
