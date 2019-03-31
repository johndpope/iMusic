//
//  MPRecentlyCollectionViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPRecentlyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var xib_image: UIImageView!
    @IBOutlet weak var xib_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCell(model: GeneralPlaylists) {
        //设置图片
        if let img = model.data_img, img != "" {
            let imgUrl = API.baseImageURL + img
            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "pic_album_default"))
        }
        xib_title.text = model.data_title
        
    }

}
