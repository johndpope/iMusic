//
//  MPSearchResultHeaderView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/20.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import TagListView

class MPSearchResultHeaderView: UITableViewCell {
    
    var segmentChangeBlock: ((_ index: Int)->Void)?
    
    var defaultConditionH: CGFloat = 0
    var defaultTimeTagsH: CGFloat = 0
    var defaultFileter: Bool = false
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
    
    
    @IBOutlet weak var timeTagsH: NSLayoutConstraint! {
        didSet {
            defaultTimeTagsH = timeTagsH.constant
        }
    }
    private let timeTags = [NSLocalizedString("不限", comment: ""), NSLocalizedString("< 4 min", comment: ""), NSLocalizedString("4 min - 20 min", comment: ""), NSLocalizedString(" > 20 min", comment: "")]
    @IBOutlet weak var xib_timeTagList: TagListView!
    
    
    private let selectTags = [NSLocalizedString("非视听", comment: ""), NSLocalizedString("官方", comment: "")]
    @IBOutlet weak var xib_selectTagList: TagListView!
    
    private let sortTags = [NSLocalizedString("相关程度", comment: ""), NSLocalizedString("发布时间", comment: ""), NSLocalizedString("播放次数", comment: "")]
    @IBOutlet weak var xib_sortTagList: TagListView!
    
    @IBOutlet weak var conditionViewH: NSLayoutConstraint! {
        didSet {
            defaultConditionH = conditionViewH.constant
        }
    }
    @IBOutlet weak var conditionView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        segment.addTarget(self, action: #selector(segmentChanged(seg:)), for: .valueChanged)
        
        xib_timeTagList.addTags(timeTags)
        xib_selectTagList.addTags(selectTags)
        xib_sortTagList.addTags(sortTags)
        
        xib_timeTagList.tagViews.first!.isSelected = true
        xib_selectTagList.tagViews.first!.isSelected = true
        xib_sortTagList.tagViews.first!.isSelected = true
        
        songStyle()
    }

    @IBAction func filterDidClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        defaultFileter = sender.isSelected
        if defaultFileter {
            if segment.selectedSegmentIndex == 1 {
                mvStyle()
            }else if segment.selectedSegmentIndex == 2 {
                songListStyle()
            }else {
                songStyle()
            }
        }else {
            songStyle()
        }
    }
}
extension MPSearchResultHeaderView {
    
    @objc func segmentChanged(seg: UISegmentedControl) {
        // 筛选是否选中
        if defaultFileter {
            switch seg.selectedSegmentIndex {
            case 0: // 单曲
                songStyle()
                break
            case 1: // MV
                mvStyle()
                break
            case 2: // 歌单
                songListStyle()
                break
            default:
                break
            }
        }
        // 回调
        if let b = segmentChangeBlock {
            b(segment.selectedSegmentIndex)
        }
    }
    
    private func songStyle() {
        conditionViewH.constant = 0
        conditionView.isHidden = true
        
        self.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(59/375)))
    }
    
    private func mvStyle() {
        
        conditionViewH.constant = defaultConditionH
        conditionView.isHidden = false
        timeTagsH.constant = defaultTimeTagsH
        
        timeLabel.isHidden = false
        xib_timeTagList.isHidden = false
        selectLabel.isHidden = false
        xib_selectTagList.isHidden = false
        
        self.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(179/375)))
    }
    
    private func songListStyle() {
        
        conditionViewH.constant = 48
        conditionView.isHidden = false
        timeTagsH.constant = 0
        
        timeLabel.isHidden = true
        xib_timeTagList.isHidden = true
        selectLabel.isHidden = true
        xib_selectTagList.isHidden = true
        
        self.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(107/375)))
    }
}
