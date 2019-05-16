//
//  MPDiscoverModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//


import ObjectMapper

class Latest: BaseModel {
    var data_japan: [MPSongModel]?
    var data_korea: [MPSongModel]?
    var data_europe: [MPSongModel]?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        // fatalError("init(map:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func mapping(map: Map) {
        data_japan <- map["japan"]
        data_korea <- map["korea"]
        data_europe <- map["europe"]
    }
}

class HotSingerPlaylists: BaseModel {
    var data_img: String?
    var data_id: Int = 0
    var data_title: String?
    var data_tracksCount: Int = 0
    var data_description: String?
    var data_originalId: String?
    var data_type: String?
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.data_img, forKey: "img")
        aCoder.encode(self.data_id, forKey: "id")
        aCoder.encode(self.data_title, forKey: "title")
        aCoder.encode(self.data_tracksCount, forKey: "tracksCount")
        aCoder.encode(self.data_description, forKey: "description")
        aCoder.encode(self.data_originalId, forKey: "originalId")
        aCoder.encode(self.data_type, forKey: "type")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.data_img = aDecoder.decodeObject(forKey: "img") as? String ?? ""
        self.data_id = aDecoder.decodeInteger(forKey: "id")
        self.data_title = aDecoder.decodeObject(forKey: "title")  as? String ?? ""
        self.data_tracksCount = aDecoder.decodeInteger(forKey: "tracksCount")
        self.data_description = aDecoder.decodeObject(forKey: "description") as? String ?? ""
        self.data_originalId = aDecoder.decodeObject(forKey: "originalId") as? String ?? ""
        self.data_type = aDecoder.decodeObject(forKey: "type") as? String ?? ""
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        // fatalError("init(map:) has not been implemented")
    }
    
    override func mapping(map: Map) {
        data_img <- map["img"]
        data_id <- map["id"]
        data_title <- map["title"]
        data_tracksCount <- map["tracksCount"]
        data_description <- map["description"]
        data_originalId <- map["originalId"]
        data_type <- map["type"]
    }
}

class Charts: BaseModel {
    var data_oricon: [MPSongModel]?
    var data_mnet: [MPSongModel]?
    var data_billboard: [MPSongModel]?
    var data_iTunes: [MPSongModel]?
    var data_listen: [MPSongModel]?
    var data_collection: [MPSongModel]?
    var data_uK: [MPSongModel]?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        // fatalError("init(map:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func mapping(map: Map) {
        data_oricon <- map["Oricon"]
        data_mnet <- map["Mnet"]
        data_billboard <- map["Billboard"]
        data_iTunes <- map["iTunes"]
        data_listen <- map["Listen"]
        data_collection <- map["Collection"]
        data_uK <- map["UK"]
    }
}

class GeneralPlaylists: BaseModel {
    
    override var hash: Int {
        return (self.data_title ?? "").md5().hash
    }
    
    var data_img: String?
    var data_id: Int = 0
    var data_title: String?
    var data_tracksCount: Int = 0
    var data_description: String?
    var data_originalId: String?
    var data_type: String?
    
    /// 最近播放类型：1：最近播放单曲 2：最新歌曲列表 3：我的最爱  4：歌手  5：专辑 6: 排行榜 7: Top 100  8：创建的歌单
    var data_recentlyType: Int = -1
    /// 用来存储当前专辑的歌曲
    var data_songs: [MPSongModel]?
    
    var data_data: [MPSongModel]?
    
    var data_trackNums: Int = 0
    
    var data_oldTitle: String?
    
