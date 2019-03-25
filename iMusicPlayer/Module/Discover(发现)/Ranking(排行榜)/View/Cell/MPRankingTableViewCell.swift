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
    
    func updateCell(model: MPRankingTempModel) {
        //设置图片
        xib_image.image = UIImage(named: model.data_image!)
        
        xib_title.text = model.data_title
        xib_updateTime.text = model.data_updateTime
        xib_rank1.text = "1." + model.data_songOne!
        xib_rank2.text = "2." + model.data_songTwo!
        
    }
    
}
