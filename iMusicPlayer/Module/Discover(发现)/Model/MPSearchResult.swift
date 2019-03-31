//
//  MPSearchResult.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/30.
//  Copyright © 2019年 Modi. All rights reserved.
//

import ObjectMapper

class MPSearchResultModel: BaseModel {
    var data_collection: [GeneralPlaylists]?
    var data_nextPageTokenVideo: String?
    var data_playlists: [GeneralPlaylists]?
    var data_nextPageTokenPlaylist: String?
    var data_songs: [MPSongModel]?
    var data_videos: [MPSongModel]?
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.data_nextPageTokenVideo, forKey: "data_nextPageTokenVideo")
        aCoder.encode(self.data_nextPageTokenPlaylist, forKey: "data_nextPageTokenPlaylist")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.data_nextPageTokenVideo = aDecoder.decodeObject(forKey: "data_nextPageTokenVideo") as? String ?? ""
        self.data_nextPageTokenPlaylist = aDecoder.decodeObject(forKey: "data_nextPageTokenPlaylist")  as? String ?? ""
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        // fatalError("init(map:) has not been implemented")
    }
    
    override func mapping(map: Map) {
        data_collection <- map["collection"]
        data_nextPageTokenVideo <- map["nextPageTokenVideo"]
        data_playlists <- map["playlists"]
        data_nextPageTokenPlaylist <- map["nextPageTokenPlaylist"]
        data_songs <- map["songs"]
        data_videos <- map["videos"]
    }
}
