//
//  MPMediaLibraryTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPMediaLibraryTableViewCell: UITableViewCell {

    @IBOutlet weak var xib_image: UIImageView!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    @IBOutlet weak var xib_more: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = md_btnDidClickedBlock {
            b(sender)
        }
    }
    
    func updateCell(model: MPSongModel, sourceType: Int = -1) {
        //设置图片
        if let img = model.data_artworkBigUrl, img != "" {
            let imgUrl = API.baseImageURL + img
            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
        }
        
        if sourceType == 0 {
            xib_title.text = model.data_title
            xib_desc.text = model.data_channelTitle
        }else {
            xib_title.text = model.data_songName
            xib_desc.text = model.data_singerName
        }
    }
    
}
