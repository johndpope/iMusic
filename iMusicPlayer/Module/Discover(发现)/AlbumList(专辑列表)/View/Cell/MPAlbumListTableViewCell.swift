//
//  MPLatestTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPAlbumListTableViewCell: UITableViewCell {

    @IBOutlet weak var xib_image: UIImageView!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    @IBOutlet weak var xib_collect: UIButton!
    @IBOutlet weak var xib_more: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
    
}
