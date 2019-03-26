//
//  MPStyleGenreModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/26.
//  Copyright © 2019 Modi. All rights reserved.
//

import ObjectMapper

class MPStyleGenreModel: BaseModel {
    
    static let sectionTitleDatas = [NSLocalizedString("推荐", comment: ""), NSLocalizedString("风格", comment: ""), NSLocalizedString("主题", comment: "")]
    
    var data_style: [Genre]?
    var data_theme: [Genre]?
    var data_recommended: [Genre]?
    
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
        data_style <- map["style"]
        data_theme <- map["theme"]
        data_recommended <- map["recommended"]
    }
}
