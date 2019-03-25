//
//  API.swift
//  Ecosphere
//
//  Created by 姚鸿飞 on 2017/6/2.
//  Copyright © 2017年 encifang. All rights reserved.
//

import UIKit

class API: NSObject {
    
    // MARK: 服务器地址
    static let baseURL         = "http://api2cdn.groupy.cn:8090"

    // MARK: 图片拼接地址
    static let baseImageURL     = "http://api2cdn.groupy.cn:8090"

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
    static let Login         = "/user/loginUser/login"
    
    // MARK: - 刷新token
    static let RefreshToken         = "/user/loginUser/refreshToken"
    
    // MARK: - 淘口令解析
    static let TaoPasswordParse         = "http://api.taokouling.com/tkl/tkljm"
    
    // MARK: 发现页数据
    static let Discover = "/discovery/getAll"
}
