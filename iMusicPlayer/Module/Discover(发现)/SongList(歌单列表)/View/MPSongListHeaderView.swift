//
//  MPLatestHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPSongListHeaderView: UITableViewCell {

    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.md_cornerRadius = xib_image.height/2
            xib_image.md_borderColor = Color.ThemeColor
        }
    }
    @IBOutlet weak var xib_random: UIButton! {
        didSet {
            xib_random.md_cornerRadius = xib_random.height/2
            xib_random.md_borderColor = Color.ThemeColor
        }
    }
    @IBOutlet weak var xib_collect: UIButton! {
        didSet {
            xib_collect.md_cornerRadius = xib_collect.height/2
            xib_collect.md_borderColor = Color.FontColor_666
        }
    }
    
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_count: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateView(model: GeneralPlaylists) {
        //设置图片
        if let img = model.data_img, img != "" {
            let imgUrl = API.baseImageURL + img
            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
        }
        
        xib_title.text = model.data_title
        xib_count.text = "\(model.data_tracksCount)" + NSLocalizedString("首", comment: "")
    }
    
    func updateView(model: HotSingerPlaylists) {
        //设置图片
        if let img = model.data_img, img != "" {
            let imgUrl = API.baseImageURL + img
            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
        }
        
        xib_title.text = model.data_title
        xib_count.text = "\(model.data_tracksCount)" + NSLocalizedString("首", comment: "")
    }
    
}
