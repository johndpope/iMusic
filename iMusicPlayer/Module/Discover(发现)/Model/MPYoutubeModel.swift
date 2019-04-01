//
//  MPYoutubeModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/1.
//  Copyright © 2019 Modi. All rights reserved.
//

import ObjectMapper

class ContentDetails: Mappable {
    var data_videoId: String?
    var data_videoPublishedAt: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_videoId <- map["videoId"]
        data_videoPublishedAt <- map["videoPublishedAt"]
    }
}

class Standard: Mappable {
    var data_url: String?
    var data_width: Int = 0
    var data_height: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_url <- map["url"]
        data_width <- map["width"]
        data_height <- map["height"]
    }
}

class Medium: Mappable {
    var data_url: String?
    var data_width: Int = 0
    var data_height: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_url <- map["url"]
        data_width <- map["width"]
        data_height <- map["height"]
    }
}

class Default: Mappable {
    var data_url: String?
    var data_width: Int = 0
    var data_height: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_url <- map["url"]
        data_width <- map["width"]
        data_height <- map["height"]
    }
}

class High: Mappable {
    var data_url: String?
    var data_width: Int = 0
    var data_height: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_url <- map["url"]
        data_width <- map["width"]
        data_height <- map["height"]
    }
}

class Maxres: Mappable {
    var data_url: String?
    var data_width: Int = 0
    var data_height: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_url <- map["url"]
        data_width <- map["width"]
        data_height <- map["height"]
    }
}

class Thumbnails: Mappable {
    var data_standard: Standard?
    var data_medium: Medium?
    var data_default: Default?
    var data_high: High?
    var data_maxres: Maxres?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_standard <- map["standard"]
        data_medium <- map["medium"]
        data_default <- map["default"]
        data_high <- map["high"]
        data_maxres <- map["maxres"]
    }
}

class ResourceId: Mappable {
    var data_kind: String?
    var data_videoId: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_kind <- map["kind"]
        data_videoId <- map["videoId"]
    }
}

class Snippet: Mappable {
    var data_thumbnails: Thumbnails?
    var data_channelId: String?
    var data_position: Int = 0
    var data_title: String?
    var data_publishedAt: String?
    var data_playlistId: String?
    var data_resourceId: ResourceId?
    var data_description: String?
    var data_channelTitle: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_thumbnails <- map["thumbnails"]
        data_channelId <- map["channelId"]
        data_position <- map["position"]
        data_title <- map["title"]
        data_publishedAt <- map["publishedAt"]
        data_playlistId <- map["playlistId"]
        data_resourceId <- map["resourceId"]
        data_description <- map["description"]
        data_channelTitle <- map["channelTitle"]
    }
}

class Items: Mappable {
    var data_etag: String?
    var data_kind: String?
    var data_id: String?
    var data_contentDetails: ContentDetails?
    var data_snippet: Snippet?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_etag <- map["etag"]
        data_kind <- map["kind"]
        data_id <- map["id"]
        data_contentDetails <- map["contentDetails"]
        data_snippet <- map["snippet"]
    }
}

class PageInfo: Mappable {
    var data_resultsPerPage: Int = 0
    var data_totalResults: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_resultsPerPage <- map["resultsPerPage"]
        data_totalResults <- map["totalResults"]
    }
}

class MPYoutubeModel: Mappable {
    var data_etag: String?
    var data_kind: String?
    var data_items: [Items]?
    var data_nextPageToken: String?
    var data_pageInfo: PageInfo?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_etag <- map["etag"]
        data_kind <- map["kind"]
        data_items <- map["items"]
        data_nextPageToken <- map["nextPageToken"]
        data_pageInfo <- map["pageInfo"]
    }
}
