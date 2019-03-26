//
//  MPModelTools.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/26.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPModelTools: NSObject {
    
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
    class func getPopularModel(songerName name: String = "", nationality: Int = 0, type: Int = 0, tableName: String = "PopularModel", finished: ((_ models: [HotSingerPlaylists]?)->Void)? = nil) {
        if let arr = NSArray.bg_array(withName: tableName) as? [HotSingerPlaylists] {
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
        if let arr: [MPDiscoverModel]  = MPDiscoverModel.bg_findAll(MPDiscoverModel.classCode) as? [MPDiscoverModel], let model = arr.first {
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
                        model!.bg_tableName = MPDiscoverModel.classCode
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
