//
//  MPTimeOffTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPTimeOffTableViewCell: UITableViewCell {

    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_mark: UIImageView!
    
    var markSelected: Bool = false {
        didSet {
            xib_mark.isHidden = !markSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
 
    func updateCell(model: String) {
        xib_title.text = model
    }
}
