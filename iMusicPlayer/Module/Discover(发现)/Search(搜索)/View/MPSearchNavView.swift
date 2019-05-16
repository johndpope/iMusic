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
    func keyboardSearch(_ text: String)
}

class MPSearchNavView: BaseView {

    var delegate: MPSearchNavViewDelegate?
    
    @IBOutlet weak var xib_textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        xib_textField.placeholder = NSLocalizedString("搜索关键字", comment: "")
    }
    
    func setupData(model: String) {
        xib_textField.text = model
    }

}
extension MPSearchNavView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if var text = textField.text, let d = delegate {
            var txt = ""
           
            if string == "", text != "" {
                text.removeLast()
                txt = text
            }else {
                txt = text + string
            }
            
            d.beginSearch(txt)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        QYTools.shared.Log(log: "回调")
        if let d = delegate {
            d.keyboardSearch(textField.text ?? "")
        }
        return true
    }
}
