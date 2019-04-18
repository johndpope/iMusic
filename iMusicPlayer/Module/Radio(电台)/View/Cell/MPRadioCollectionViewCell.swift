//
//  MPRadioCollectionViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/13.
//  Copyright © 2019年 Modi. All rights reserved.
//

import UIKit

class MPRadioCollectionViewCell: UICollectionViewCell, ViewClickedDelegate {
    var clickBlock: ((Any?) -> ())?

    @IBOutlet weak var xib_image: UIImageView!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    @IBOutlet weak var xib_play: UIButton!
    
    var playBtnShow = false {
        didSet {
            xib_play.isHidden = !playBtnShow
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        playBtnShow = false
    }
    
    func updateCell(model: MPSongModel) {
        //设置图片
        if let img = model.data_artworkBigUrl, img != "" {
            let imgUrl = API.baseImageURL + img
            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
        }
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

    @IBAction func play(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
    
}
