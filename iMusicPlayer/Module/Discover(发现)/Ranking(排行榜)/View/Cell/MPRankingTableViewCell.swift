//
//  MPRankingTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPRankingTableViewCell: UITableViewCell {

    @IBOutlet weak var xib_image: UIImageView!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_updateTime: UILabel!
    @IBOutlet weak var xib_rank1: UILabel!
    @IBOutlet weak var xib_rank2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCell(model: MPRankingModel) {
        //设置图片
//        if let img = model.data_artworkBigUrl, img != "" {
//            let imgUrl = API.baseImageURL + img
//            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
//        }
//        
//        xib_title.text = model.data_title
//        xib_updateTime.text = model.data
        
    }
    
}
