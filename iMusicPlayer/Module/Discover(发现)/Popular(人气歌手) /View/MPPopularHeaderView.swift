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

    private let countryTags = [NSLocalizedString("全部", comment: ""), NSLocalizedString("日本", comment: ""), NSLocalizedString("韩国", comment: ""), NSLocalizedString("欧美", comment: "")]
    @IBOutlet weak var xib_countryTagList: TagListView!
    
    
    private let categoryTags = [NSLocalizedString("全部", comment: ""), NSLocalizedString("男歌手", comment: ""), NSLocalizedString("女歌手", comment: ""), NSLocalizedString("组合", comment: "")]
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
            case NSLocalizedString("日本", comment: ""):
                nationality = 1
                break
            case NSLocalizedString("韩国", comment: ""):
                nationality = 2
                break
            case NSLocalizedString("欧美", comment: ""):
                nationality = 3
                break
            default:
                break
            }
        }else {
            switch title {
            case NSLocalizedString("男歌手", comment: ""):
                type = 1
                break
            case NSLocalizedString("女歌手", comment: ""):
                type = 2
                break
            case NSLocalizedString("组合", comment: ""):
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let b = sgmDidChangeBlock {
            b(xib_nameTF.text ?? "")
        }
        return true
    }
}
