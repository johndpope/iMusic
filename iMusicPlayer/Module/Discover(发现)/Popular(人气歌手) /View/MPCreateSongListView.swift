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
    

    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_songListName: UITextField!
    @IBOutlet weak var xib_count: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        xib_songListName.becomeFirstResponder()
        
        // 监听键盘改变事件
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { (notify) in
            // 改变view的高度
            let keyBH = (notify.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! CGRect).height
            let keyBY = (notify.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! CGRect).origin.y
            if keyBY == SCREEN_HEIGHT {
                self.top = (SCREEN_HEIGHT - self.height)/2
            }else {
                let y =  (SCREEN_HEIGHT - keyBH - self.height)/2
                self.top = y
            }
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
