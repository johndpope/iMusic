//
//  MPDiscoverModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

/*
import ObjectMapper

class Recommendations:BaseModel {
    
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
      // self.data_durationInSeconds = aDecoder.decodeInteger(forKey: "durationInSeconds")
       self.data_songName = aDecoder.decodeObject(forKey: "songName") as? String ?? ""
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


class Japan:BaseModel {

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
       // self.data_durationInSeconds = aDecoder.decodeInteger(forKey: "durationInSeconds")
        self.data_songName = aDecoder.decodeObject(forKey: "songName") as? String ?? ""
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


class Korea:BaseModel {
    
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
       // self.data_durationInSeconds = aDecoder.decodeInteger(forKey: "durationInSeconds")
        self.data_songName = aDecoder.decodeObject(forKey: "songName") as? String ?? ""
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


class Europe:BaseModel {

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
       // self.data_durationInSeconds = aDecoder.decodeInteger(forKey: "durationInSeconds")
        self.data_songName = aDecoder.decodeObject(forKey: "songName") as? String ?? ""
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


class Latest:BaseModel {
    
    var data_Japan: [Japan]?
    var data_Korea: [Korea]?
    var data_Europe: [Europe]?
    
    override func encode(with aCoder: NSCoder) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init()
       // fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
// fatalError("init(map:) has not been implemented")
    }
    
    override func mapping(map: Map) {
        data_Japan <- map["Japan"]
        data_Korea <- map["Korea"]
        data_Europe <- map["Europe"]
    }
}


class HotSingerPlaylists:BaseModel {
    
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


class GeneralPlaylists:BaseModel {
    
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

class Charts:BaseModel {
    
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
       // self.data_durationInSeconds = aDecoder.decodeInteger(forKey: "durationInSeconds")
        self.data_songName = aDecoder.decodeObject(forKey: "songName") as? String ?? ""
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

class MPDiscoverModel:BaseModel {
    
    static let categoryDatas = [NSLocalizedString("最新发布", comment: ""), NSLocalizedString("排行榜", comment: ""), NSLocalizedString("人气歌手", comment: ""), NSLocalizedString("风格流派", comment: "")]
    
    static let sectionTitleDatas = [NSLocalizedString("每日推荐", comment: ""), NSLocalizedString("最近播放", comment: ""), "", NSLocalizedString("精选歌单", comment: "")]
    
    var data_recommendations: [Recommendations]?
    var data_latest: Latest?
    var data_hotSingerPlaylists: [HotSingerPlaylists]?
    var data_generalPlaylists: [GeneralPlaylists]?
    var data_charts: [Charts]?
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
        data_recommendations <- map["recommendations"]
        data_latest <- map["latest"]
        data_hotSingerPlaylists <- map["hotSingerPlaylists"]
        data_generalPlaylists <- map["generalPlaylists"]
        data_charts <- map["charts"]
        data_genre <- map["genre"]
    }
    
    class func getModel() -> MPDiscoverModel? {
        var tempM: MPDiscoverModel?
        if let arr: [MPDiscoverModel]  = MPDiscoverModel.bg_findAll(NSStringFromClass(MPDiscoverModel.self).components(separatedBy: ".").last!) as? [MPDiscoverModel], let model = arr.first {
            QYTools.shared.Log(log: "本地数据库获取数据")
            
            printSQLiteData(arr: arr)
            
            tempM = model
        }else {
            DiscoverCent?.requestDiscover(complete: { (isSucceed, model, msg) in
                switch isSucceed {
                case true:
                    QYTools.shared.Log(log: "在线获取数据")
                    tempM = model
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
        return tempM
    }
    
    class func printSQLiteData<T: BaseModel>(arr: [T]) {
        let tableName = NSStringFromClass(MPDiscoverModel.self).components(separatedBy: ".").last!
        print("表名称：\(tableName)")
        
        /**
         当数据量巨大时采用分页范围查询.
         */
        let count = T.bg_count(tableName, where: nil)
//        for i in stride(from: 0, to: count, by: 50) {
//            let arr: [T] = T.bg_find(tableName, range: NSRange(location: i+1, length: 50), orderBy: nil, desc: false) as! [T]
//
//            for m: T in arr {
//                print("····················································")
//                print("主键 = \(m.bg_id), 表名 = \(m.bg_tableName), 创建时间 = \(m.bg_createTime), 更新时间 = \(m.bg_updateTime), 数据 = \(m.getPropertiesAndValues())")
//                print("========================")
//            }
//            //顺便取第一个对象数据测试
//            if(i==0){
//                let m = arr.last
//                print("第一个对象数据 ========================\(m?.getPropertiesAndValues())")
//            }
//        }
        
        T.bg_findAllAsync(tableName) { (models) in
            if let arr = models as? [T] {
                for m: T in arr {
                    print("····················································")
                    print("主键 = \(m.bg_id), 表名 = \(m.bg_tableName), 创建时间 = \(m.bg_createTime), 更新时间 = \(m.bg_updateTime), 数据 = \(m.getPropertiesAndValues())")
                    print("========================")
                }
            }
        }
        
    }
    
}

private extension BaseModel {
    func encode(aCoder: NSCoder) {
        
    }
    
    func code(aDecoder: NSCoder) {
        
    }
}
*/
