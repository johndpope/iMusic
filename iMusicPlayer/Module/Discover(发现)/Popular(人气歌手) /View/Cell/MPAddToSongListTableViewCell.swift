//
//  MPAddToSongListTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/15.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPAddToSongListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameCenterConstraints: NSLayoutConstraint!
    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.viewClipCornerDirection(radius: 2, direct: .left)
            xib_image.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_count: UILabel!
    
    var type: Int = 0 {
        didSet {
            if type == 1 {
                nameCenterConstraints.constant = 0
                xib_count.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCell(model: GeneralPlaylists) {
        //设置图片
        if let img = model.data_img, img != "" {
            if img.contains("http") {
                let imgUrl = API.baseImageURL + img
                xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
            }else {
                xib_image.image = UIImage(named: img)
            }
        }
        xib_title.text = model.data_title
        xib_count.text = "\(model.data_tracksCount)" + NSLocalizedString("首", comment: "")
    }
    
}
