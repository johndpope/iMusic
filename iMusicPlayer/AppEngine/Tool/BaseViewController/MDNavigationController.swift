//
//  HWNavigationController.swift
//  HandWriting
//
//  Created by mac on 17/9/11.
//  Copyright © 2017年 modi. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class MDNavigationController: UINavigationController {
    
    var rightClickBlock: RightItemClickedHandler?
    
    typealias RightItemClickedHandler =  (() -> Void)?
    
    convenience init(vc: UIViewController) {
        self.init(rootViewController: vc)
        //配置导航栏样式
        self.setupNavgationBar()
    }
    
    /// 配置导航栏样式
    private func setupNavgationBar() {
        
        self.navigationBar.isTranslucent = false
        
        let bar = UINavigationBar.appearance()
        bar.barTintColor = Color.md_NavBarBgColor
        bar.tintColor = Color.md_NavBarTintColor
        bar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Color.md_333333, NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize.md_NavBarFontSize)]
        let line:UIImage = UIImage(color: Color.md_bbbbbb, size: CGSize(width: SCREEN_WIDTH, height: 0.1))!
        
        bar.shadowImage = line;
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -100, vertical: 0), for:UIBarMetrics.default)
        
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if viewControllers.count > 0 {
            
//            viewController.hidesBottomBarWhenPushed = true
            self.interactivePopGestureRecognizer?.delegate = self
            self.interactivePopGestureRecognizer?.isEnabled = true
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "global_btn_return_n"), style: .plain, target: self, action: #selector(navigationBackClick))
            
            // 设置播放View的隐藏显示
//            appDelegate.playingView?.isHidden = true
        }
        
        super.pushViewController(viewController, animated: true)
    }
    
    @objc func navigationBackClick() {
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }
        if UIApplication.shared.isNetworkActivityIndicatorVisible {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        popViewController(animated: true)
    }
    
    /// 设置导航栏左按钮
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - imageName: 图片
    func addRightItem(title:String,imageName:String) {
        let rightButton = UIBarButtonItem.init(title: title, style: .plain, target: self, action: #selector(clickRight))
        let dic = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]
        rightButton.setTitleTextAttributes(dic, for: .normal)
        rightButton.setTitleTextAttributes(dic, for: .highlighted)
        rightButton.tintColor = UIColor.white
        rightButton.image = UIImage.init(named: imageName)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    
    /// 点击导航右按钮
    @objc func clickRight() {
        if let b = rightClickBlock {
            b!()
        }
    }
    
    /// 设置导航栏右按钮
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - imageName: 图片
    func addLeftItem(title:String,imageName:String) {
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.isEnabled = true
        let leftButton = UIBarButtonItem.init(title: title, style: .plain, target: self, action: #selector(navigationBackClick))
        let dic = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]
        leftButton.setTitleTextAttributes(dic, for: .normal)
        leftButton.setTitleTextAttributes(dic, for: .highlighted)
        leftButton.tintColor = UIColor.white
        leftButton.image = UIImage.init(named: imageName)
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    /// 点击导航左按钮
    @objc func clickLeft() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var shouldAutorotate: Bool{
        get{
            return false
        }
    }
    
    // MARK: - 设置播放条Bar
    //MARK: Properties
    private lazy var playerView: PlayerView = {
        let pv = PlayerView.md_viewFromXIB() as! PlayerView
        return pv
    }()
    let hiddenOrigin: CGPoint = {
        let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 32) - 10
        let x = -UIScreen.main.bounds.width
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    let minimizedOrigin: CGPoint = {
        let x = UIScreen.main.bounds.width/2 - 10
        let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 32) - 10
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    let fullScreenOrigin = CGPoint.init(x: 0, y: 0)
    
    //Methods
    func customization() {
        //PLayerView setup
        self.playerView.frame = CGRect.init(origin: self.hiddenOrigin, size: UIScreen.main.bounds.size)
        self.playerView.delegate = self
    }
    
   
    
    //MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.customization()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
        super.viewDidAppear(animated)
        if let window = UIApplication.shared.keyWindow {
            // 暂时不采用这种方式播放
//            window.addSubview(self.playerView)
            
//            addPlayingView()
        }
    }

}

extension MDNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count == 1 {
            return false
        }else{
            return true
        }
    }
}

extension MDNavigationController: PlayerVCDelegate {
    
    func animatePlayView(toState: stateOfVC) {
        switch toState {
        case .fullScreen:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [.beginFromCurrentState], animations: {
                self.playerView.frame.origin = self.fullScreenOrigin
            })
        case .minimized:
            UIView.animate(withDuration: 0.3, animations: {
                self.playerView.frame.origin = self.minimizedOrigin
            })
        case .hidden:
            UIView.animate(withDuration: 0.3, animations: {
                self.playerView.frame.origin = self.hiddenOrigin
            })
        }
    }
    
    func positionDuringSwipe(scaleFactor: CGFloat) -> CGPoint {
        let width = UIScreen.main.bounds.width * 0.5 * scaleFactor
        let height = width * 9 / 16
        let x = (UIScreen.main.bounds.width - 10) * scaleFactor - width
        let y = (UIScreen.main.bounds.height - 10) * scaleFactor - height
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }
    
    //MARK: Delegate methods
    func didMinimize() {
        self.animatePlayView(toState: .minimized)
    }
    
    func didmaximize(){
        self.animatePlayView(toState: .fullScreen)
    }
    
    func didEndedSwipe(toState: stateOfVC){
        self.animatePlayView(toState: toState)
    }
    
    func swipeToMinimize(translation: CGFloat, toState: stateOfVC){
        switch toState {
        case .fullScreen:
            self.playerView.frame.origin = self.positionDuringSwipe(scaleFactor: translation)
        case .hidden:
            self.playerView.frame.origin.x = UIScreen.main.bounds.width/2 - abs(translation) - 10
        case .minimized:
            self.playerView.frame.origin = self.positionDuringSwipe(scaleFactor: translation)
        }
    }
    
}

extension MDNavigationController {
    
}
