//
//  Macro.swift
//  LampblackMonitor
//
//  Created by 姚鸿飞 on 2017/12/4.
//  Copyright © 2017年 encifang. All rights reserved.
//

import UIKit

// MARK: 核心模块宏

/// 引擎
weak var AppEngine: HFAppEngine?                        = HFAppEngine.shared

// MARK: - --------数据中心宏定义开始-------

/// 主数据中心
weak var MainCent: HFMainDataCent?                  = AppEngine?.mainDataCent

///登录页数据中心
//weak var LoginCent:LoginDataCent?                   = AppEngine?.loginDataCent

/// 设置
//weak var SettingCent: SettingDataCent?                  = AppEngine?.settingDataCent

/// 公共数据
weak var CommonCent: CommonDataCent?                = AppEngine?.commonDataCent

/// 主页数据
weak var DiscoverCent: MPDiscoverDataCent?                = AppEngine?.discoverDataCent

/// 消息数据
//weak var MessageCent: MessageDataCent?                = AppEngine?.messageDataCent

/// 购物车数据
//weak var ShoppingCartCent: QBShoppingCartDataCent?                = AppEngine?.shoppingCartDataCent

// MARK: - --------数据中心宏定义结束-------



/// 根控制器
weak var RootController: UIViewController?              = UIApplication.shared.keyWindow?.rootViewController

/// 定位完成通知
let HFLocationDidUpdateNotification: Notification             = Notification(name: Notification.Name(rawValue: "HFLocationDidUpdateNotification"))


// MARK: 其他

/// 百度地图AppKey
let BaiduMapAppKey: String                              = "ll428MWiAAkwh7y269rP4knX1wrtvUQj"

/// 使用说明URL
let AboutURL: String                                    = "http://www.baidu.com"

/// 公钥KEY
let PublicKeyKEY: String                                = "pk"

/// 令牌KEY
let TokenKEY: String                                    = "tk"

/// 令牌KEY
let RefreshTokenKEY: String                                    = "rtk"

/// 接口基地址KEY
let BaseURLKEY: String                                  = "buk"

/// 用户名KEY
let UserNameKEY: String                                 = "unk"

/// 用户手机KEY
let UserPhoneKEY: String                                = "phok"

/// 用户id
let UserIDKEY: String                                   = "userid"

/// 密码KEY
let PasswordKEY: String                                 = "pdk"

/// 是否设置支付密码
let IsPayPass: String                                   = "payPass"

/// 当前版本号
let CurrentVersion: String                                   = "CurrentVersion"

/// 集货倒计时通知
let CollectCountDownTimeName                            = "CollectCountDownTimeName"


/// 屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.width
/// 屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.height

let IPHONEX: Bool = UIScreen.main.bounds.height == 812 ? true : false
let is_iPhonex: Bool = UIScreen.main.bounds.height == 812 ? true : false

let IPHONESE: Bool = UIScreen.main.bounds.width == 320 ? true : false

let SaveAreaHeight: CGFloat = StatusBarHeight > 20 ? 34 : 0

let NavBarHeight: CGFloat = StatusBarHeight > 20 ? 88 : 64

let TabBarHeight: CGFloat = StatusBarHeight > 20 ? 49+SaveAreaHeight : 49

/// 状态栏高度
let StatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

// 当前应用的AppDelegate
let appDelegate = UIApplication.shared.delegate as! AppDelegate
// 当前应用的keyWindow
let window = UIApplication.shared.keyWindow!

// 包名
let BundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""

// 当前显示MV还是MP3
var SourceType = 0

// 当前显示的语言版本：ja: 日版 en: 英文版
let LanguageType: String = "ja"

// 当前地区
let LocationCode = ""
// 此参数跟风格流派分类图片有关，接口默认是s=0
let StyleImageType = 0

let TokenCode = "z#master@Music1.4.8"

/// 标记当前需要同步的数据是增加还是减少：1：当前数据减少了、0：当前数据增加、1：当前数据增加和减少：增加或减少的项需要发送当前全部数据给后台：不变的可以不传
var SyncReset = 0

/// 配置TabBar
let TabBarDataSource: [[String: String]] = {
    let dic1 = ["title": NSLocalizedString("发现", comment: ""), "imageNameS": "icon_discover_selected", "imageNameN": "icon_discover_selected(1)", "viewController": "MPDiscoverViewController"]
    let dic2 = ["title": NSLocalizedString("电台", comment: ""), "imageNameS": "icon_fm_normal(1)", "imageNameN": "icon_fm_normal", "viewController": "MPRadioViewController"]
    let dic3 = ["title": NSLocalizedString("媒体库", comment: ""), "imageNameS": "icon_list_normal(1)", "imageNameN": "icon_list_normal", "viewController": "MPMediaLibraryViewController"]
    return [dic1, dic2, dic3]
}()

protocol ViewClickedDelegate {
    var clickBlock: ((_ sender: Any?) -> ())? {get set}
}

var BtnDidClickedBlock: ((_ sender: UIButton) -> Void)?

/*
 layer.cornerRadius
 layer.masksToBounds
 
 <userDefinedRuntimeAttributes>
 <userDefinedRuntimeAttribute type="number" keyPath="layer.cornerRadius">
 <integer key="value" value="20"/>
 </userDefinedRuntimeAttribute>
 <userDefinedRuntimeAttribute type="boolean" keyPath="layer.masksToBounds" value="YES"/>
 </userDefinedRuntimeAttributes>
 */

// MARK: - 远程配置


/// 为 true 则激活mp3功能
var BOOL_OPEN_MP3: Bool = false

/// 为true则激活下载功能
var BOOL_OPEN_MUSIC_DL: Bool = false

/// 为true则激活歌词功能
var BOOL_OPEN_LYRICS: Bool = false

/// 如果是"reject"，则不再激活任何隐藏功能（下载，mp3，歌词）。如果是"accept"则允许激活。如果为空，不作任何处理
var STATUS_OF_DEVICE_AUTH: String = ""


// MARK: - 下载管理类
//KDownloadManager [GKDownloadManager sharedInstance]
//let KDownloadManager = GKDownloadManager.sharedInstance()
