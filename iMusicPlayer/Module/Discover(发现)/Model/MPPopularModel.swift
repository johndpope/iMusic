//
//  MPPopularModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/26.
//  Copyright © 2019 Modi. All rights reserved.
//

import ObjectMapper

class MPPopularModel: BaseModel {
    var data_id: Int = 0
    var data_title: String?
    var data_originalId: String?
    var data_img: String?
    var data_type: String?
    var data_tracksCount: Int = 0
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.data_id, forKey: "id")
        aCoder.encode(self.data_title, forKey: "title")
        aCoder.encode(self.data_originalId, forKey: "originalId")
        aCoder.encode(self.data_img, forKey: "img")
        aCoder.encode(self.data_type, forKey: "type")
        aCoder.encode(self.data_tracksCount, forKey: "tracksCount")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        self.data_id = aDecoder.decodeInteger(forKey: "id")
        self.data_title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        self.data_originalId = aDecoder.decodeObject(forKey: "originalId")  as? String ?? ""
        self.data_img = aDecoder.decodeObject(forKey: "img") as? String ?? ""
        self.data_type = aDecoder.decodeObject(forKey: "type") as? String ?? ""
        self.data_tracksCount = aDecoder.decodeInteger(forKey: "tracksCount")
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
        data_originalId <- map["originalId"]
        data_img <- map["img"]
        data_type <- map["type"]
        data_tracksCount <- map["tracksCount"]
    }
}
