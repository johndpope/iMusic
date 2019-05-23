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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        xib_downloadOrCollect.isSelected = false
    }

    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
    
    func updateCell(model: MPSongModel) {
        var type = 0
       if let sid = model.data_songId, sid != "", let cache = model.data_cache, cache != "" {
            type = 1
            imageView.isHidden = false
            //设置图片
            if let img = model.data_artworkBigUrl, img != "" {
                let imgUrl = API.baseImageURL + img
                imageView!.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
            }
        
            xib_title.text = model.data_songName
            xib_desc.text = model.data_singerName
        
            if BOOL_OPEN_MP3, BOOL_OPEN_MUSIC_DL {
                xib_downloadOrCollect.setImage(#imageLiteral(resourceName: "icon_download_default_1"), for: .normal)
                xib_downloadOrCollect.setImage(#imageLiteral(resourceName: "icon_download_finish_1"), for: .selected)
            }else {
                xib_downloadOrCollect.setImage(#imageLiteral(resourceName: "icon_collect_normal"), for: .normal)
                xib_downloadOrCollect.setImage(#imageLiteral(resourceName: "icon_collect_selected"), for: .selected)
            }
        }else {
            type = 0
            xib_title.text = model.data_title
            xib_desc.text = model.data_channelTitle
        
            imageView.isHidden = true
        
            xib_downloadOrCollect.setImage(#imageLiteral(resourceName: "icon_collect_normal"), for: .normal)
            xib_downloadOrCollect.setImage(#imageLiteral(resourceName: "icon_collect_selected"), for: .selected)
        }
        
        DispatchQueue.main.async {
            if type == 1, BOOL_OPEN_MP3, BOOL_OPEN_MUSIC_DL {
                if MPModelTools.checkSongExsistInDownloadList(song: model) {
                    self.xib_downloadOrCollect.isSelected = true
                }
            }else {
                if MPModelTools.checkSongExsistInPlayingList(song: model, tableName: MPMyFavoriteViewController.classCode) {
                    self.xib_downloadOrCollect.isSelected = true
                }
            }
        }
    }
    
}