    /// 收藏类型：1: 歌单 2：歌手 3: youtube获取
    var data_collectionType: Int = -1
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.data_img, forKey: "img")
        aCoder.encode(self.data_id, forKey: "id")
        aCoder.encode(self.data_title, forKey: "title")
        aCoder.encode(self.data_tracksCount, forKey: "tracksCount")
        aCoder.encode(self.data_description, forKey: "description")
        aCoder.encode(self.data_originalId, forKey: "originalId")
        aCoder.encode(self.data_type, forKey: "type")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.data_img = aDecoder.decodeObject(forKey: "img") as? String ?? ""
        self.data_id = aDecoder.decodeInteger(forKey: "id")
        self.data_title = aDecoder.decodeObject(forKey: "title")  as? String ?? ""
        self.data_tracksCount = aDecoder.decodeInteger(forKey: "tracksCount")
        self.data_description = aDecoder.decodeObject(forKey: "description") as? String ?? ""
        self.data_originalId = aDecoder.decodeObject(forKey: "originalId") as? String ?? ""
        self.data_type = aDecoder.decodeObject(forKey: "type") as? String ?? ""
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        // fatalError("init(map:) has not been implemented")
    }
    
    override func mapping(map: Map) {
        data_img <- map["img"]
        data_id <- map["id"]
        data_title <- map["title"]
        data_tracksCount <- map["tracksCount"]
        data_description <- map["description"]
        data_originalId <- map["originalId"]
        data_type <- map["type"]
        
        data_recentlyType <- map["recentlyType"]
        
        data_data <- map["data"]
        
        data_trackNums <- map["trackNums"]
        
        data_oldTitle <- map["oldTitle"]
    }
    
    func getJson() -> [String: Any] {
        let dict: [String: Any] = [
//            "contact": UserDefaults.standard.value(forKey: UserNameKEY) as? String ?? "",
            "description": "",
            "id": self.data_id,
            "img": self.data_img ?? "",
            "originalId": self.data_originalId ?? "",
            "title": self.data_title ?? "",
            "tracksCount": self.data_tracksCount,
            "type": self.data_type ?? "",
//            "userId": UserDefaults.standard.value(forKey: UserIDKEY) as? String ?? ""
        ]
        return dict
    }
    
    func getJsonByCustom() -> [String: Any] {
        
        var arr = [[String: Any]]()
        self.data_data?.forEach({ (item) in
            arr.append(item.getJson())
        })
        
        let dict: [String: Any] = [
            "data": arr,
            "img": self.data_img ?? "",
            "oldTitle": self.data_oldTitle ?? (self.data_title ?? ""),
            "title": self.data_title ?? ""
        ]
        return dict
    }
    
}

class Genre: BaseModel {
    var data_id: Int = 0
    var data_title: String?
    var data_image: String?
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.data_id, forKey: "id")
        aCoder.encode(self.data_title, forKey: "title")
        aCoder.encode(self.data_image, forKey: "image")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.data_id = aDecoder.decodeInteger(forKey: "id")
        self.data_title = aDecoder.decodeObject(forKey: "title")  as? String ?? ""
        self.data_image = aDecoder.decodeObject(forKey: "image")  as? String ?? ""
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
        data_title <- map["title"]
        data_image <- map["image"]
    }
}

class MPDiscoverModel: BaseModel {
    
    static let categoryDatas = [NSLocalizedString("最新发布", comment: ""), NSLocalizedString("排行榜", comment: ""), NSLocalizedString("人气歌手", comment: ""), NSLocalizedString("风格及流派", comment: "")]
    
    static let sectionTitleDatas = [NSLocalizedString("每日热门歌曲", comment: ""), NSLocalizedString("最近播放", comment: ""), "", NSLocalizedString("歌单精选", comment: "")]
    
    var data_latest: Latest?
    var data_hotSingerPlaylists: [GeneralPlaylists]?
    var data_charts: Charts?
    var data_recommendations: [MPSongModel]?
    var data_generalPlaylists: [GeneralPlaylists]?
    var data_top: [MPSongModel]?
    var data_genre: [Genre]?
    
    override func encode(with aCoder: NSCoder) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        // fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        QYTools.shared.Log(log: "调用初始化方法")
    }
    
    required init?(map: Map) {
        super.init(map: map)
        // fatalError("init(map:) has not been implemented")
    }
    
    override func mapping(map: Map) {
        data_latest <- map["latest"]
        data_hotSingerPlaylists <- map["hotSingerPlaylists"]
        data_charts <- map["charts"]
        data_recommendations <- map["recommendations"]
        data_generalPlaylists <- map["generalPlaylists"]
        data_top <- map["top"]
        data_genre <- map["genre"]
    }
    
}

