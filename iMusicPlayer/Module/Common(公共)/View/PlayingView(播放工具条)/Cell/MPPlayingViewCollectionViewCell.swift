//
//  MPPlayingViewCollectionViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/21.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPPlayingViewCollectionViewCell: UICollectionViewCell {

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
            HFAppEngine.shared.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
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
}
