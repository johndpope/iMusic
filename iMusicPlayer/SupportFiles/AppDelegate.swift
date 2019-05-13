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
    
    var playingBigView: MPPlayingBigView_new?
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier!
    
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
                    QYTools.shared.Log(log: "数据保存成功~")
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
    // 提前添加播放控制View到window上
    private func addPlayingView() {
        // 添加播放详情View
        let pbv = MPPlayingBigView_new.md_viewFromXIB() as! MPPlayingBigView_new
        pbv.top = window?.frame.height ?? 0
        playingBigView = pbv
        window?.addSubview(pbv)
    }
    
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

