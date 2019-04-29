
//
//  MPDiscoverDataCent.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/24.
//  Copyright © 2019年 Modi. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON
import Alamofire

class MPDiscoverDataCent: HFDataCent {
//    /user/syncUserData?contact=1&reset=1&token=z%23master%40Music1.4.8&uid=1
//        {{music}}/user/syncUserData?token={{token}}&uid=MtyTnSfvidZnRohJWWzujIfF7Yq2&reset=1&contact=hrf82898@gmail.com
    
    var data_CloudListUploadModel: MPUserCloudListModel = MPUserCloudListModel()
    
    func requestSaveUserCloudList(contact: String, reset: Int = 1, uid: String, model: MPUserCloudListModel? = nil, complete:@escaping ((_ isSucceed: Bool, _ message: String) -> Void)) {
        
        let param = self.mappingToJson(model: data_CloudListUploadModel)
        
        let tempReset = self.getReset(model: data_CloudListUploadModel)
        
        let url = API.SaveUserCloudList + "?token=z%23master%40Music1.4.8&contact=\(contact)&reset=\(tempReset)&uid=\(uid)"
        
        HFNetworkManager.request(url: url, method: .post, parameters: param, requestHeader: AppCommon.JsonRequestHeader,
                                 encoding: JSONEncoding.default, description: "保存数据到云端") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, error!.localizedDescription)
                return
            }
            
            guard let status = resp?["status"].intValue else {return}
            guard let msg = resp?["errorMsg"].string else {return}
            
            // 请求失败时
            if status != 200 {
                complete(false, msg)
                return
            }
            
            //            guard let code = resp?["code"].string else {return}
            //            guard let dataArr = resp?["data"].arrayObject else {return}
            //            guard let dataDic = resp?["data"].dictionaryObject else {return}
            
            // 请求成功时
            complete(true, msg)
        }
    }
    
    private func getReset(model: MPUserCloudListModel) -> Int {
        if model.data_playlistReset == 0, model.data_customlistReset == 0, model.data_downloadReset == 0, model.data_favoriteReset == 0, model.data_historyReset == 0 {
            return 0
        }else {
             return 1
        }
    }
    
    private func mappingToJson(model: MPUserCloudListModel) -> [String: Any] {
        var customlistArr = [[String: Any]]()
        model.data_customlist?.forEach({ (item) in
            customlistArr.append(item.getJsonByCustom())
        })
        
        var downloadArr = [[String: Any]]()
        model.data_download?.forEach({ (item) in
            downloadArr.append(item.getJson())
        })
        
        var favoriteArr = [[String: Any]]()
        model.data_favorite?.forEach({ (item) in
            favoriteArr.append(item.getJson())
        })
        
        var historyArr = [[String: Any]]()
        model.data_history?.forEach({ (item) in
            historyArr.append(item.getJson())
        })
        
        var playlistArr = [[String: Any]]()
        model.data_playlist?.forEach({ (item) in
            playlistArr.append(item.getJson())
        })
        
        let dict: [String: Any] = [
            "customlist": customlistArr,
            "download": downloadArr,
            "favorite": favoriteArr,
            "history": historyArr,
            "playlist": playlistArr
        ]
        
        let json = JSON(dict)
//        QYTools.shared.Log(log: json.dictionaryValue)
        return json.dictionaryObject!
    }
    
