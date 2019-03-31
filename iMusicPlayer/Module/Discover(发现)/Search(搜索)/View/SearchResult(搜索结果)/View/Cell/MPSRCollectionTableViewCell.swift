//
//  MPSRCollectionTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/20.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPSRCollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.layer.cornerRadius = xib_image.height/2
            xib_image.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var xib_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCell(model: GeneralPlaylists) {
        //设置图片
        if let img = model.data_img, img != "" {
            let imgUrl = API.baseImageURL + img
            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
        }
        xib_title.text = model.data_title
    }
    
}
