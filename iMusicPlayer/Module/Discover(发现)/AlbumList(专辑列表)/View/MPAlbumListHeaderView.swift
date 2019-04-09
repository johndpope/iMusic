//
//  MPLatestHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPAlbumListHeaderView: UITableViewCell, ViewClickedDelegate {
    
    var clickBlock: ((Any?) -> ())?

    @IBOutlet weak var xib_random: UIButton! {
        didSet {
            xib_random.layer.cornerRadius = xib_random.height/2
            xib_random.layer.masksToBounds = true
            xib_random.layer.borderColor = Color.ThemeColor.cgColor
            xib_random.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var xib_image: UIImageView!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_updateTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateView(model: MPRankingTempModel) {
        //设置图片
        xib_image.image = UIImage(named: model.data_image!)
        
        xib_title.text = model.data_title
        xib_updateTime.text = model.data_updateTime
    }

    @IBAction func randomPlay(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
}