//    /user/getUserData?contact=1294432350%40qq.com&token=z%23master%40Music1.4.8&uid=3C918520-B55F-4DD4-8D9F-D71CC9A38AD7
    
    /// 获取云端保存数据
    ///
    /// - Parameters:
    ///   - contact: 邮箱
    ///   - uid: UID
    ///   - complete: 回调
    func requestUserCloudList(contact: String = "", uid: String = "", complete:@escaping ((_ isSucceed: Bool, _ data: MPUserCloudListModel?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["contact": contact,"uid": uid]
        
        HFNetworkManager.request(url: API.UserCloudList, method: .get, parameters:param, description: "获取云端数据") { (error, resp) in
            
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
            
            let model: MPUserCloudListModel = Mapper<MPUserCloudListModel>().map(JSONObject: dataDic)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
//    /config/login?avatar=1&contact=1&did=1&name=1&token=ok&uid=1

    /// 登录保存用户信息
    ///
    /// - Parameters:
    ///   - name: 用户名
    ///   - avatar: 头像
    ///   - contact: 邮箱
    ///   - did: 用户ID
    ///   - uid: 设备ID
    ///   - complete: 回调
    func requestLogin(name: String = "", avatar: String = "", contact: String = "", did: String = "", uid: String = "", complete:@escaping ((_ isSucceed: Bool, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["name": name, "avatar": avatar,"contact": contact, "did": did, "uid": uid]
        
        HFNetworkManager.request(url: API.Login, method: .get, parameters:param, description: "登录：保存用户信息") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, error!.localizedDescription)
                return
            }
            
            guard let status = resp?["status"].intValue else {return}
            guard let msg = resp?["errorMsg"].string else {return}
            
            // 请求失败时
            if status != 200 {
                complete(false, msg)
                return
            }
            
            //            guard let code = resp?["code"].string else {return}
            //            guard let dataArr = resp?["data"].arrayObject else {return}
            //            guard let dataDic = resp?["data"].dictionaryObject else {return}
            
            // 保存用户信息
            self.localizationUserInfo(model: MPUserSettingHeaderViewModel(picture: avatar, name: name, email: contact, uid: uid, did: did))
            
            // 请求成功时
            complete(true,msg)
        }
    }
    
//    /playlists/getLyrics?name=%E7%B6%BB%E3%81%B3%E3%81%AE%E5%BD%B1&songId=486194220&token=z%23master%40Music1.4.8
    
    /// 搜索歌词
    ///
    /// - Parameters:
    ///   - name: 歌曲名
    ///   - songId: 歌曲ID
    ///   - complete: 回调
    func requestSearchLyrics(name: String = "", songId: String = "", complete:@escaping ((_ isSucceed: Bool, _ data: MPLyricsModel?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["name": name,"songId": songId]
        
        HFNetworkManager.request(url: API.SearchLyrics, method: .get, parameters:param, description: "搜索歌词") { (error, resp) in
            
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
            
            let model: MPLyricsModel = Mapper<MPLyricsModel>().map(JSONObject: dataDic)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
//    /playlists/getYoutubePlaylistItems?playlistId=PL5DkbtlaY8IyLg3AOjWcheija4y2N7vIr&token=z%23master%40Music1.4.8
    // MARK: - 通过后台搜索YouTube歌单
    var data_SongListByYoutube: MPYoutubeMVModel?
    
    /// 通过后台搜索YouTube歌单
    ///
    /// - Parameters:
    ///   - playlistId: 歌单ID
    ///   - pageToken: 下一页token
    ///   - complete: 回调
    func requestSearchSongListByYoutube(playlistId: String = "", pageToken: String = "", complete:@escaping ((_ isSucceed: Bool, _ data: MPYoutubeMVModel?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["playlistId": playlistId,"pageToken": pageToken]
        
        HFNetworkManager.request(url: API.SearchSongListByYoutube, method: .get, parameters:param, description: "通过后台搜索YouTube歌单") { (error, resp) in
            
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
            
            let model: MPYoutubeMVModel = Mapper<MPYoutubeMVModel>().map(JSONObject: dataDic)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
    // MARK: - 从Youtube获取播放列表
    var data_SearchSongList: [MPSongModel]?
    /// 联想关键词
    ///
    /// - Parameters:
    ///   - playlistId: 歌单ID
    ///   - size: 条数
    ///   - pageToken: 下一页token
    ///   - complete: 回调
    func requestSearchSongList(playlistId: String = "", size: Int = 20, pageToken: String = "", complete:@escaping ((_ isSucceed: Bool, _ data: [MPSongModel]?, _ message: String) -> Void)) {
        
//        part: snippet,contentDetails
//        order: date
//        type: playlist
//        maxResults: 20
//        playlistId: PLZu8GBv1kr1Gs8-fRP07YQsBrKhZbC4Yv
//        pageToken:
//        key: AIzaSyCx-gblQbbkQaFbBhqgu17HYKWZ01SVUQk
        
        let param: [String:Any] = ["part": "snippet,contentDetails", "order": "date","type": "playlist", "maxResults": size,"playlistId": playlistId, "pageToken": pageToken,"key": "AIzaSyCx-gblQbbkQaFbBhqgu17HYKWZ01SVUQk"]
        
        Alamofire.SessionManager.default.request(API.SearchSongList, method: HTTPMethod.get, parameters: param).responseJSON { (resp) in
//            QYTools.shared.Log(log: resp.result.value as! String)
            let rs = resp.result
            // 连接失败时
            if rs.error != nil {
                complete(false, nil, rs.error!.localizedDescription)
                return
            }
            
            // 请求失败时
            if !rs.isSuccess {
                complete(false,nil, "获取数据失败")
                return
            }
            
            guard let dataDic = rs.value else {return}
            
            let model: MPYoutubeModel = Mapper<MPYoutubeModel>().map(JSONObject: dataDic)!
            
            let temps = self.mappingToMPSongModel(models: model)
            
            // 请求成功时
            complete(true,temps,"成功")
        }
    }

    
    /// 将YouTube模型映射到本地模型
    ///
    /// - Parameter models: YouTube模型
    /// - Returns: 本地模型
    private func mappingToMPSongModel(models: MPYoutubeModel?) -> [MPSongModel] {
        var temps = [MPSongModel]()
        guard let model = models else { return temps }
        
        if let songs = model.data_items {
            songs.forEach { (song) in
                let dict: [String : Any] = ["id": song.data_snippet?.data_position,"originalId": song.data_contentDetails?.data_videoId,"songId": song.data_snippet?.data_resourceId,"heatIndex": 0.0,"singerName": song.data_snippet?.data_channelTitle,"title": song.data_snippet?.data_title,"cache": "","channelTitle": song.data_snippet?.data_channelTitle,"artworkUrl": song.data_snippet?.data_thumbnails?.data_default,"artworkBigUrl": song.data_snippet?.data_thumbnails?.data_high,"durationInSeconds": 0,"songName": song.data_snippet?.data_title]
                let tempM = Mapper<MPSongModel>().map(JSON: dict)
                temps.append(tempM!)
            }
        }
        
        return temps
    }
    
    
    // MARK: - 联想关键词
    var data_RelatedKeyword: [String]?
    /// 联想关键词
    ///
    /// - Parameters:
    ///   - q: 搜索关键词
    ///   - client: 客户端
    ///   - complete: 回调
    func requestRelatedKeyword(q: String = "", client: String = "firefox", complete:@escaping ((_ isSucceed: Bool, _ data: [String]?, _ message: String) -> Void)) {
        
//        let urlQ = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let param: [String:Any] = ["q": q, "client": client]
        
        Alamofire.SessionManager.default.request(API.RelatedKeyword, method: HTTPMethod.get, parameters: param).responseString { (resp) in
            if let temps = JSON(parseJSON: resp.result.value ?? "").arrayObject, temps.count > 0, let rs = temps[1] as? [String] {
                // 请求成功时
                complete(true, rs, "Succeed")
            }
        }
    }
    
//    /search/getAll?q=MM&size=20&token=z%23master%40Music1.4.8
    // MARK: - 搜索
    var data_SearchResult: MPSearchResultModel?
    
    /// 搜索
    ///
    /// - Parameters:
    ///   - q: 搜索关键字
    ///   - duration: 时长
    ///   - filter: 过滤条件
    ///   - order: 排序
    ///   - size: 每页显示条数
    ///   - y: 是否用 youtube 的 cached mp3 来补充，默认y=0
    ///   - complete: 回调
    func requestSearchResult(q: String = "", duration: String = "", filter: String = "", order: String = "", size: Int = 20, y: String = "0", complete:@escaping ((_ isSucceed: Bool, _ data: MPSearchResultModel?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["q": q,"duration": duration, "filter": filter, "order": order, "size": size, "y": y, "m": 1]
        
        HFNetworkManager.request(url: API.SearchResult, method: .get, parameters:param, description: "搜索") { (error, resp) in
            
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
            
            let model: MPSearchResultModel = Mapper<MPSearchResultModel>().map(JSONObject: dataDic)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
//    /search/getSongs?duration=any&filter=official&order=date&page=0&q=lemon&size=20&token=z%23master%40Music1.4.8&y=0
    
    /// 单独搜索MP3
    ///
    /// - Parameters:
    ///   - q: 关键词
    ///   - duration: 时长
    ///   - filter: 过滤
    ///   - order: 排序
    ///   - size: 条数
    ///   - y: 是否用MV来填充MP3
    ///   - page: 页码下标
    ///   - complete: 回调
    func requestSearchMp3(q: String = "", duration: String = "", filter: String = "", order: String = "", size: Int = 20, y: String = "0", page: Int = 0, complete:@escaping ((_ isSucceed: Bool, _ data: MPSearchResultModel?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["q": q,"duration": duration, "filter": filter, "order": order, "size": size, "y": y, "m": 1, "page": page]
        
        HFNetworkManager.request(url: API.SearchMp3, method: .get, parameters:param, description: "搜索") { (error, resp) in
            
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
            
            let model: MPSearchResultModel = Mapper<MPSearchResultModel>().map(JSONObject: dataDic)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
//    /search/getVideos?duration=any&filter=official&m=0&order=date&page=0&q=lemon&size=20&token=z%23master%40Music1.4.8
    
    /// 单独搜索YouTube MV
    ///
    /// - Parameters:
    ///   - q: 关键词
    ///   - duration: 时长
    ///   - filter: 过滤
    ///   - order: 排序
    ///   - size: 条数
    ///   - pageToken: 下一页token
    ///   - complete: 回调
    func requestSearchMV(q: String = "", duration: String = "", filter: String = "", order: String = "", size: Int = 20, pageToken: String = "", complete:@escaping ((_ isSucceed: Bool, _ data: MPSearchResultModel?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["q": q,"duration": duration, "filter": filter, "order": order, "size": size, "m": 1, "pageToken": pageToken]
        
        HFNetworkManager.request(url: API.SearchMV, method: .get, parameters:param, description: "搜索") { (error, resp) in
            
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
            
            let model: MPSearchResultModel = Mapper<MPSearchResultModel>().map(JSONObject: dataDic)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
//    /search/getPlaylists?duration=any&filter=official&order=date&q=lemon&size=20&token=z%23master%40Music1.4.8
    
    /// 单独搜索YouTube歌单列表
    ///
    /// - Parameters:
    ///   - q: 关键词
    ///   - duration: 时长
    ///   - filter: 过滤
    ///   - order: 排序
    ///   - size: 条数
    ///   - pageToken: 下一页token
    ///   - complete: 回调
    func requestSearchList(q: String = "", duration: String = "", filter: String = "", order: String = "", size: Int = 20, pageToken: String = "", complete:@escaping ((_ isSucceed: Bool, _ data: MPSearchResultModel?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["q": q,"duration": duration, "filter": filter, "order": order, "size": size, "m": 1, "pageToken": pageToken]
        
        HFNetworkManager.request(url: API.SearchList, method: .get, parameters:param, description: "搜索") { (error, resp) in
            
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
            
            let model: MPSearchResultModel = Mapper<MPSearchResultModel>().map(JSONObject: dataDic)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
//    /music/getSearchKeyword?token=z%23master%40Music1.4.8
    // MARK: - 搜索关键词
    var data_SearchKeyword: [MPSearchKeywordModel]?
    /// 搜索关键词
    ///
    /// - Parameters:
    ///   - complete: 回调
    func requestSearchKeyword(complete:@escaping ((_ isSucceed: Bool, _ data: [MPSearchKeywordModel]?, _ message: String) -> Void)) {
        
        let param: [String:Any] = [:]
        
        HFNetworkManager.request(url: API.SearchKeyword, method: .get, parameters:param, description: "搜索关键词") { (error, resp) in
            
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
            
            let model: [MPSearchKeywordModel] = Mapper<MPSearchKeywordModel>().mapArray(JSONObject: dataArr)!
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
//    /tracks/getRelated?id=EgmBmk7d8Yc&token=z%23master%40Music1.4.8
    // MARK: - 相关歌曲
    var data_RelatedSongs: [MPSongModel]?
    /// 电台
    ///
    /// - Parameters:
    ///   - type: 风格流派ID
    ///   - complete: 回调
    func requestRelatedSongs(id: String = "", complete:@escaping ((_ isSucceed: Bool, _ data: [MPSongModel]?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["id": id]
        
        HFNetworkManager.request(url: API.RelatedSongs, method: .get, parameters:param, description: "相关歌曲") { (error, resp) in
            
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
    
    //    /music/getFm?token=z%23master%40Music1.4.8&type=0
    // MARK: - 歌单列表：精选歌单、风格流派歌单
    var data_Radio: [MPSongModel]?
    /// 电台
    ///
    /// - Parameters:
    ///   - type: 风格流派ID
    ///   - complete: 回调
    func requestRadio(type: Int = 0, complete:@escaping ((_ isSucceed: Bool, _ data: [MPSongModel]?, _ message: String) -> Void)) {
        
        let param: [String:Any] = ["type": type]
        
        HFNetworkManager.request(url: API.Radio, method: .get, parameters:param, description: "电台") { (error, resp) in
            
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
    func requestLatest(type: String = "Japan", limit: Int = 20, offset: Int = 0,complete:@escaping ((_ isSucceed: Bool, _ data: [MPSongModel]?, _ message: String) -> Void)) {
        
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
    var data_Popular: [GeneralPlaylists]?
    
    /// 人气歌手
    ///
    /// - Parameters:
    ///   - nationality: 国籍
    ///   - type: 分类：全部、男、女、组合
    ///   - page: 第几页
    ///   - row: 每页条数
    ///   - complete: 回调
    func requestPopular(nationality: Int = 0, type: Int = 0, name: String = "", page: Int = 0, row: Int = 20,complete:@escaping ((_ isSucceed: Bool, _ data: [GeneralPlaylists]?, _ message: String) -> Void)) {
        
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
            
            let model: [GeneralPlaylists] = Mapper<GeneralPlaylists>().mapArray(JSONObject: dataArr)!
            
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
    
    /// 本地化用户基本信息
    ///
    /// - Parameter resp: -
    private func localizationUserInfo(model: MPUserSettingHeaderViewModel) {
        
        let arcObj = NSKeyedArchiver.archivedData(withRootObject: model)
        // 保存用户信息
        UserDefaults.standard.setValue(arcObj, forKey: "UserInfoModel")
        
        UserDefaults.standard.synchronize()
    }
    
}
