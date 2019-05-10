//
//  MPPlayingViewCollectionViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/21.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class MPPlayingViewCollectionViewCell: UICollectionViewCell, ViewClickedDelegate {
    
    var clickBlock: ((Any?) -> ())?
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.md_cornerRadius = 2
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    @IBOutlet weak var xib_play: UIButton!
    @IBOutlet weak var xib_downloadOrCollect: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
    
    func updateCell(model: MPSongModel) {
        
        var type = -1
       if let sid = model.data_songId, sid != "", let cache = model.data_cache, cache != "" {
            type = 1
        }else {
            type = 0
        }
        
        if type == 0 {
            xib_title.text = model.data_title
            xib_desc.text = model.data_channelTitle
            
            imageView.isHidden = true
        }else {
            
            imageView.isHidden = false
            //设置图片
            if let img = model.data_artworkBigUrl, img != "" {
                let imgUrl = API.baseImageURL + img
                imageView!.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
            }
            
            xib_title.text = model.data_songName
            xib_desc.text = model.data_singerName
        }
        
        DispatchQueue.main.async {
            if MPModelTools.checkSongExsistInPlayingList(song: model, tableName: MPMyFavoriteViewController.classCode) {
                self.xib_downloadOrCollect.isSelected = true
            }
        }
    }
    
}
