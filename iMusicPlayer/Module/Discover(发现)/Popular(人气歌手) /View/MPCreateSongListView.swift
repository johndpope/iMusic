//
//  MPCreateSongListView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/15.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPCreateSongListView: UITableViewCell, ViewClickedDelegate {
    
    var clickBlock: ((Any?) -> ())?
    

    @IBOutlet weak var xib_songListName: UITextField!
    @IBOutlet weak var xib_count: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if let b = clickBlock {
            b(sender)
        }
    }
}
extension MPCreateSongListView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location > 29 {
            let subString = self.xib_songListName.text! as NSString
            self.xib_songListName.text = subString.substring(to: 30)
            return false
        }
        if string == "" {
             xib_count.text = "\(xib_songListName.text!.count - 1)/30"
        }else {
             xib_count.text = "\(xib_songListName.text!.count + 1)/30"
        }
        return true
    }
    
}
