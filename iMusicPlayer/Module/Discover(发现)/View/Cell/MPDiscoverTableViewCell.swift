//
//  MPDiscoverTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPDiscoverTableViewCell: UITableViewCell {

    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.viewClipCornerDirection(radius: 2, direct: .left)
        }
    }
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_count: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateCell(model: GeneralPlaylists, type: Int = -1) {
        //设置图片
        if let img = model.data_img, img != "" {
            let imgUrl = API.baseImageURL + img
            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
        }
        xib_title.text = model.data_title
        xib_count.text = "\(model.data_tracksCount)" + NSLocalizedString("首", comment: "")
        
        if type != -1 {
            xib_count.isHidden = true
        }else {
            xib_count.isHidden = false
        }
    }

    var clickBlock: ((Any?) -> ())?
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
}

