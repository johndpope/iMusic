//
//  MPPlayingViewCollectionViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/21.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class MPPlayingViewCollectionViewCell: UICollectionViewCell {

    var ybPlayView: YTPlayerView?
    var imageView: UIImageView?
    
    @IBOutlet weak var playView: UIView! {
        didSet {
            if SourceType == 0 {    // MV
                let pv = YTPlayerView()
                ybPlayView = pv
                pv.delegate = self
                playView.addSubview(pv)
                pv.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }else { // MP3
                let iv = UIImageView()
                imageView = iv
                self.addSubview(iv)
                iv.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
        }
    }
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    @IBOutlet weak var xib_play: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func btn_DidClicked(_ sender: UIButton) {
        switch sender.tag {
        case 10001:
            //            let vc = MPSongDetailViewController()
            //            HFAppEngine.shared.currentViewController()?.present(vc, animated: true, completion: nil)
           
            // 隐藏播放View
            appDelegate.playingView?.isHidden = true
            
            let vc = MPPlayingViewController()
            let nav = UINavigationController(rootViewController: vc)
            HFAppEngine.shared.currentViewController()?.present(nav, animated: true, completion: nil)
            break
        case 10002:
            sender.isSelected = true
            break
        case 10003:
            sender.isSelected = !sender.isSelected
            break
        default:
            break
        }
    }
    
    func updateCell(model: MPSongModel) {
        
        if SourceType == 0 {
            
            ybPlayView?.load(withVideoId: model.data_originalId!, playerVars: [ "showinfo": "0", "modestbranding" : "1"])
            
            xib_title.text = model.data_title
            xib_desc.text = model.data_channelTitle
        }else {
            //设置图片
            if let img = model.data_artworkBigUrl, img != "" {
                let imgUrl = API.baseImageURL + img
                imageView!.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
            }
            
            xib_title.text = model.data_songName
            xib_desc.text = model.data_singerName
        }
        
        
    }
    
}
extension MPPlayingViewCollectionViewCell: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        ybPlayView?.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        // 判断当前播放模式
        switch state {
        case .buffering:
            xib_play.isSelected = false
            break
        case .playing:
            xib_play.isSelected = true
            break
        case .paused:
            xib_play.isSelected = false
            break
        case .ended:
            xib_play.isSelected = false
            // 获取下一首歌曲继续播放
            //            currentSong = getNextSongFromSongs(song: currentSong!, songs: self.model)
            //            updateView()
            //            playView.playVideo()
            ybPlayView!.nextVideo()
            break
        case .queued:
            xib_play.isSelected = false
            break
        case .unknown:
            xib_play.isSelected = false
            break
        case .unstarted:
            xib_play.isSelected = false
            break
        default:
            break
        }
    }
    
}
