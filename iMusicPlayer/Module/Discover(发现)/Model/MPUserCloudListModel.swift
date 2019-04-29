//
//  MPUserCloudListModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/28.
//  Copyright © 2019 Modi. All rights reserved.
//

import ObjectMapper

class MPUserCloudListModel: Mappable {
    var data_customlist: [GeneralPlaylists]?
    var data_playlist: [GeneralPlaylists]?
    var data_favorite: [MPSongModel]?
    var data_download: [MPSongModel]?
    var data_history: [MPSongModel]?
    
    var data_customlistReset: Int = -1
    var data_playlistReset: Int = -1
    var data_favoriteReset: Int = -1
    var data_downloadReset: Int = -1
    var data_historyReset: Int = -1
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_customlist <- map["customlist"]
        data_playlist <- map["playlist"]
        data_favorite <- map["favorite"]
        data_download <- map["download"]
        data_history <- map["history"]
    }
    
    init() {
        
    }
    
}
