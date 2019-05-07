//
//  API.swift
//  Ecosphere
//
//  Created by 姚鸿飞 on 2017/6/2.
//  Copyright © 2017年 encifang. All rights reserved.
//

import UIKit

class API: NSObject {
    
    // MARK: 服务器地址: https://api.musicz.co
//    static let baseURL         = "http://api2cdn.groupy.cn:8090"
    static let baseURL         = "https://api.musicz.co"

    // MARK: 图片拼接地址
    static let baseImageURL     = ""

    // MARK: 视频播放地址
    static let ViodeURL         = "http://api2cdn.groupy.cn:8090"
    
    // MARK: - 通用API -
    
    // MARK: 图片上传
    static let imgUp            = "/global/upload/pic"
    
    // MARK: 视频上传
    static let uploadVideo         = "/common/uploadVideo"
    
    static let WXAccessToken       = "https://api.weixin.qq.com/sns/oauth2/access_token"
    
    static let WXUserinfo          = "https://api.weixin.qq.com/sns/userinfo"
    
    // MARK: - 登录
    static let Login         = "/config/login"
    
    // MARK: - 刷新token
    static let RefreshToken         = "/user/loginUser/refreshToken"
    
    // MARK: - 淘口令解析
    static let TaoPasswordParse         = "http://api.taokouling.com/tkl/tkljm"
    
    // MARK: 发现页数据
    static let Discover = "/discovery/getAll"
    // MARK: - 排行榜
    static let Rank = "/discovery/getCharts"
    
    // MARK: - 最新发布
    static let Latest         = "/discovery/getLatest"
    
    // MARK: - 人气歌手
    static let Popular         = "/playlists/getMusicSinger"
    
    // MARK: - 风格流派
    static let StyleGenre         = "/playlists/getCategory"
    
    // MARK: - 歌单列表
    static let SongList         = "/music/getYoutubeCate"
    
    // MARK: - 歌单列表详情数据
    static let SongListByID         = "/playlists/getPlaylistItems"
    
    // MARK: - 歌手列表详细
    static let SongerListByID         = "/playlists/getSongs"
    
    // MARK: - 电台
    static let Radio         = "/music/getFm"
    
    // MARK: - 相关歌曲
    static let RelatedSongs         = "/tracks/getRelated"
    
    // MARK: - 搜索关键词
    static let SearchKeyword         = "/music/getSearchKeyword"
    
    // MARK: - 搜索
    static let SearchResult         = "/search/getAll"
    
    // MARK: - 单独搜索MP3
    static let SearchMp3         = "/search/getSongs"
    
    // MARK: - 单独搜索MV
    static let SearchMV         = "/search/getVideos"
    
    // MARK: - 单独搜索YouTube歌单
    static let SearchList         = "/search/getPlaylists"
    
    // MARK: - 联想关键词
    static let RelatedKeyword         = "http://suggestqueries.google.com/complete/search"
    
    // MARK: - Yotube搜索歌单
    static let SearchSongList         = "https://www.googleapis.com/youtube/v3/playlistItems"
    
    // MARK: - Yotube搜索歌单
    static let SearchSongListByYoutube         = "/playlists/getYoutubePlaylistItems"
    
    // MARK: - 投诉
    static let Complaint         = "https://en.wikipedia.org/wiki/Complaint"
    
    // MARK: - 版权许可协议
    static let Copyright         = "https://en.wikipedia.org/wiki/Copyright"
    
    // MARK: - 播放来源
    static let MVSource        = "https://www.youtube.com/watch?v="
    
    // MARK: - 搜索歌词
    static let SearchLyrics         = "/playlists/getLyrics"
    
    // MARK: - 拉取用户保存的数据
    static let UserCloudList         = "/user/getUserData"
    
    // MARK: -
    static let SaveUserCloudList         = "/user/syncUserData"
    
}
