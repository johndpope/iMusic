//
//  MPStyleGenreCollectionViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPStyleGenreCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.md_cornerRadius = 2
            xib_image.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var xib_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateCell(model: Genre) {
        //设置图片
        if let img = model.data_image, img != ""  {
            let imgUrl = API.baseImageURL + img
            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
        }
        xib_title.text = model.data_title
    }
    
}
