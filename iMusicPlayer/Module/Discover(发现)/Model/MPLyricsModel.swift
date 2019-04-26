//
//  MPLyricsModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/26.
//  Copyright © 2019 Modi. All rights reserved.
//

import ObjectMapper

class MPLyricsModel: Mappable {
    var data_songName: String?
    var data_lyrics: String?
    var data_songId: String?
    
    /// 当前播放的时间
    var data_currentTime: TimeInterval = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_songName <- map["songName"]
        data_lyrics <- map["lyrics"]
        data_songId <- map["songId"]
    }
}
