//
//  MPSongExtensionToolsView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let TableViewCellHeight: CGFloat = 44
    static let NotTabHeight = IPHONEX ? SCREEN_WIDTH * (91/375) + SaveAreaHeight : SCREEN_WIDTH * (91/375)
}

class MPSongExtensionToolsView: TableBaseView {
    
    var delegate: MPSongToolsViewDelegate?

    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var tableViewH: NSLayoutConstraint!
    
    @IBOutlet weak var xib_close: UIButton!
    
    var title: String = "" {
        didSet {
            xib_title.text = title
        }
    }
    
    var isShowMvOrMp3 = false {
        didSet {
            self.isExsistFirstModel()
        }
    }
    
    func updateTableViewHeight() {
        //获取组
        let group = groups.object(at: 0) as! NSDictionary
        let item = group["items"] as! NSArray
        tableViewH.constant = CGFloat(item.count) * Constant.TableViewCellHeight
        self.height = tableViewH.constant + Constant.NotTabHeight
    }
    
    private func isExsistFirstModel() {
        var tempIndex = -1
        for index in 0..<(groups.count ) {
            let item = NSMutableDictionary.init(dictionary: groups[index] as! NSDictionary)
            if var items = item["items"] as? [[String : Any?]] {
                for i in 0..<items.count {
                    var itemJ = items[i]
                    if let id = itemJ["id"] as? String, id == "1" {
                        tempIndex = i
                        if !isShowMvOrMp3 {
                            items.remove(at: i)
                            let tempItems = items
                            item["items"] = tempItems
                            let temps = NSMutableArray(array: groups)
                            temps[index] = item
                            groups = temps
                            return
                        }else {
                            // 修改当前的title
                            let title = SourceType == 0 ? NSLocalizedString("播放MP3", comment: "").decryptString() : NSLocalizedString("播放MV", comment: "").decryptString()
                            var t = itemJ
                            t["title"] = title
                            let tempItems = NSMutableArray(array: items)
                            tempItems[i] = t
                            item["items"] = tempItems
                            let temps = NSMutableArray(array: groups)
                            temps[index] = item
                            groups = temps
                        }
                    }
                }
            }
        }
        
        if tempIndex == -1, isShowMvOrMp3 {
            // 重新加载数据：items数据源
            var arr = NSArray()
            let path = Bundle.main.path(forResource: self.plistName, ofType: "plist")
            arr = NSArray(contentsOfFile: path!)!
//            debugPrint("arr --> \(arr)")
            for index in 0..<(arr.count ) {
                let item = NSMutableDictionary.init(dictionary: arr[index] as! NSDictionary)
                if var items = item["items"] as? [[String : Any?]] {
                    for i in 0..<items.count {
                        var itemJ = items[i]
                        if let id = itemJ["id"] as? String, id == "1" {
                            tempIndex = i
                            // 修改当前的title
                            let title = SourceType == 0 ? NSLocalizedString("播放MP3", comment: "").decryptString() : NSLocalizedString("播放MV", comment: "").decryptString()
                            var t = itemJ
                            t["title"] = title
                            let tempItems = NSMutableArray(array: items)
                            tempItems[i] = t
                            item["items"] = tempItems
                            let temps = NSMutableArray(array: arr)
                            temps[index] = item
                            groups = temps
                        }
                    }
                }
            }
        }
        
//        return tempIndex
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        xib_close.setTitle(NSLocalizedString("关闭", comment: "").decryptString(), for: .normal)
        
        // 将tableView重新布局
//        self.bringSubviewToFront(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(topLineView.snp.bottom)
            make.bottom.equalTo(bottomLineView.snp.top)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.removeFromWindow()
    }
    
    // MARK: - 构造会员特权项
    private func getMvOrMp3Model(type: Int = -1) -> [String: Any?]? {
        let title = type == 0 ? NSLocalizedString("播放MP3", comment: "").decryptString() : NSLocalizedString("播放MV", comment: "").decryptString()
        let tempDic = ["id": "1", "icon": "icon_add_to_next-1", "title": title, "accessoryType": "UIImageView", "accessoryView": "", "funcKey": "playVideo", "cellStyle": "value1", "subTitle": ""]
        let tempArr = [tempDic]
        
        let tempDicOutSide = ["items": tempArr]
        
        _ = [tempDicOutSide]
        
        return tempDicOutSide
    }
    
}
// MARK: - 点击事件
extension MPSongExtensionToolsView {
    
    /// 定时关闭
    @objc func timeOff() {
        if let d = self.delegate {
            d.timeOff!()
        }
    }
    /// 播放视频
    @objc func playVideo() {
        if let d = self.delegate {
            d.playVideo!()
        }
    }
    /// 歌曲信息
    @objc func songInfo() {
        if let d = self.delegate {
            d.songInfo!()
        }
    }
    
    /// 修改名称
    @objc func modifyAlbumName() {
        if let d = self.delegate {
            d.modifyAlbumName!()
        }
    }
    /// 删除歌单
    @objc func deleteSongList() {
        if let d = self.delegate {
            d.deleteSongList!()
        }
    }
}
