
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
            model.bg_tableName = "MPDiscoverModel"
            model.bg_save()
            
            print("表名称：\(model.bg_tableName)")
            
            let ct = model.bg_createTime
            print("创建时间：\(ct)")
            
            /**
             当数据量巨大时采用分页范围查询.
             */
            let count = MPDiscoverModel.bg_count(model.bg_tableName, where: nil)
            for i in stride(from: 1, to: count, by: 50) {
                let arr: [MPDiscoverModel] = MPDiscoverModel.bg_find(model.bg_tableName, range: NSRange(location: i, length: 50), orderBy: nil, desc: false) as! [MPDiscoverModel]
                for m: MPDiscoverModel in arr {
                    print("主键 = \(m.bg_id), 表名 = \(m.bg_tableName), 创建时间 = \(m.bg_createTime), 更新时间 = \(m.bg_updateTime), 推荐数据 = \(m.data_recommendations), 人气歌手 = \(m.data_hotSingerPlaylists)")
                }
                //顺便取第一个对象数据测试
                if(i==1){
                    let m = arr.last
                    print("第一个对象数据 ：：：\(m?.getPropertiesAndValues())")
                }
            }
            
            // 请求成功时
            complete(true,model,msg)
        }
    }
}
