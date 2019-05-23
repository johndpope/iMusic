//
//  MPPopularHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import TagListView

class MPPopularHeaderView: BaseView {
    
    var sgmDidChangeBlock: ((_ name: String)->Void)?
    
    var nationality: Int = 0, type: Int = 0

    private let countryTags = [NSLocalizedString("全部", comment: "").decryptString(), NSLocalizedString("日本", comment: "").decryptString(), NSLocalizedString("韩国", comment: "").decryptString(), NSLocalizedString("欧美", comment: "").decryptString()]
    @IBOutlet weak var xib_countryTagList: TagListView!
    
    
    private let categoryTags = [NSLocalizedString("全部", comment: "").decryptString(), NSLocalizedString("男歌手", comment: "").decryptString(), NSLocalizedString("女歌手", comment: "").decryptString(), NSLocalizedString("组合", comment: "").decryptString()]
    @IBOutlet weak var xib_categoryTagList: TagListView!
    
    @IBOutlet weak var xib_nameBgView: UIView! {
        didSet {
            xib_nameBgView.layer.borderWidth = 1
            xib_nameBgView.layer.borderColor = Color.FontColor_bbb.cgColor
            xib_nameBgView.layer.cornerRadius = 2
            xib_nameBgView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var xib_nameTF: UITextField!
    
    @IBOutlet weak var xib_country: UILabel!
    @IBOutlet weak var xib_category: UILabel!
    @IBOutlet weak var xib_nameLB: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        xib_country.text = NSLocalizedString("国家", comment: "").decryptString()
        xib_category.text = NSLocalizedString("类别", comment: "").decryptString()
        xib_nameLB.text = NSLocalizedString("姓名", comment: "").decryptString()
        xib_nameTF.placeholder = NSLocalizedString("搜索歌手", comment: "").decryptString()
        
        xib_countryTagList.addTags(countryTags)
        xib_categoryTagList.addTags(categoryTags)
        
        xib_countryTagList.tagViews.first!.isSelected = true
        xib_categoryTagList.tagViews.first!.isSelected = true
        
        xib_countryTagList.delegate = self
        xib_categoryTagList.delegate = self
        
    }

}
extension MPPopularHeaderView: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        // 取消选中状态
        sender.tagViews.forEach { (tagView) in
            tagView.isSelected = false
        }
        tagView.isSelected = true
        
        if sender == xib_countryTagList {
            switch title {
            case NSLocalizedString("日本", comment: "").decryptString():
                nationality = 1
                break
            case NSLocalizedString("韩国", comment: "").decryptString():
                nationality = 2
                break
            case NSLocalizedString("欧美", comment: "").decryptString():
                nationality = 3
                break
            default:
                break
            }
        }else {
            switch title {
            case NSLocalizedString("男歌手", comment: "").decryptString():
                type = 1
                break
            case NSLocalizedString("女歌手", comment: "").decryptString():
                type = 2
                break
            case NSLocalizedString("组合", comment: "").decryptString():
                 type = 3
                break
            default:
                break
            }
        }
        if let b = sgmDidChangeBlock {
            b(xib_nameTF.text ?? "")
        }
    }
}

extension MPPopularHeaderView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if var text = textField.text, let d = sgmDidChangeBlock {
            var txt = ""
            
            if string == "", text != "" {
                text.removeLast()
                txt = text
            }else {
                txt = text + string
            }
            
            d(txt)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let b = sgmDidChangeBlock {
            b(xib_nameTF.text ?? "")
        }
        return true
    }
}
