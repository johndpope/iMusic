
//
//  MPDiscoverDataCent.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/24.
//  Copyright © 2019年 Modi. All rights reserved.
//

import Foundation
import ObjectMapper

class MPDiscoverDataCent: HFDataCent {
    
    //    /playlists/getSongs?m=0&singerId=9932&token=z%23master%40Music1.4.8
    // MARK: - 歌单列表：精选歌单、风格流派歌单
    var data_SongerListByID: [MPSongModel]?
    
    /// 歌手列表详细
    ///
    /// - Parameters:
    ///   - singerId: 歌手ID
    ///   - rows: 每页显示条数
    ///   - page: 页码
    ///   - complete: 回调
    func requestSongerListByID(singerId: String = "", rows: Int = 20, page: Int = 0, complete:@escaping ((_ isSucceed: Bool, _ data: [MPSongModel]?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["singerId": singerId, "rows": rows, "page": page]
        
        HFNetworkManager.request(url: API.SongerListByID, method: .get, parameters:param, description: "歌手列表详细") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, nil, error!.localizedDescription)
                return
            }
            
            guard let status = resp?["status"].intValue else {return}
            guard let msg = resp?["errorMsg"].string else {return}
            
            // 请求失败时
            if status != 200 {
                complete(false,nil, msg)
                return
            }
            
            //            guard let code = resp?["code"].string else {return}
            
//            guard let dataArr = resp?["data"].arrayObject else {return}
            guard let dataDic = resp?["data"].dictionaryObject else {return}
            guard let dataArr = dataDic["songs"] else {return}
            
            let model: [MPSongModel] = Mapper<MPSongModel>().mapArray(JSONObject: dataArr)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
    //    /playlists/getPlaylistItems?m=0&playlistId=2784&rows=10&start=0&token=z%23master%40Music1.4.8
    // MARK: - 歌单列表：精选歌单、风格流派歌单
    var data_SongListByID: [MPSongModel]?
    
    /// 歌单列表详细
    ///
    /// - Parameters:
    ///   - playlistId: 歌单ID
    ///   - rows: 每页显示条数
    ///   - start: 开始位置默认0
    ///   - complete: 回调
    func requestSongListByID(playlistId: Int = 0, rows: Int = 20, start: Int = 0, complete:@escaping ((_ isSucceed: Bool, _ data: [MPSongModel]?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["playlistId": playlistId, "rows": rows, "start": start]
        
        HFNetworkManager.request(url: API.SongListByID, method: .get, parameters:param, description: "歌单列表详细") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, nil, error!.localizedDescription)
                return
            }
            
            guard let status = resp?["status"].intValue else {return}
            guard let msg = resp?["errorMsg"].string else {return}
            
            // 请求失败时
            if status != 200 {
                complete(false,nil, msg)
                return
            }
            
            //            guard let code = resp?["code"].string else {return}
            
            guard let dataArr = resp?["data"].arrayObject else {return}
            //            guard let dataDic = resp?["data"].dictionaryObject else {return}
            
            let model: [MPSongModel] = Mapper<MPSongModel>().mapArray(JSONObject: dataArr)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
    //        /music/getYoutubeCate?m=0&rows=20&start=0&token=z%23master%40Music1.4.8&type=0
    
    // MARK: - 歌单列表：精选歌单、风格流派歌单
    var data_SongList: [GeneralPlaylists]?
    
    /// 歌单列表：精选歌单、风格流派歌单
    ///
    /// - Parameters:
    ///   - type: 歌单ID：精选歌单可以不传或0
    ///   - rows: 每页显示条数
    ///   - start: 开始位置默认0
    ///   - complete: 回调
    func requestSongList(type: Int = 0, rows: Int = 20, start: Int = 0, complete:@escaping ((_ isSucceed: Bool, _ data: [GeneralPlaylists]?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["type": type, "rows": rows, "start": start]
        
        HFNetworkManager.request(url: API.SongList, method: .get, parameters:param, description: "歌单列表：精选歌单、风格流派歌单") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, nil, error!.localizedDescription)
                return
            }
            
            guard let status = resp?["status"].intValue else {return}
            guard let msg = resp?["errorMsg"].string else {return}
            
            // 请求失败时
            if status != 200 {
                complete(false,nil, msg)
                return
            }
            
            //            guard let code = resp?["code"].string else {return}
            
            guard let dataArr = resp?["data"].arrayObject else {return}
//            guard let dataDic = resp?["data"].dictionaryObject else {return}
            
            let model: [GeneralPlaylists] = Mapper<GeneralPlaylists>().mapArray(JSONObject: dataArr)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
    //        app_id=com.musiczplayer.app&hl=ja&m=0&s=0&token=z%23master%40Music1.4.8
    
    // MARK: - 发现
    var data_Discover: MPDiscoverModel?
    func requestDiscover(complete:@escaping ((_ isSucceed: Bool, _ data: MPDiscoverModel?, _ message: String) -> Void)) {
        
        let param: [String:Any] = [:]
        
        HFNetworkManager.request(url: API.Discover, method: .get, parameters:param, description: "发现") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, nil, error!.localizedDescription)
                return
            }
            
            guard let status = resp?["status"].intValue else {return}
            guard let msg = resp?["errorMsg"].string else {return}
            
            // 请求失败时
            if status != 200 {
                complete(false,nil, msg)
                return
            }
            
//            guard let code = resp?["code"].string else {return}
            
            //            guard let dataArr = resp?["data"].arrayObject else {return}
            guard let dataDic = resp?["data"].dictionaryObject else {return}
            
            let model: MPDiscoverModel = Mapper<MPDiscoverModel>().map(JSONObject: dataDic)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
//    /discovery/getCharts?app_id=com.musiczplayer.app&limit=50&m=0&offset=15&source=Mnet&token=z%23master%40Music1.4.8
    
    // MARK: - 排行榜
    var data_Rank: [MPSongModel]?
    func requestRank(source: String = "Mnet", limit: Int = 20, offset: Int = 15,complete:@escaping ((_ isSucceed: Bool, _ data: [MPSongModel]?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["limit": limit, "offset": offset, "source":  source]
        
        HFNetworkManager.request(url: API.Rank, method: .get, parameters:param, description: "排行榜") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, nil, error!.localizedDescription)
                return
            }
            
            guard let status = resp?["status"].intValue else {return}
            guard let msg = resp?["errorMsg"].string else {return}
            
            // 请求失败时
            if status != 200 {
                complete(false,nil, msg)
                return
            }
            
            //            guard let code = resp?["code"].string else {return}
            
            guard let dataArr = resp?["data"].arrayObject else {return}
//            guard let dataDic = resp?["data"].dictionaryObject else {return}
            
            let model: [MPSongModel] = Mapper<MPSongModel>().mapArray(JSONObject: dataArr)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
//    /discovery/getLatest?m=0&token=z%23master%40Music1.4.8
    // MARK: - 最新发布
    var data_Latest: [MPSongModel]?
    
    /// 最新发布
    ///
    /// - Parameters:
    ///   - type: 接口默认是日文版,即：type=Japan。欧美：hl=Europe 韩国：Korea
    ///   - limit: 分页设置
    ///   - offset: 分页间隔
    ///   - complete: 完成回调
    func requestLatest(type: String = "Japan", limit: Int = 20, offset: Int = 15,complete:@escaping ((_ isSucceed: Bool, _ data: [MPSongModel]?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["limit": limit, "offset": offset, "type":  type]
        
        HFNetworkManager.request(url: API.Latest, method: .get, parameters:param, description: "最新发布") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, nil, error!.localizedDescription)
                return
            }
            
            guard let status = resp?["status"].intValue else {return}
            guard let msg = resp?["errorMsg"].string else {return}
            
            // 请求失败时
            if status != 200 {
                complete(false,nil, msg)
                return
            }
            
            //            guard let code = resp?["code"].string else {return}
            
            guard let dataArr = resp?["data"].arrayObject else {return}
            //            guard let dataDic = resp?["data"].dictionaryObject else {return}
            
            let model: [MPSongModel] = Mapper<MPSongModel>().mapArray(JSONObject: dataArr)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
    
    //    /playlists/getMusicSinger?m=0&nationality=0&token=z%23master%40Music1.4.8&type=0
    // MARK: - 人气歌手
    var data_Popular: [HotSingerPlaylists]?
    
    /// 人气歌手
    ///
    /// - Parameters:
    ///   - nationality: 国籍
    ///   - type: 分类：全部、男、女、组合
    ///   - page: 第几页
    ///   - row: 每页条数
    ///   - complete: 回调
    func requestPopular(nationality: Int = 0, type: Int = 0, name: String = "", page: Int = 0, row: Int = 20,complete:@escaping ((_ isSucceed: Bool, _ data: [HotSingerPlaylists]?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["page": page, "row": row, "type":  type, "nationality": nationality, "name": name]
        
        HFNetworkManager.request(url: API.Popular, method: .get, parameters:param, description: "人气歌手") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, nil, error!.localizedDescription)
                return
            }
            
            guard let status = resp?["status"].intValue else {return}
            guard let msg = resp?["errorMsg"].string else {return}
            
            // 请求失败时
            if status != 200 {
                complete(false,nil, msg)
                return
            }
            
            //            guard let code = resp?["code"].string else {return}
            
            guard let dataArr = resp?["data"].arrayObject else {return}
            //            guard let dataDic = resp?["data"].dictionaryObject else {return}
            
            let model: [HotSingerPlaylists] = Mapper<HotSingerPlaylists>().mapArray(JSONObject: dataArr)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
    //    /playlists/getCategory?token=z%23master%40Music1.4.8
    // MARK: - 风格流派
    var data_StyleGenre: MPStyleGenreModel?
    
    /// 风格流派
    ///
    /// - Parameter complete: 回调
    func requestStyleGenre(complete:@escaping ((_ isSucceed: Bool, _ data: MPStyleGenreModel?, _ message: String) -> Void)) {
        
        let param: [String:Any] = [:]
        
        HFNetworkManager.request(url: API.StyleGenre, method: .get, parameters:param, description: "风格流派") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, nil, error!.localizedDescription)
                return
            }
            
            guard let status = resp?["status"].intValue else {return}
            guard let msg = resp?["errorMsg"].string else {return}
            
            // 请求失败时
            if status != 200 {
                complete(false,nil, msg)
                return
            }
            
            //            guard let code = resp?["code"].string else {return}
            
//            guard let dataArr = resp?["data"].arrayObject else {return}
            guard let dataDic = resp?["data"].dictionaryObject else {return}
            
            let model: MPStyleGenreModel = Mapper<MPStyleGenreModel>().map(JSONObject: dataDic)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
}
