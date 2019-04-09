//
//  MPRankingTempModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/25.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import ObjectMapper

class MPRankingTempModel: NSObject, Mappable {
    
    required init?(map: Map) {
    }
    
    var data_image: String?
    var data_title: String?
    var data_updateTime: String?
    var data_songOne: String?
    var data_songTwo: String?
    
    init(image: String?,title: String?,updateTime: String?,songOne: String?,songTwo: String?) {
        data_image = image
        data_title = title
        data_updateTime = updateTime
        data_songOne = songOne
        data_songTwo = songTwo
    }
    
    func mapping(map: Map) {
        data_image <- map["image"]
        data_title <- map["title"]
        data_updateTime <- map["updateTime"]
        data_songOne <- map["songOne"]
        data_songTwo <- map["songTwo"]
    }
}

