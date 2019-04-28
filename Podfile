# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# 忽略所有第三方库警告⚠️
inhibit_all_warnings!

target 'iMusicPlayer' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iMusicPlayer
  
  pod "SnapKit"
  pod "Alamofire"
  pod "SwiftyJSON"
  pod "SVProgressHUD"
  pod "CryptoSwift"
  pod "ObjectMapper"
  #4.10.0
  pod "Kingfisher"
  pod "KingfisherWebP"
  #    导入腾讯SDK
  pod "TencentOpenAPI"
  pod "WechatOpenSDK"
  pod "IQKeyboardManager"
  #   轮播图
  #    pod "YJBannerView"
  pod "FSPagerView"
  #    刷新
  pod "MJRefresh"
  
  #   选项卡：Viewpager
#  pod 'LTScrollView'

  #    Google登录
  pod 'GoogleSignIn'
  pod 'FirebaseUI/Google'
  
  pod "RxSwift"
  pod "RxCocoa"
  
  #   极光推送
  pod 'JPush'
  # 链式添加事件等处理
  #    pod 'ReactiveCocoa'
  
  pod 'TagListView'
  # 歌词解析/显示
#  pod 'SpotlightLyrics'
  pod 'BGFMDB'
  # YouTube网页播放器交互库
  pod "youtube-ios-player-helper"
  # tableView拖动单行交换位置
  # pod "TableViewDragger"
  # 音频（流媒体）播放
#   pod "StreamingKit"
   pod "DOUAudioStreamer"
   
   pod 'Firebase/Core'

  target 'iMusicPlayerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'iMusicPlayerUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

# IBAnimate XIB看不见视图
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
