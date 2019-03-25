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
        data_oricon <- map["oricon"]
        data_mnet <- map["mnet"]
        data_billboard <- map["billboard"]
        data_iTunes <- map["iTunes"]
        data_listen <- map["listen"]
        data_collection <- map["collection"]
        data_uK <- map["uK"]
    }
}

class GeneralPlaylists: BaseModel {
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
    
    static let categoryDatas = [NSLocalizedString("最新发布", comment: ""), NSLocalizedString("排行榜", comment: ""), NSLocalizedString("人气歌手", comment: ""), NSLocalizedString("风格流派", comment: "")]
    
    static let sectionTitleDatas = [NSLocalizedString("每日推荐", comment: ""), NSLocalizedString("最近播放", comment: ""), "", NSLocalizedString("精选歌单", comment: "")]
    
    var data_latest: Latest?
    var data_hotSingerPlaylists: [HotSingerPlaylists]?
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
        _ = T.bg_count(tableName, where: nil)
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

