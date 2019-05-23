//
//  AppDelegate.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/12.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import IQKeyboardManager
import Kingfisher
import KingfisherWebP
import youtube_ios_player_helper
import Firebase
import FirebaseUI
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var playingView: MPPlayingView?
    
    var playingBigView: MPPlayingBigView?
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier!
    
    var remoteConfig: RemoteConfig!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        //注册第三方
        HFThirdPartyManager.shared.registerThirdParty()
        
        //        let configuration = HFEngineConfiguration()
        //        configuration.isNeedWelcomeView = true
        //        configuration.isEnabledDemonstration = false
        //        configuration.autoLoginByLocalTokenKey = TokenKEY
        //        HFAppEngine.run(configuration: configuration)
        HFAppEngine.run()
        
        // Facebook
        //        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // 极光推送
        self.pushAction(launchOptions: launchOptions)
        // KF支持webP图片
        KingfisherManager.shared.defaultOptions = [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]
        
        // 支持不同尺寸设备自动xib按比例约束
        //        NSLayoutConstraint().adaptive = true
        
//        addPlayingView()
        
        if #available(iOS 11.0, *) {
            registerBackgroundPlay()
        } else {
            // Fallback on earlier versions
        }
        
        // 配置Firebase
        FirebaseApp.configure()
        let authUI = FUIAuth.defaultAuthUI()
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        authUI?.providers = providers
        
        // 配置Google登陆
