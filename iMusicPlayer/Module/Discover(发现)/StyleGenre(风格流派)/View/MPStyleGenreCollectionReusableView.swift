//
//  MPStyleGenreCollectionReusableView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPStyleGenreCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var xib_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateView(model: String) {
        xib_title.text = model
    }
    
}
