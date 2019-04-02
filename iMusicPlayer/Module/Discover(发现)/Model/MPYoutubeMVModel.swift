//
//  MPYoutubeMVModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/2.
//  Copyright © 2019 Modi. All rights reserved.
//

import ObjectMapper

class MPYoutubeMVModel: Mappable {
    var data_songs: [MPSongModel]?
    var data_pageToken: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_songs <- map["songs"]
        data_pageToken <- map["pageToken"]
    }
}
