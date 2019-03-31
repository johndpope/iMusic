//
//  MPSearchKeywordModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/30.
//  Copyright © 2019年 Modi. All rights reserved.
//

import ObjectMapper

class MPSearchKeywordModel: BaseModel {
    var data_id: Int = 0
    var data_keyword: String?
    var data_icon: String?
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.data_id, forKey: "id")
        aCoder.encode(self.data_keyword, forKey: "keyword")
        aCoder.encode(self.data_icon, forKey: "icon")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.data_id = aDecoder.decodeInteger(forKey: "id")
        self.data_keyword = aDecoder.decodeObject(forKey: "keyword") as? String ?? ""
        self.data_icon = aDecoder.decodeObject(forKey: "icon")  as? String ?? ""
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
        data_keyword <- map["keyword"]
        data_icon <- map["icon"]
    }
}
