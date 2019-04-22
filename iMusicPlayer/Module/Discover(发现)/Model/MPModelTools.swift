//
//  MPModelTools.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/26.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import ObjectMapper

class MPModelTools: NSObject {
    
    // MARK: - 公共存储歌曲列表：数组
    /// 保存歌曲到对应的表名中
    ///
    /// - Parameters:
    ///   - song: 歌曲
    ///   - tableName: 表名
    class func saveSongToTable(song: MPSongModel, tableName: String = "") {
        // 缓存
        ([song] as NSArray).bg_save(withName: tableName)
    }
    // MARK: - 公共获取歌曲列表：数组
    /// 获取对应歌曲列表
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - finished: 回调
    class func getSongInTable(tableName: String = "", finished: ((_ models: [MPSongModel]?)->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSongModel] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                f(arr)
            }
        }
    }
    
    // MARK: - 删除表中歌曲
    
    /// 删除表中歌曲
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - songs: 要删除的歌曲数组
    ///   - finished: 完成回调
    class func deleteSongInTable(tableName: String = "", songs: [MPSongModel], finished: (()->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSongModel] {
            for i in 0..<arr.count {
                var isExsist = false
                for j in 0..<songs.count {
                    if arr[i].data_title == songs[j].data_title {
                        isExsist = true
                    }
                }
                if isExsist {
                    NSArray.bg_deleteObject(withName: tableName, index: i)
                    QYTools.shared.Log(log: "歌曲\(i)删除成功")
                }
            }
//            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                f()
            }
        }
    }
    
    /// 更新表中歌曲信息
    ///
    /// - Parameters:
    ///   - song: 更新歌曲
    ///   - tableName: 表名
    ///   - finished: 回调
    class func updateSongInTable(song: MPSongModel,tableName: String = "", finished: (()->Void)? = nil) {
        getSongInTable(tableName: tableName) { (model) in
            if let m = model {
                for i in (0..<(m.count)) {
                    let item = m[i]
                    if item.data_title == song.data_title {
                        NSArray.bg_updateObject(withName: tableName, object: song, index: i)
                        QYTools.shared.Log(log: "歌曲收藏状态更新成功")
                        if let f = finished {
                            f()
                        }
                    }
                }
            }
        }
    }
    
    /// 更新专辑数量
    ///
    /// - Parameter songList: 当前专辑
    class func updateCountForSongList(songList: GeneralPlaylists, tableName: String = "", finished: (()->Void)? = nil) {
        let tableN = (tableName == "" ? (songList.data_title ?? "SongList") : tableName)
        if let arr = NSArray.bg_array(withName: tableN) as? [MPSongModel] {
            let count = arr.count
            getCollectListModel(tableName: MPCreateSongListViewController.classCode) { (model) in
                if let m = model {
                    for i in (0..<(m.count)) {
                        let item = m[i]
                        if item.data_title == tableN {
                            let tempM = item
                            tempM.data_title = songList.data_title
                            tempM.data_tracksCount = count
                            tempM.data_img = arr.first?.data_artworkUrl
                            NSArray.bg_updateObject(withName: MPCreateSongListViewController.classCode, object: tempM, index: i)
                            QYTools.shared.Log(log: "专辑图片及数量更新成功")
                            if let f = finished {
                                f()
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// 检查歌曲是否在该歌单中
    ///
    /// - Parameters:
    ///   - song: 歌曲
    ///   - tableName: 通过歌单获取的表名
    /// - Returns: 是否存在
    class func checkSongExsistInSongList(song: MPSongModel, songList: GeneralPlaylists) -> Bool {
        let tableName = songList.data_title ?? "SongList"
        var rs = false
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSongModel] {
//            QYTools.shared.Log(log: "本地数据库获取数据")
            arr.forEach { (item) in
                if item.data_title == song.data_title {
                    rs = true
                }
            }
        }
        return rs
    }
    
    /// 检查当前歌曲是否已经在播放列表中
    ///
    /// - Parameter song: 歌曲
    /// - Returns: 是否存在
    class func checkSongExsistInPlayingList(song: MPSongModel, tableName: String = "CurrentPlayList") -> Bool {
        var rs = false
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSongModel] {
//            QYTools.shared.Log(log: "本地数据库获取数据")
            arr.forEach { (item) in
                if item.data_id == song.data_id {
                    rs = true
                }
            }
        }
        return rs
    }
    
    /// 获取当前播放列表
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - finished: 回调
    class func getCurrentPlayList(tableName: String = "CurrentPlayList", finished: ((_ models: [MPSongModel]?, _ currentPlayingSong: MPSongModel?)->Void)? = nil) {
        var tempPlaySong: MPSongModel?
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSongModel] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            
            arr.forEach { (item) in
                if item.data_playingStatus == 1 {
                    tempPlaySong = item
                }
            }
            
            if let f = finished {
                f(arr, tempPlaySong)
            }
        }
    }
    
    /// 存储当前的播放列表
    ///
    /// - Parameters:
    ///   - currentList: 播放列表
    ///   - tableName: 表名
    class func saveCurrentPlayList(currentList: [MPSongModel], tableName: String = "CurrentPlayList") {
        // 缓存
        (currentList as NSArray).bg_save(withName: tableName)
    }
    
   /// 创建歌单
   ///
   /// - Parameters:
   ///   - songListName: 歌单名
   ///   - tableName: 表名
   /// - Returns: 是否创建成功
   class func createSongList(songListName: String = "newList", tableName: String = MPCreateSongListViewController.classCode) -> Bool {
        var rs = false
        let json: [String : Any] = ["img" : "pic_album_default", "id": 1, "title": songListName, "tracksCount": 0, "originalld": "", "type": ""]
        let model = Mapper<GeneralPlaylists>().map(JSON: json)
        let isExsist = MPModelTools.checkCollectListExsist(model: model!, tableName: tableName, condition: songListName)
        if !isExsist {
            MPModelTools.saveCollectListModel(model: model!, tableName: tableName)
            rs = true
        }else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌单已存在", comment: ""))
        }
        return rs
    }
    
    /// 收藏歌单、创建的歌单
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - finished: 回调
    class func getCollectListModel(tableName: String = GeneralPlaylists.classCode, finished: ((_ models: [GeneralPlaylists]?)->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [GeneralPlaylists] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                f(arr)
            }
        }
    }
    
    /// 删除收藏的歌单、创建的歌单
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - finished: 回调
    class func deleteCollectListModel(songList: GeneralPlaylists, tableName: String = GeneralPlaylists.classCode, finished: (()->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [GeneralPlaylists] {
            var index = -1
            for i in 0..<arr.count {
                if songList.data_title == arr[i].data_title {
                    index = i
                }
            }
            if index != -1 {
                if NSArray.bg_deleteObject(withName: tableName, index: index) {
                    if let f = finished {
                        f()
                    }
                }
            }
        }
    }
    
    /// 保存收藏歌单、创建的歌单
    ///
    /// - Parameters:
    ///   - model: 需要收藏的歌单
    ///   - tableName: 表名
    class func saveCollectListModel(model: GeneralPlaylists, tableName: String = GeneralPlaylists.classCode) {
        // 缓存
        ([model] as NSArray).bg_save(withName: tableName)
    }
    
    /// 检查当前歌单是否已经创建
    ///
    /// - Parameters:
    ///   - model: 当前歌单模型
    ///   - tableName: 表名
    ///   - condition: 查询条件：默认ID查询
    /// - Returns: 是否存在
    class func checkCollectListExsist(model: GeneralPlaylists, tableName: String = GeneralPlaylists.classCode, condition: String = "") -> Bool {
        var isExsist = false
        self.getCollectListModel(tableName: tableName) { (models) in
            if let m = models {
                m.forEach({ (item) in
                    if condition != "" {
                        if item.data_title == condition {
                            isExsist = true
                        }
                    }else {
                        if model.data_id == item.data_id {
                            isExsist = true
                        }
                    }
                })
            }
        }
        return isExsist
    }
    
    /// 检查当前歌单是否已经创建
    ///
    /// - Parameters:
    ///   - model: 当前歌单模型
    ///   - tableName: 表名
    ///   - condition: 查询条件：默认ID查询
    /// - Returns: 是否存在
    class func getCollectListExsistIndex(model: GeneralPlaylists, tableName: String = GeneralPlaylists.classCode, condition: String = "") -> Int {
        var index = -1
        self.getCollectListModel(tableName: tableName) { (models) in
            if let m = models {
                for i in (0..<m.count) {
                    let item = m[i]
                    if condition != "" {
                        if item.data_title == condition {
                            index = i
                        }
                    }else {
                        if model.data_id == item.data_id {
                            index = i
                        }
                    }
                }
            }
        }
        return index
    }
    
    /// 删除搜索词
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - model: 搜索关键字
    class func deleteHistoryModel(model: String) {
        let arr = getHistoryModels()
        let marr = NSMutableArray(array: arr)
        marr.remove(model)
        UserDefaults.standard.setValue((marr as! [String]), forKey: "HistoryKeys")
    }
    
    /// 保存最近搜索词
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - model: 搜索关键字
    class func saveHistoryModel(model: [String], finished: (()->Void)? = nil) {
        UserDefaults.standard.setValue(model, forKey: "HistoryKeys")
        UserDefaults.standard.synchronize()
    }
    
    /// 获取最近搜索数据
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - finished: 回调
    class func getHistoryModels() -> [String] {
        var temps = [String]()
        if let arr = UserDefaults.standard.value(forKey: "HistoryKeys") as? [String] {
            temps = arr
        }
        return temps
    }
    
    /// 获取搜索结果模块数据
    ///
    /// - Parameters:
    ///   - q: 搜索关键词
    ///   - duration: 时长：any, short, medium, long
    ///   - filter: 选择：official，preview
    ///   - order: relevance, date, videoCount
    ///   - size: 查询数目，默认size=20条
    ///   - y: 是否用 youtube 的 cached mp3 来补充，默认y=0
    ///   - tableName: 缓存必须传表名：空代表不缓存
    ///   - finished: 数据获取完成回调
    class func getSearchResult(q: String = "", duration: String = "", filter: String = "", order: String = "", size: Int = 20, y: String = "0", tableName: String = MPSearchResultModel.classCode, finished: ((_ models: MPSearchResultModel?)->Void)? = nil) {
        if let arr: [MPSearchResultModel]  = MPSearchResultModel.bg_findAll(tableName) as? [MPSearchResultModel], let model = arr.first {
            QYTools.shared.Log(log: "本地数据库获取数据")
//            printSQLiteData(arr: arr)
            if let f = finished {
                f(model)
            }
        }else {
            DiscoverCent?.requestSearchResult(q: q, duration: duration, filter: filter, order: order, size: size, y: y, complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished {
                        // 缓存数据库
                        model!.bg_tableName = tableName
                        model!.bg_save()
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    class func getRelatedKeyword(q: String = "", client: String = "firefox", finished: ((_ models: [String])->Void)? = nil) {
        DiscoverCent?.requestRelatedKeyword(q: q, client: client, complete: { (isSucceed, model, msg) in
            switch isSucceed {
            case true:
                if let f = finished {
                    f(model!)
                }
                break
            case false:
                SVProgressHUD.showError(withStatus: msg)
                break
            }
        })
    }
    
    /// 搜索关键词
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - finished: 回调
    class func getSearchKeywordModel(tableName: String = MPSearchKeywordModel.classCode, finished: ((_ models: [MPSearchKeywordModel]?)->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSearchKeywordModel] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                f(arr)
            }
        }else {
            DiscoverCent?.requestSearchKeyword(complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished, model!.count > 0 {
                        // 缓存
                        (model! as NSArray).bg_save(withName: tableName)
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    /// 相关歌曲
    ///
    /// - Parameters:
    ///   - id: 当前歌曲ID
    ///   - tableName: 表名
    ///   - finished: 回调
    class func getRelatedSongsModel(id: String = "", tableName: String = MPSongModel.classCode, finished: ((_ models: [MPSongModel]?)->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSongModel] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                f(arr)
            }
        }else {
            DiscoverCent?.requestRelatedSongs(id: id, complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished, model!.count > 0 {
                        // 缓存
                        (model! as NSArray).bg_save(withName: tableName)
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    
    static var data_RadioModels = [MPSongModel]()
    /// 电台
    ///
    /// - Parameters:
    ///   - type: 风格流派ID
    ///   - tableName: 表名
    ///   - finished: 回调
    class func getRadioModel(type: Int = 0, tableName: String = MPSongModel.classCode, location: Int = 1, finished: ((_ models: [MPSongModel]?)->Void)? = nil) {
        
        /**
         根据范围查询.
         */
//        NSArray* arr = [People bg_find:bg_tablename range:NSMakeRange(i,50) orderBy:nil desc:NO];
        
        /**
         直接写SQL语句操作.
         */
//        NSArray* arr = bg_executeSql(@"select * from yy", bg_tablename, [People class]);//查询时,后面两个参数必须要传入.
//        let str = "select * from \(tableName)"
//        let ar = bg_executeSql(str, tableName, NSArray.self)
        
//        if let arr = NSArray.bg_find(tableName, range: NSRange(location: location, length: 20), orderBy: nil, desc: false) as? [MPSongModel] {
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSongModel] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                data_RadioModels = arr
                f(arr)
                if arr.count > 1000 {
                    NSArray.bg_clear(withName: tableName)
                }
            }
        }else {
            DiscoverCent?.requestRadio(type: type, complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished, model!.count > 0 {
                        // 缓存
                        
//                        var temps = [String]()
//                        model?.forEach({ (item) in
//                            temps.append(item.data_cache ?? "--------------")
//                        })
                        data_RadioModels = model!
                        
                        (model! as NSArray).bg_save(withName: tableName)
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    /// 歌手列表详细
    ///
    /// - Parameters:
    ///   - singerId: 歌手ID
    ///   - tableName: 表名
    ///   - finished: 回调
    class func getSongerListByIDModel(singerId: String = "", tableName: String = MPSongModel.classCode, finished: ((_ models: [MPSongModel]?)->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSongModel] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                f(arr)
            }
        }else {
            DiscoverCent?.requestSongerListByID(singerId: singerId, complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished, model!.count > 0 {
                        // 缓存
                        (model! as NSArray).bg_save(withName: tableName)
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    /// 歌单列表详细
    ///
    /// - Parameters:
    ///   - playlistId: 歌单ID
    ///   - tableName: 表名
    ///   - finished: 回调
    class func getSongListByIDModel(playlistId: Int = 0, tableName: String = MPSongModel.classCode, finished: ((_ models: [MPSongModel]?)->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSongModel] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                f(arr)
            }
        }else {
            DiscoverCent?.requestSongListByID(playlistId: playlistId, complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished, model!.count > 0 {
                        // 缓存
                        (model! as NSArray).bg_save(withName: tableName)
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    /// 歌单列表
    ///
    /// - Parameters:
    ///   - typeID: 歌单ID
    ///   - tableName: 表名
    ///   - finished: 回调
    class func getSongListModel(typeID: Int = 0, tableName: String = GeneralPlaylists.classCode, finished: ((_ models: [GeneralPlaylists]?)->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [GeneralPlaylists] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                f(arr)
            }
        }else {
            DiscoverCent?.requestSongList(type: typeID, complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished, model!.count > 0 {
                        // 缓存
                        (model! as NSArray).bg_save(withName: tableName)
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    /// 风格流派
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - finished: 回调
    class func getStyleGenreModel(tableName: String = Genre.classCode, finished: ((_ models: MPStyleGenreModel?)->Void)? = nil) {
        if let arr: [MPStyleGenreModel]  = MPStyleGenreModel.bg_findAll(tableName) as? [MPStyleGenreModel], let model = arr.first {
            QYTools.shared.Log(log: "本地数据库获取数据")
            printSQLiteData(arr: arr)
            if let f = finished {
                f(model)
            }
        }else {
            DiscoverCent?.requestStyleGenre(complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished {
                        // 缓存数据库
                        model!.bg_tableName = tableName
                        model!.bg_save()
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    /// 人气歌手
    ///
    /// - Parameters:
    ///   - name: 歌手名字
    ///   - nationality: 国籍
    ///   - type: 类型：男、女、组合
    ///   - tableName: 缓存表名
    ///   - finished: 回调
    class func getPopularModel(songerName name: String = "", nationality: Int = 0, type: Int = 0, tableName: String = "PopularModel", finished: ((_ models: [GeneralPlaylists]?)->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [GeneralPlaylists] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                f(arr)
            }
        }else {
            DiscoverCent?.requestPopular(nationality: nationality, type: type, name: name, complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished, model!.count > 0 {
                        // 缓存
                        (model! as NSArray).bg_save(withName: tableName)
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    /// 最新发布
    ///
    /// - Parameters:
    ///   - source: 资源类型：MV/MP3
    ///   - tableName: 当前存储的数组标识
    ///   - finished: 数据获取完成回调
    class func getLatestModel(latestType type: String = "", tableName: String, finished: ((_ models: [MPSongModel]?)->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSongModel] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                f(arr)
            }
        }else {
            DiscoverCent?.requestLatest(type: type, complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished, model!.count > 0 {
                        // 缓存
                        (model! as NSArray).bg_save(withName: tableName)
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    /// 排行榜数据
    ///
    /// - Parameters:
    ///   - source: 资源类型：MV/MP3
    ///   - tableName: 当前存储的数组标识
    ///   - finished: 数据获取完成回调
    class func getRankingModel(rankType source: String = "", tableName: String,finished: ((_ models: [MPSongModel]?)->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [MPSongModel] {
            QYTools.shared.Log(log: "本地数据库获取数据")
            if let f = finished {
                f(arr)
            }
        }else {
            DiscoverCent?.requestRank(source: source, complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished, model!.count > 0 {
                        // 缓存
                        (model! as NSArray).bg_save(withName: tableName)
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    /// 获取发现模块数据
    ///
    /// - Parameter finished: 数据获取完成回调
    class func getDiscoverModel(finished: ((_ models: MPDiscoverModel?)->Void)? = nil) {
        if let arr: [MPDiscoverModel]  = MPDiscoverModel.bg_findAll(MPDiscoverModel.classCode + "\(SourceType)") as? [MPDiscoverModel], let model = arr.first {
            QYTools.shared.Log(log: "本地数据库获取数据")
            
            printSQLiteData(arr: arr)
            if let f = finished {
                f(model)
            }
        }else {
            DiscoverCent?.requestDiscover(complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    if let f = finished {
                        // 缓存数据库
                        model!.bg_tableName = MPDiscoverModel.classCode + "\(SourceType)"
                        model!.bg_save()
                        f(model)
                    }
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    /// 打印从数据库中读取的b模型表
    ///
    /// - Parameter arr: 模型数组
    class func printSQLiteData<T: BaseModel>(arr: [T]) {
        let tableName = MPDiscoverModel.classCode
        print("表名称：\(tableName)")
        
        /**
         当数据量巨大时采用分页范围查询.
         */
        _ = T.bg_count(tableName, where: nil)
        //        for i in stride(from: 0, to: count, by: 50) {
        //            let arr: [T] = T.bg_find(tableName, range: NSRange(location: i+1, length: 50), orderBy: nil, desc: false) as! [T]
        //
        //            for m: T in arr {
        //                print("····················································")
        //                print("主键 = \(m.bg_id), 表名 = \(m.bg_tableName), 创建时间 = \(m.bg_createTime), 更新时间 = \(m.bg_updateTime), 数据 = \(m.getPropertiesAndValues())")
        //                print("========================")
        //            }
        //            //顺便取第一个对象数据测试
        //            if(i==0){
        //                let m = arr.last
        //                print("第一个对象数据 ========================\(m?.getPropertiesAndValues())")
        //            }
        //        }
        
        T.bg_findAllAsync(tableName) { (models) in
            if let arr = models as? [T] {
                for m: T in arr {
                    print("····················································")
                    print("主键 = \(m.bg_id), 表名 = \(m.bg_tableName), 创建时间 = \(m.bg_createTime), 更新时间 = \(m.bg_updateTime), 数据 = \(m.getPropertiesAndValues())")
                    print("========================")
                }
            }
        }
    }
}
