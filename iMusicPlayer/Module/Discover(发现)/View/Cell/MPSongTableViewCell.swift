//
//  MPSongTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/26.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let smallPlayerWidth = SCREEN_HEIGHT * (90/667)
    static let sbReduceHeight = SCREEN_WIDTH * (58/375)
    static let smallPlayerHeight = SCREEN_WIDTH * (48/375)
}

protocol MPSongTableViewCellDelegate {
    func addToSongList(song: MPSongModel?)
    func nextPlay(song: MPSongModel?)
    func addToPlayList(song: MPSongModel?)
    
    func addToMyFavorite(song: MPSongModel?)
}

class MPSongTableViewCell: UITableViewCell, ViewClickedDelegate {
    
    var extView: MPSongToolsView!
    
    var delegate: MPSongTableViewCellDelegate?
    
    var clickBlock: ((Any?) -> ())?
    
    var favoriteBlock: ((_ currenSong: MPSongModel)->Void)?

    @IBOutlet weak var xib_image: UIImageView! {
        didSet {
            xib_image.md_cornerRadius = 2
            xib_image.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_desc: UILabel!
    @IBOutlet weak var xib_collect: UIButton! {
        didSet {
            // 扩大按钮热区
            xib_collect.touchAreaInsets = UIEdgeInsets(top: 14, left: 8, bottom: 14, right: 4)
        }
    }
    @IBOutlet weak var xib_more: UIButton! {
        didSet {
            // 扩大按钮热区
            xib_more.touchAreaInsets = UIEdgeInsets(top: 14, left: 8, bottom: 14, right: 12)
        }
    }
    
    var currentSong: MPSongModel?
    
    var currentSongList = [MPSongModel]()
    
    var currentAlbum: GeneralPlaylists?
    
    var sourceType = -1
    
    var MVOrMP3: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // 用户点击的时候调用
        if selected {
            if let album = currentAlbum {
                album.data_songs = currentSongList
                MPModelTools.saveRecentlyAlbum(album: album)
            }
            
            let index = getIndexFromSongs(song: currentSong!, songs: currentSongList)
            currentSongList[index].data_playingStatus = 1
            
            MPModelTools.saveCurrentPlayList(currentList: currentSongList)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, userInfo: ["randomMode" : 0])
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 清除状态
        xib_collect.isSelected = false
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if sender.tag == 10001 {
            if BOOL_OPEN_MUSIC_DL, self.sourceType == -1, MVOrMP3 == 1 {
                download()
            }else {
                collection()
            }
        }else {
            let pv = MPSongToolsView.md_viewFromXIB() as! MPSongToolsView
            pv.plistName = "songTools"
            extView = pv
            pv.delegate = self
            if let song = currentSong {
                pv.title = MPModelTools.getTitleByMPSongModel(model: song)
            }
            HFAlertController.showCustomView(view: pv, type: HFAlertType.ActionSheet)
        }
        
    }
    
    /// 收藏
    private func collection() {
        // 添加到我的最爱列表
        if !MPModelTools.checkSongExsistInPlayingList(song: self.currentSong!, tableName: MPMyFavoriteViewController.classCode) {
            // 标记为收藏状态：喜爱列表、当前列表
            self.currentSong?.data_collectStatus = 1
            MPModelTools.saveSongToTable(song: self.currentSong!, tableName: MPMyFavoriteViewController.classCode)
            // 设置为收藏状态
            xib_collect.isSelected = true
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("收藏成功", comment: ""))
        }else {
            guard let song = self.currentSong else {
                return
            }
            MPModelTools.deleteSongInTable(tableName: MPMyFavoriteViewController.classCode, songs: [song]) {
                // 标记为收藏状态：喜爱列表、当前列表
                song.data_collectStatus = 0
                // 设置为收藏状态
                self.xib_collect.isSelected = false
                // 取消收藏
//                SVProgressHUD.showInfo(withStatus: NSLocalizedString("取消收藏", comment: ""))
            }
        }
        // 更新上传模型
        MPModelTools.updateCloudListModel(type: 2)
        // 通知更新列表数据
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_RefreshLocalModels), object: nil)
    }
    
    /// 下载
    private func download() {
        if let song = self.currentSong, !xib_collect.isSelected {
            MPDownloadTools.downloadMusicWithSongId(model: song)
            GKDownloadManager.sharedInstance()?.delegate = self
        }
    }
    
    func updateCell(model: MPSongModel, models: [MPSongModel], album: GeneralPlaylists? = nil, sourceType: Int = -1) {
        currentSongList = models
        currentSong = model
        currentAlbum = album
        
        self.sourceType = sourceType
        
        //设置图片
        let img = model.data_artworkBigUrl ?? model.data_artworkUrl ?? ""
        if img.contains("http") {
            let imgUrl = API.baseImageURL + img
            xib_image.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "pic_album"))
        }else {
            let path = model.data_artworkBigUrl ?? model.data_artworkUrl ?? ""
            xib_image.image = UIImage(named: path) == nil ? #imageLiteral(resourceName: "pic_album") : UIImage(named: path)
        }

        if let sid = model.data_songId, sid != "", let cache = model.data_cache, cache != "" {   // MP3
            MVOrMP3 = 1
            xib_title.text = model.data_songName
            xib_desc.text = model.data_singerName
            if BOOL_OPEN_MUSIC_DL, sourceType == -1 {
                xib_collect.setImage(#imageLiteral(resourceName: "icon_download_default_1"), for: .normal)
                xib_collect.setImage(#imageLiteral(resourceName: "icon_download_finish_1"), for: .selected)
            }else {
                xib_collect.setImage(#imageLiteral(resourceName: "icon_collect_normal"), for: .normal)
                xib_collect.setImage(#imageLiteral(resourceName: "icon_collect_selected"), for: .selected)
            }
        }else {     // MV
            MVOrMP3 = 0
            xib_title.text = model.data_title
            xib_desc.text = model.data_channelTitle
            
            xib_collect.setImage(#imageLiteral(resourceName: "icon_collect_normal"), for: .normal)
            xib_collect.setImage(#imageLiteral(resourceName: "icon_collect_selected"), for: .selected)
        }
        
        // 异步更新当前收藏状态
        DispatchQueue.main.async {
            if BOOL_OPEN_MUSIC_DL, self.sourceType == -1, let song = self.currentSong, self.MVOrMP3 == 1 {
                if MPModelTools.checkSongExsistInDownloadList(song: song) {
                    self.xib_collect.isSelected = true
                }
            }else {
                if MPModelTools.checkSongExsistInPlayingList(song: model, tableName: MPMyFavoriteViewController.classCode) {
                    self.xib_collect.isSelected = true
                }
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
                            
                            // 更新上传模型
                            MPModelTools.updateCloudListModel(type: 4)
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
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("成功添加歌单", comment: ""))
                    // 更新当前歌单图片及数量：+1
                    MPModelTools.updateCountForSongList(songList: songList, finished: {
                        lv.removeFromWindow()
                    })
                    
                    // 更新上传模型
                    MPModelTools.updateCloudListModel(type: 4)
                }else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已经收录到歌单了", comment: ""))
                }
            }
        }
        
        HFAlertController.showCustomView(view: lv, type: HFAlertType.ActionSheet)
    }
    
    func nextPlay() {
            // 调换一下位置
            MPModelTools.getCurrentPlayList { (model, currentPlaySong) in
                var m = model
                if let cs = currentPlaySong {
                    let index = self.getIndexFromSongs(song: cs, songs: m)
                    let nextIndex = (index+1)%m.count
    
                    // 添加到播放列表的下一首: 判断是否在列表中：在则调换到下一首，不在则添加到下一首
                    if MPModelTools.checkSongExsistInPlayingList(song: self.currentSong!) {
                        let csi = self.getIndexFromSongs(song: self.currentSong!, songs: m)
                        m.remove(at: csi)
                    }
    
                    m.insert(self.currentSong!, at: nextIndex)
                    // 保存到当前播放列表
                    MPModelTools.saveCurrentPlayList(currentList: m)
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("已添加，下一首播放", comment: ""))
                    self.extView.removeFromWindow()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, userInfo: ["needPlay" : 0])
                }
            }
    
    }
    
    func addToPlayList() {
        // 添加到播放列表: 判断是否在列表中：不在则添加
        if !MPModelTools.checkSongExsistInPlayingList(song: self.currentSong!) {
            MPModelTools.getCurrentPlayList { (model, currentPlaySong) in
                var m = model
                m.append(self.currentSong!)
                // 保存到当前播放列表
                MPModelTools.saveCurrentPlayList(currentList: m)
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("已加入到播放列表", comment: ""))
                self.extView.removeFromWindow()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, userInfo: ["needPlay" : 0])
            }
        }else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("已加入到播放列表", comment: ""))
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
// MARK: - 下载相关代理事件
extension MPSongTableViewCell: GKDownloadManagerDelegate {
    func gkDownloadManager(_ downloadManager: GKDownloadManager!, downloadModel: GKDownloadModel!, stateChanged state: GKDownloadManagerState) {
        if state == .finished {
            xib_collect.isSelected = true
        }
    }
}
