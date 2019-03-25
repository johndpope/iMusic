//
//  MPRecommendCollectionViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPRecommendCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var xib_image: UIImageView!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_user: UILabel!
    
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
        if let title = model.data_title {
            xib_title.text = title
            xib_user.text = model.data_channelTitle
        }else {
            xib_title.text = model.data_songName
            xib_user.text = model.data_songName
        }
        
        
    }

}
