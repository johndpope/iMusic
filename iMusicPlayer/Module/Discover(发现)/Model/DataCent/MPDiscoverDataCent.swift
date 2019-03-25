
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
    // MARK: - 发现
    var data_Discover: MPDiscoverModel?
    func requestDiscover(complete:@escaping ((_ isSucceed: Bool, _ data: MPDiscoverModel?, _ message: String) -> Void)) {
//        app_id=com.musiczplayer.app&hl=ja&m=0&s=0&token=z%23master%40Music1.4.8
        let app_id = BundleName // 包名
        let hl = "ja" // 日文版、en: 英文版
        let m = 1 // 0: MV 1: MP3
        let s = 0
        let token = "z#master@Music1.4.8"
        
        let param: [String:Any] = ["app_id": app_id, "hl": hl, "m": m, "s": s, "token": token]
        
//        let param: [String:Any] = ["m": m, "s": s]
        
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
            model.bg_tableName = NSStringFromClass(MPDiscoverModel.self).components(separatedBy: ".").last!
//            QYTools.shared.Log(log: model.getPropertiesAndValues().description)
            model.bg_save()
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
    
//    /discovery/getCharts?app_id=com.musiczplayer.app&limit=50&m=0&offset=15&source=Mnet&token=z%23master%40Music1.4.8
    
    // MARK: - 发现
    var data_Rank: [MPRankingModel]?
    func requestRank(source: String = "Mnet", limit: Int = 20, offset: Int = 15,complete:@escaping ((_ isSucceed: Bool, _ data: [MPRankingModel]?, _ message: String) -> Void)) {
        //        app_id=com.musiczplayer.app&hl=ja&m=0&s=0&token=z%23master%40Music1.4.8
        let app_id = BundleName // 包名
//        let limit = 50 // 分页
//        let offset = 15 // 分页间隔
        let hl = "ja" // 日文版、en: 英文版
        let m = 0 // 0: MV 1: MP3
        let s = 0
        let token = "z#master@Music1.4.8"
        
        let param: [String:Any] = ["app_id": app_id, "limit": limit, "m": m, "offset": offset, "source":  source,"token": token]
        
        HFNetworkManager.request(url: API.Rank, method: .get, parameters:param, description: "发现") { (error, resp) in
            
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
            
            let model: [MPRankingModel] = Mapper<MPRankingModel>().mapArray(JSONObject: dataArr)!
            let cacheName = NSStringFromClass(MPRankingModel.self).components(separatedBy: ".").last!
            (model as NSArray).bg_save(withName: cacheName)
            
            // 请求成功时
            complete(true,model,msg)
        }
    }

}
