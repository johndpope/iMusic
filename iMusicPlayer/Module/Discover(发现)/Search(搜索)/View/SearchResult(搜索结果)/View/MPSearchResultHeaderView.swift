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
    var frameChangeBlock: (()->Void)?
    
    var duration: String = "any"  // 时长：any, short, medium, long
    var filter: String = ""  // 选择："", official, preview, 可多选： "official, preview"
    var tempFilterArr = [String]()
    var order: String = "relevance"  // 排序：relevance, date, videoCount
    
//    var itemClickedBlock: ((_ duration: String, _ filter: String, _ order: String) -> Void)?
    var itemClickedBlock: ((_ duration: String, _ filter: String, _ order: String, _ segIndex: Int) -> Void)?
    
    var defaultConditionH: CGFloat = 0
    var defaultTimeTagsH: CGFloat = 0
    var defaultTimeTagTop: CGFloat = 0
    var defaultSelectTagTop: CGFloat = 0
    var defaultSelectTagBottom: CGFloat = 0
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
    @IBOutlet weak var selectTagTop: NSLayoutConstraint!{
        didSet {
            defaultSelectTagTop = selectTagTop.constant
        }
    }
    @IBOutlet weak var selectTagBottom: NSLayoutConstraint!{
        didSet {
            defaultSelectTagBottom = selectTagBottom.constant
        }
    }
    @IBOutlet weak var timeTagTop: NSLayoutConstraint!{
        didSet {
            defaultTimeTagTop = timeTagTop.constant
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
//        xib_selectTagList.tagViews.first!.isSelected = true
        xib_sortTagList.tagViews.first!.isSelected = true
        
        xib_timeTagList.delegate = self
        xib_selectTagList.delegate = self
        xib_sortTagList.delegate = self
        
        songStyle()
    }

    @IBAction func filterDidClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
//        sender.imageView?.trans180DegreeAnimation()
        
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
        // 回调
        if let b = frameChangeBlock {
            b()
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
        
        if let b = itemClickedBlock {
            b(duration, filter, order, segment.selectedSegmentIndex)
        }
        
        // 回调
        if let b = frameChangeBlock {
            b()
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
        selectTagTop.constant = defaultSelectTagTop
//        selectTagBottom.constant = defaultSelectTagBottom
        timeTagTop.constant = defaultTimeTagTop
        
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
        selectTagTop.constant = 0
//        selectTagBottom.constant = 0
        timeTagTop.constant = 0
        
        timeLabel.isHidden = true
        xib_timeTagList.isHidden = true
        selectLabel.isHidden = true
        xib_selectTagList.isHidden = true
        
        self.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(107/375)))
    }
    
    private func resetStyle(sender: TagListView) {
        sender.tagViews.forEach { (tagv) in
            tagv.isSelected = false
        }
    }
}
extension MPSearchResultHeaderView: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        switch sender {
        case xib_timeTagList:
//            QYTools.shared.Log(log: title)
            switch tagView {
            case sender.tagViews[0]:
                duration = "any"  // any, short, medium, long
                break
            case sender.tagViews[1]:
                duration = "short"  // any, short, medium, long
                break
            case sender.tagViews[2]:
                duration = "medium"  // any, short, medium, long
                break
            case sender.tagViews[3]:
                duration = "long"  // any, short, medium, long
                break
            default:
                break
            }
            tagSelected(title, tagView: tagView, sender: sender)
            break
        case xib_selectTagList:
//            QYTools.shared.Log(log: title)
            // 选择："", official, preview, 可多选： "official, preview"
            tagView.isSelected = !tagView.isSelected
            if tagView == sender.tagViews[0] {
                if tagView.isSelected {
                    if !tempFilterArr.contains("preview") {
                        tempFilterArr.append("preview")
                    }
                }else {
                    if tempFilterArr.contains("preview") {
                        tempFilterArr.remove(at: tempFilterArr.firstIndex(of: "preview") ?? 0)
                    }
                }
            }else {
                if tagView.isSelected {
                    if !tempFilterArr.contains("official") {
                        tempFilterArr.append("official")
                    }
                }else {
                    if tempFilterArr.contains("official") {
                        tempFilterArr.remove(at: tempFilterArr.firstIndex(of: "official") ?? 0)
                    }
                }
            }
            filter = tempFilterArr.joined(separator: ",")
            if let b = itemClickedBlock {
                b(duration, filter, order, segment.selectedSegmentIndex)
            }
            break
        case xib_sortTagList:
//            QYTools.shared.Log(log: title)
            switch tagView {
            case sender.tagViews[0]:
                order = "relevance"  // 排序：relevance, date, videoCount
                break
            case sender.tagViews[1]:
                order = "date"  // 排序：relevance, date, videoCount
                break
            case sender.tagViews[2]:
                order = "videoCount"  // 排序：relevance, date, videoCount
                break
            default:
                break
            }
            tagSelected(title, tagView: tagView, sender: sender)
            break
        default:
            break
        }
    }
    
    private func tagSelected(_ title: String, tagView: TagView, sender: TagListView) {
        resetStyle(sender: sender)
        tagView.isSelected = !tagView.isSelected
        if let b = itemClickedBlock {
             b(duration, filter, order, segment.selectedSegmentIndex)
        }
    }
}
