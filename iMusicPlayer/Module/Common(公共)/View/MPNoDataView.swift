//
//  MPNoDataView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/5/8.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPNoDataView: BaseView {

    @IBOutlet weak var xib_image: UIImageView!
    @IBOutlet weak var xib_text: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateView(image: String, text: String) {
        xib_image.image = UIImage(named: image)
        xib_text.text = text
    }
    
}
