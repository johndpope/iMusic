//
//  MPSearchNavView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

protocol MPSearchNavViewDelegate {
    func beginSearch(_ text: String)
}

class MPSearchNavView: BaseView {

    var delegate: MPSearchNavViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
extension MPSearchNavView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if var text = textField.text, let d = delegate {
            var txt = ""
           
            if string == "" {
                text.removeLast()
                txt = text
            }else {
                txt = text + string
            }
            
            d.beginSearch(txt)
        }
        return true
    }
}
