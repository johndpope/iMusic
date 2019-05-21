//
//  MPAppConfig.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/5/21.
//  Copyright © 2019 Modi. All rights reserved.
//

import ObjectMapper

class MPAppConfig: Mappable {
    var data_devAuthStatus: String?
    var data_updateUrl: String?
    var data_svt: Double = 0.0
    var data_ip: String?
    var data_utc: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_devAuthStatus <- map["devAuthStatus"]
        data_updateUrl <- map["updateUrl"]
        data_svt <- map["svt"]
        data_ip <- map["ip"]
        data_utc <- map["utc"]
    }
}