//        GIDSignIn.sharedInstance().clientID = HFThirdPartyManager.GoogleClientID
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // 远程配置
        setupRemoteConfig()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        debugPrint("前台进入后台 --------------------------> ")
        
        backgroundTaskIdentifier = application.beginBackgroundTask {
            self.endBackgroundTask()
        }
        self.syncData()
    }
    
    private func endBackgroundTask() {
        if self.backgroundTaskIdentifier != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
            self.backgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
        }
    }
    
    @objc private func syncData() {
        
        if let obj = UserDefaults.standard.value(forKey: "UserInfoModel") as? Data, let m = NSKeyedUnarchiver.unarchiveObject(with: obj) as? MPUserSettingHeaderViewModel  {
            DiscoverCent?.requestSaveUserCloudList(contact: m.email, reset: 1, uid: m.uid, complete: { (isSucceed, msg) in
                switch isSucceed {
                case true:
                    //                SVProgressHUD.showInfo(withStatus: "数据保存成功~")
                    QYTools.shared.Log(log: "数据保存成功~".decryptLog())
                    break
                case false:
                    SVProgressHUD.showError(withStatus: msg)
                    break
                }
            })
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        debugPrint("后台回前台 --------------------------> ")
        if let cvc = HFAppEngine.shared.currentViewController() {
            //            cvc.viewWillAppear(true)
            cvc.viewDidAppear(true)
        }
        // 清除角标
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
}
extension AppDelegate {
    
    // MARK: - 兼容iOS8.0之前版本
    func application(application: UIApplication,
                     openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return HFThirdPartyManager.shared.application(application, open: url as URL, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    // MARK: - 处理第三方回调
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return HFThirdPartyManager.shared.application(application,handleOpen:url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return HFThirdPartyManager.shared.application(_:application, open:url, sourceApplication:sourceApplication, annotation:annotation)
    }
    //解决iOS9后微博分享回调找不到系统方法
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        return HFThirdPartyManager.shared.application(_:application, open:url, sourceApplication:sourceApplication, annotation:annotation)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return HFThirdPartyManager.shared.application(app:app, openURL:url, options:options)
    }
}
extension AppDelegate: JPUSHRegisterDelegate {
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {
        
    }
    
    private func pushAction(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        //极光推送
        let entity = JPUSHRegisterEntity()
        entity.types = 1 << 0 | 1 << 1 | 1 << 2
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        // 配置APPKey
        JPUSHService.setup(withOption: launchOptions, appKey: HFThirdPartyManager.JPushAppKey, channel: "App Store", apsForProduction: false)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    //    func applicationDidBecomeActive(_ application: UIApplication) {
    //        if let launchOptions = UserDefaults.standard.value(forKey: "launchOptions") as? [UIApplicationLaunchOptionsKey: Any] {
    //            if let remoteNotify = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: Any] {
    //                if let aps = remoteNotify["aps"] as? [String: Any] {
    //                    if let badge = aps["badge"] as? Int {
    //                        UserDefaults.standard.set(badge, forKey: "badge")
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    //MARK:JPUSHRegisterDelegate
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {//收到通知
        let userInfo = notification.request.content.userInfo
        debugPrint("userInfo --------------------------> \(userInfo)")
        if notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler(Int(JPAuthorizationOptions.alert.rawValue))
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {//点击通知
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        
        if UIApplication.shared.applicationState == .active {
            self.handlePushAction(userInfo: userInfo)
        }else{
            DispatchQueue.main.asyncAfter(deadline:1.5, execute: {
                self.handlePushAction(userInfo: userInfo)
            })
        }
        
        completionHandler()
    }
    
    private func handlePushAction(userInfo: [AnyHashable : Any]) {
        debugPrint("userInfo --------------------------> \(userInfo)")
        
        // 获取当前的角标数量
        //        if let aps = userInfo["aps"] as? [String: Any], let badge = aps["badge"] as? Int {
        //            UIApplication.shared.applicationIconBadgeNumber = badge
        //        }
        
        
    }
}
// 监听后台回到前台
extension AppDelegate {
    
    @available(iOS 11.0, *)
    private func registerBackgroundPlay() {
        // 注册后台播放
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
            try session.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, policy: AVAudioSession.RouteSharingPolicy.default, options: [.mixWithOthers, .duckOthers])
        } catch {
            print(error)
        }
    }
}

// MARK: - 远程配置相关
extension AppDelegate {
    
    private func setupRemoteConfig() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        
        setFRCDefault()
        updateKeyWithRCValues()
        fetchRemoteConfig()
    }
    
    private func setFRCDefault() {
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefault")
        QYTools.shared.Log(log: "成功设置默认值".decryptLog())
    }
    
    private func fetchRemoteConfig() {
        let dbgSetting = RemoteConfigSettings(developerModeEnabled: true)
        RemoteConfig.remoteConfig().configSettings = dbgSetting
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { (status, error) in
            guard error == nil else {
                QYTools.shared.Log(log: "还没有配置默认值哦".decryptLog())
                return
            }
            QYTools.shared.Log(log: "已经存在默认值".decryptLog())
            RemoteConfig.remoteConfig().activateFetched()
            self.updateKeyWithRCValues()
        }
    }
    
    /// 获取firebase远程配置的值保持本地
    private func updateKeyWithRCValues() {
        let openMP3 = self.remoteConfig.configValue(forKey: "bool_open_mp3").boolValue
        QYTools.shared.Log(log: "BOOL_OPEN_MP3 == \(openMP3)")
        SourceType = openMP3 ? 1 : 0
        BOOL_OPEN_MP3 = openMP3
        if openMP3 {
            Analytics.logEvent("allow_mp3_on", parameters: nil)
        }else {
            Analytics.logEvent("allow_mp3_off", parameters: nil)
        }
        
        let openMusicDL = self.remoteConfig.configValue(forKey: "bool_open_music_dl").boolValue
        QYTools.shared.Log(log: "BOOL_OPEN_MUSIC_DL == \(openMusicDL)")
        if BOOL_OPEN_MUSIC_DL == false, openMusicDL == true {
            Analytics.logEvent("allow_downloading_activated", parameters: nil)
        }
        BOOL_OPEN_MUSIC_DL = openMusicDL
        if openMusicDL {
            Analytics.logEvent("allow_downloading_on", parameters: nil)
        }else {
            Analytics.logEvent("allow_downloading_off", parameters: nil)
        }
        
        let openLyrics = self.remoteConfig.configValue(forKey: "bool_open_lyrics").boolValue
        QYTools.shared.Log(log: "BOOL_OPEN_LYRICS == \(openLyrics)")
        if BOOL_OPEN_LYRICS == false, openLyrics == true {
            Analytics.logEvent("allow_lyrics_activated", parameters: nil)
        }
        BOOL_OPEN_LYRICS = openLyrics
        if openLyrics {
            Analytics.logEvent("allow_lyrics_on", parameters: nil)
        }else {
            Analytics.logEvent("allow_lyrics_off", parameters: nil)
        }
        
        let deviceAuth = self.remoteConfig.configValue(forKey: "status_of_device_auth").stringValue ?? ""
        QYTools.shared.Log(log: "STATUS_OF_DEVICE_AUTH == \(deviceAuth)")
        STATUS_OF_DEVICE_AUTH = deviceAuth
        
        let installTime = self.remoteConfig.configValue(forKey: "float_min_act_hours_as_old_user").numberValue?.floatValue ?? 0
        QYTools.shared.Log(log: "FLOAT_MIN_ACT_HOURS_AS_OLD_USER == \(installTime)")
        FLOAT_MIN_ACT_HOURS_AS_OLD_USER = installTime
        
        let completedSongs = self.remoteConfig.configValue(forKey: "int_min_completed_songs_as_old_user").numberValue?.intValue ?? 0
        QYTools.shared.Log(log: "INT_MIN_COMPLETED_SONGS_AS_OLD_USER == \(completedSongs)")
        INT_MIN_COMPLETED_SONGS_AS_OLD_USER = completedSongs
        
        let devLang = self.remoteConfig.configValue(forKey: "dev_lang").stringValue ?? ""
        QYTools.shared.Log(log: "DEV_LANG == \(devLang)")
        DEV_LANG = devLang
        
        let dev_loc = self.remoteConfig.configValue(forKey: "dev_loc").stringValue ?? ""
        QYTools.shared.Log(log: "DEV_LOC == \(dev_loc)")
        DEV_LOC = dev_loc
        
        // 获取后台配置
        getAppConfig()
    }
    
    private func getAppConfig() {
        DiscoverCent?.requestAppConfig(complete: { (isSucceed, model, msg) in
            switch isSucceed {
            case true:
                if let status = model?.data_devAuthStatus {
                    STATUS_OF_DEVICE_AUTH = status
                }
                break
            case false:
                SVProgressHUD.showError(withStatus: msg)
                break
            }
        })
    }
    
}
