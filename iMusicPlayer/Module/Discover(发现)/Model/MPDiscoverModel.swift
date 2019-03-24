//
//  MPDiscoverModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

//import UIKit
//
//class MPDiscoverModel: NSObject {
//
//    static let categoryDatas = [NSLocalizedString("最新发布", comment: ""), NSLocalizedString("排行榜", comment: ""), NSLocalizedString("人气歌手", comment: ""), NSLocalizedString("风格流派", comment: "")]
//
//    static let sectionTitleDatas = [NSLocalizedString("每日推荐", comment: ""), NSLocalizedString("最近播放", comment: ""), "", NSLocalizedString("精选歌单", comment: "")]
//
//}


import ObjectMapper

@objcMembers
class Recommendations:NSObject, NSCoding, Mappable {
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    override init() {
        super.init()
    }
    
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
    var data_durationInSeconds: String?
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

@objcMembers
class Japan:NSObject, NSCoding, Mappable {
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    override init() {
        super.init()
    }
    
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

@objcMembers
class Korea:NSObject, NSCoding, Mappable {
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    override init() {
        super.init()
    }
    
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

@objcMembers
class Europe:NSObject, NSCoding, Mappable {
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    override init() {
        super.init()
    }
    
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

@objcMembers
class Latest:NSObject, NSCoding, Mappable {
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        //        self.whc_Decode(aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    var data_Japan: [Japan]?
    var data_Korea: [Korea]?
    var data_Europe: [Europe]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_Japan <- map["Japan"]
        data_Korea <- map["Korea"]
        data_Europe <- map["Europe"]
    }
}

@objcMembers
class HotSingerPlaylists:NSObject, NSCoding, Mappable {
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    override init() {
        super.init()
    }
    
    var data_img: String?
    var data_id: Int = 0
    var data_title: String?
    var data_tracksCount: Int = 0
    var data_description: String?
    var data_originalId: String?
    var data_type: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_img <- map["img"]
        data_id <- map["id"]
        data_title <- map["title"]
        data_tracksCount <- map["tracksCount"]
        data_description <- map["description"]
        data_originalId <- map["originalId"]
        data_type <- map["type"]
    }
}

@objcMembers
class GeneralPlaylists:NSObject, NSCoding, Mappable {
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    override init() {
        super.init()
    }
    
    var data_img: String?
    var data_id: Int = 0
    var data_title: String?
    var data_tracksCount: Int = 0
    var data_description: String?
    var data_originalId: String?
    var data_type: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_img <- map["img"]
        data_id <- map["id"]
        data_title <- map["title"]
        data_tracksCount <- map["tracksCount"]
        data_description <- map["description"]
        data_originalId <- map["originalId"]
        data_type <- map["type"]
    }
}

@objcMembers
class Charts:NSObject, NSCoding, Mappable {
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    override init() {
        super.init()
    }
    
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

@objcMembers
class MPDiscoverModel:NSObject, NSCoding, Mappable {
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    override init() {
        super.init()
    }
    
    static let categoryDatas = [NSLocalizedString("最新发布", comment: ""), NSLocalizedString("排行榜", comment: ""), NSLocalizedString("人气歌手", comment: ""), NSLocalizedString("风格流派", comment: "")]
    
    static let sectionTitleDatas = [NSLocalizedString("每日推荐", comment: ""), NSLocalizedString("最近播放", comment: ""), "", NSLocalizedString("精选歌单", comment: "")]
    
    var data_recommendations: [Recommendations]?
    var data_latest: Latest?
    var data_hotSingerPlaylists: [HotSingerPlaylists]?
    var data_generalPlaylists: [GeneralPlaylists]?
    var data_charts: [Charts]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_recommendations <- map["recommendations"]
        data_latest <- map["latest"]
        data_hotSingerPlaylists <- map["hotSingerPlaylists"]
        data_generalPlaylists <- map["generalPlaylists"]
        data_charts <- map["charts"]
    }
    
    class func getModel() -> MPDiscoverModel? {
        var tempM: MPDiscoverModel?
        if let arr: [MPDiscoverModel]  = MPDiscoverModel.bg_findAll("MPDiscoverModel") as? [MPDiscoverModel], let model = arr.first {
            QYTools.shared.Log(log: "本地数据库获取数据")
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
}
