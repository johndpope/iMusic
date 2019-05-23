//
//  MPSearchHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import TagListView

class MPSearchHeaderView: BaseView {
    
    @IBOutlet weak var xib_hot: UILabel!
    @IBOutlet weak var xib_history: UILabel!
    
    var itemClickedBlock: ((_ title: String) -> Void)?

    let tagDataSources = ["AKB48", "三浦大知", "星野源", "西野カナ", "中島愛", "米津玄师", "Winds" ]
    
    @IBOutlet weak var xib_tagListView: TagListView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        xib_hot.text = NSLocalizedString("人气搜索", comment: "").decryptString()
        xib_history.text = NSLocalizedString("搜索历史", comment: "").decryptString()
        
        xib_tagListView.addTags(tagDataSources)
        xib_tagListView.delegate = self
    }
    
    func updateTags(tags: [String], finished: ((_ tagsView: TagListView) -> Void)? = nil) {
        xib_tagListView.removeAllTags()
        xib_tagListView.addTags(tags)
        if let f = finished {
            f(xib_tagListView)
        }
    }
    
}

extension MPSearchHeaderView: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        QYTools.shared.Log(log: title)
        if let b = itemClickedBlock {
            b(title)
        }
    }
}
