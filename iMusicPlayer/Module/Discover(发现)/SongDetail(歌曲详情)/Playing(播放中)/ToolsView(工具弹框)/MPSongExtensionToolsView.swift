//
//  MPSongExtensionToolsView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPSongExtensionToolsView: TableBaseView {
    
    var delegate: MPSongToolsViewDelegate?

    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var xib_title: UILabel!
    
    var isShowMvOrMp3Mark: Bool = false
    var tempFirst: Any?
    
    var title: String = "" {
        didSet {
            xib_title.text = title
        }
    }
    
    var isShowMvOrMp3 = false {
        didSet {
            
            let data = groups as! NSMutableArray
            
            // 记录当前的会员特权项
            self.tempFirst = data.firstObject
            
            if !isShowMvOrMp3Mark {
                let index = self.isExsistFirstModel()
                if index != -1 {
                    data.remove(index)
                }
            }else {
                let index = self.isExsistFirstModel()
                if index == -1 {
                    data.insert(self.getMvOrMp3Model()!, at: 0)
                    tableView.reloadData()
                }
            }
        }
    }
    
    private func isExsistFirstModel() -> Int {
        var tempIndex = -1
        for index in 0..<(groups.count ?? 0) {
            let item = groups[index] as! NSDictionary
            if let items = item["items"] as? [[String : Any?]] {
                for item in items {
                    if let id = item["id"] as? String, id == "1" {
                        tempIndex = index
                    }
                }
            }
        }
        return tempIndex
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 将tableView重新布局
//        self.bringSubviewToFront(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(topLineView.snp.bottom)
            make.bottom.equalTo(bottomLineView.snp.top)
        }
    }
    
    // MARK: - 构造会员特权项
    private func getMvOrMp3Model(type: Int = -1) -> [String: Any?]? {
        let title = type == 0 ? NSLocalizedString("播放Mp3", comment: "") : NSLocalizedString("播放视频", comment: "")
        let tempDic = ["id": "1", "icon": "icon_add_to_next-1", "title": title, "accessoryType": "UIImageView", "accessoryView": "", "funcKey": "PlayMvOrMp3", "cellStyle": "value1", "subTitle": ""]
        let tempArr = [tempDic]
        
        let tempDicOutSide = ["items": tempArr]
        
        let tempArrOutSide = [tempDicOutSide]
        
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
