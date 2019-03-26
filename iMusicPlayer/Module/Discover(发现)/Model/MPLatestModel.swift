//
//  MPLatestModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/26.
//  Copyright © 2019 Modi. All rights reserved.
//

import ObjectMapper

class MPLatestModel: Mappable {
    var data_id: Int = 0
    var data_originalId: String?
    var data_songId: String?
    var data_heatIndex: Double = 0.0
    var data_singerName: String?
    var data_title: String?
    var data_cache: String?
    var data_channelTitle: String?
    var data_artworkUrl: String?
    var data_artworkBigUrl: String?
    var data_durationInSeconds: Int = 0
    var data_songName: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_id <- map["id"]
        data_originalId <- map["originalId"]
        data_songId <- map["songId"]
        data_heatIndex <- map["heatIndex"]
        data_singerName <- map["singerName"]
        data_title <- map["title"]
        data_cache <- map["cache"]
        data_channelTitle <- map["channelTitle"]
        data_artworkUrl <- map["artworkUrl"]
        data_artworkBigUrl <- map["artworkBigUrl"]
        data_durationInSeconds <- map["durationInSeconds"]
        data_songName <- map["songName"]
    }
}
