//
//  MPSongModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/25.
//  Copyright © 2019 Modi. All rights reserved.
//

import ObjectMapper

class MPSongModel:BaseModel {
    
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
    
    var data_playingStatus: Int = 0
    
    var data_collectStatus: Int = 0
    
    var data_isSelected: Int = 0
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.data_id, forKey: "id")
        aCoder.encode(self.data_originalId, forKey: "originalId")
        aCoder.encode(self.data_songId, forKey: "songId")
        aCoder.encode(self.data_heatIndex, forKey: "heatIndex")
        aCoder.encode(self.data_singerName, forKey: "singerName")
        aCoder.encode(self.data_title, forKey: "title")
        aCoder.encode(self.data_cache, forKey: "cache")
        aCoder.encode(self.data_channelTitle, forKey: "channelTitle")
        aCoder.encode(self.data_artworkUrl, forKey: "artworkUrl")
        aCoder.encode(self.data_artworkBigUrl, forKey: "artworkBigUrl")
        aCoder.encode(self.data_durationInSeconds, forKey: "durationInSeconds")
        aCoder.encode(self.data_songName, forKey: "songName")
        
        
//        aCoder.encode(self.data_songName, forKey: "playingStatus")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        self.data_id = aDecoder.decodeInteger(forKey: "id")
        self.data_originalId = aDecoder.decodeObject(forKey: "originalId") as? String ?? ""
        self.data_songId = aDecoder.decodeObject(forKey: "songId")  as? String ?? ""
        self.data_heatIndex = aDecoder.decodeDouble(forKey: "heatIndex")
        self.data_singerName = aDecoder.decodeObject(forKey: "singerName") as? String ?? ""
        self.data_title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        self.data_cache = aDecoder.decodeObject(forKey: "cache") as? String ?? ""
        self.data_channelTitle = aDecoder.decodeObject(forKey: "channelTitle") as? String ?? ""
        self.data_artworkUrl = aDecoder.decodeObject(forKey: "artworkUrl") as? String ?? ""
        self.data_artworkBigUrl = aDecoder.decodeObject(forKey: "artworkBigUrl") as? String ?? ""
         self.data_durationInSeconds = aDecoder.decodeInteger(forKey: "durationInSeconds")
        self.data_songName = aDecoder.decodeObject(forKey: "songName") as? String ?? ""
        
//        self.data_playingStatus = aDecoder.decodeInteger(forKey: "playingStatus")
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        // fatalError("init(map:) has not been implemented")
    }
    
    override func mapping(map: Map) {
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

extension Array {
    // 获取当前下标
    func getIndexFromArray<T: BaseModel> (song: T, songs: [T]) -> Int {
        var index = 0
        for i in (0..<songs.count) {
            if song == songs[i] {
                index = i
            }
        }
        return index
    }
}
