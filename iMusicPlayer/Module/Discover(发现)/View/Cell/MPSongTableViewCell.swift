//
//  MPSongTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/26.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

protocol MPSongTableViewCellDelegate {
    func addToSongList(song: MPSongModel?)
    func nextPlay(song: MPSongModel?)
    func addToPlayList(song: MPSongModel?)
    
    func addToMyFavorite(song: MPSongModel?)
}

class MPSongTableViewCell: UITableViewCell, ViewClickedDelegate {
    
    var delegate: MPSongTableViewCellDelegate?
    
    var clickBlock: ((Any?) -> ())?
    
    var favoriteBlock: ((_ currenSong: MPSongModel)->Void)?

    @IBOutlet weak var xib_image: UIImageView!
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    @IBOutlet weak var xib_collect: UIButton!
    @IBOutlet weak var xib_more: UIButton!
    
    var currentSong: MPSongModel?
    
    var currentSongList = [MPSongModel]()
    
    var currentAlbum: GeneralPlaylists?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // 用户点击的时候调用
        if selected {
            let vc = MPPlayingViewController()
            // 循序不能倒过来
            vc.currentSong = self.currentSong
            vc.model = self.currentSongList
            
            // 把当前的专辑添加到最近播放
            if let a = currentAlbum {
                if !MPModelTools.checkCollectListExsist(model: a, tableName: "RecentlyAlbum") {
                    MPModelTools.saveCollectListModel(model: a, tableName: "RecentlyAlbum")
                }else {
                    // 删除原来的并将当前的插入到第一位
                    let sql = String(format: "where %@=%@",bg_sqlKey("BG_data_title"),bg_sqlValue(a.data_title))
                    if NSArray.bg_delete("RecentlyAlbum", where: sql) {
                        // 添加到最后一项：获取的时候倒序即可
                        NSArray.bg_addObject(withName: "RecentlyAlbum", object: a)
                    }
                }
            }
            
            let nav = UINavigationController(rootViewController: vc)
            HFAppEngine.shared.currentViewController()?.present(nav, animated: true, completion: nil)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 清除状态
        xib_collect.isSelected = false
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if sender.tag == 10001 {
            // 添加到我的最爱列表
            if !MPModelTools.checkSongExsistInPlayingList(song: self.currentSong!, tableName: MPMyFavoriteViewController.classCode) {
                // 标记为收藏状态：喜爱列表、当前列表
                self.currentSong?.data_collectStatus = 1
                MPModelTools.saveSongToTable(song: self.currentSong!, tableName: MPMyFavoriteViewController.classCode)
                // 设置为收藏状态
                xib_collect.isSelected = true
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲收藏成功", comment: ""))
            }else {
                // 取消收藏
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已经收藏", comment: ""))
            }
        }else {
            let pv = MPSongToolsView.md_viewFromXIB() as! MPSongToolsView
            pv.plistName = "songTools"
            pv.delegate = self
            HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
        }
        
    }
    
    func updateCell(model: MPSongModel, models: [MPSongModel], album: GeneralPlaylists? = nil) {
        currentSongList = models
        currentSong = model
        currentAlbum = album
        //设置图片
        if let img = model.data_artworkBigUrl, img != "" {
            let imgUrl = API.baseImageURL + img
            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
        }
        
        if SourceType == 0 {
            xib_title.text = model.data_title
            xib_desc.text = model.data_channelTitle
        }else {
            xib_title.text = model.data_songName
            xib_desc.text = model.data_singerName
        }
        
        // 是否选中
//        if model.data_collectStatus == 1 {
//            xib_collect.isSelected = true
//        }
        
        // 异步更新当前收藏状态
        DispatchQueue.main.async {
            if MPModelTools.checkSongExsistInPlayingList(song: model, tableName: MPMyFavoriteViewController.classCode) {
                self.xib_collect.isSelected = true
            }
        }
        
    }
    
}
extension MPSongTableViewCell: MPSongToolsViewDelegate {
    func addToSongList() {
        let lv = MPAddToSongListView.md_viewFromXIB() as! MPAddToSongListView
        MPModelTools.getCollectListModel(tableName: MPCreateSongListViewController.classCode) { (model) in
            if let m = model {
                lv.model = m
            }
        }
        // 新建歌单
        lv.createSongListBlock = {
            let pv = MPCreateSongListView.md_viewFromXIB(cornerRadius: 4) as! MPCreateSongListView
            pv.clickBlock = {(sender) in
                if let btn = sender as? UIButton {
                    if btn.tag == 10001 {
                        pv.removeFromWindow()
                    }else {
                        // 新建歌单操作
                        if MPModelTools.createSongList(songListName: pv.xib_songListName.text ?? "") {
                            // 刷新数据
                            MPModelTools.getCollectListModel(tableName: MPCreateSongListViewController.classCode) { (model) in
                                if let m = model {
                                    lv.model = m
                                }
                            }
                        }else {
                            SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌单已存在", comment: ""))
                        }
                        pv.removeFromWindow()
                    }
                }
            }
            HFAlertController.showCustomView(view: pv)
        }
        
        // 加入歌单
        lv.addSongListBlock = {(songList) in
            if let song = self.currentSong, let tn = songList.data_title {
                if !MPModelTools.checkSongExsistInSongList(song: song, songList: songList) {
                    MPModelTools.saveSongToTable(song: self.currentSong!, tableName: tn)
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲添加成功", comment: ""))
                    // 更新当前歌单图片及数量：+1
                    MPModelTools.updateCountForSongList(songList: songList, finished: {
                        lv.removeFromWindow()
                    })
                }else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已在该歌单中", comment: ""))
                }
            }
        }
        
        HFAlertController.showCustomView(view: lv, type: HFAlertType.ActionSheet)
    }
    
    func nextPlay() {
        // 添加到播放列表的下一首: 判断是否在列表中：在则调换到下一首，不在则添加到下一首
        if !MPModelTools.checkSongExsistInPlayingList(song: self.currentSong!) {
            MPModelTools.getCurrentPlayList { (model, currentPlaySong) in
                if var m = model, let cs = currentPlaySong {
                    let index = self.getIndexFromSongs(song: cs, songs: m)
                    let nextIndex = (index+1)%m.count
                    m.insert(self.currentSong!, at: nextIndex)
                }
            }
        }else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已在播放列表中", comment: ""))
        }
    }
    
    func addToPlayList() {
        // 添加到播放列表: 判断是否在列表中：不在则添加
        if !MPModelTools.checkSongExsistInPlayingList(song: self.currentSong!) {
            MPModelTools.getCurrentPlayList { (model, currentPlaySong) in
                if var m = model {
                    m.append(self.currentSong!)
                }
            }
        }else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已在播放列表中", comment: ""))
        }
    }
    
    // 获取当前下标
    private func getIndexFromSongs(song: MPSongModel, songs: [MPSongModel]) -> Int {
        var index = 0
        for i in (0..<songs.count) {
            if song == songs[i] {
                index = i
            }
        }
        return index
    }
    
}
