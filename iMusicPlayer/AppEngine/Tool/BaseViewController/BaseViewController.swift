//
//  BaseViewController.swift
//  MingChuangWine
//
//  Created by Modi on 2018/6/5.
//  Copyright © 2018年 江启雨. All rights reserved.
//

import UIKit
import Alamofire

import RxCocoa
import RxSwift

class BaseViewController: UIViewController, PlaceholderViewDelegate {
    
    /// 是否返回按钮
    open var hiddenLeftButton:Bool = false {
        didSet {
            setupStyle()
        }
    }
    
    /// 是否隐藏导航栏 - 默认不隐藏
    open var hiddenNavBar:Bool = false {
        didSet{
            if hiddenNavBar {
                navigationController?.setNavigationBarHidden(true, animated: true)
            }else {
                navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }
    
    /// 导航栏title颜色
    open var titleColor:UIColor = UIColor.white {
        didSet{
            let dict:NSDictionary = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 18)]
            navigationController?.navigationBar.titleTextAttributes = dict as? [NSAttributedString.Key:AnyObject]
            
        }
    }
    
    /// 导航栏设置字体颜色 - 默认 18
    open var titleSize : CGFloat = 18 {
        didSet{
            let dict:NSDictionary = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: titleSize)]
            navigationController?.navigationBar.titleTextAttributes = dict as? [NSAttributedString.Key:AnyObject]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupStyle()
    }

    open func setupStyle() {
        // 添加左右按钮
        if let vcs = self.navigationController?.viewControllers {
            if vcs.count > 1 {
                if !hiddenLeftButton {
                    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_nav_back"), style: .plain, target: self, action: #selector(clickBack))
                }else {
                     self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView(frame: .zero))
                }
            }else {
//                addLeftItem(title: "", imageName: "btn_my_n1", fontColor: Color.md_NavBarTintColor)
//                addRightItem(title: "", imageName: "btn_system_n1", fontColor: Color.md_NavBarTintColor)
                // 导航栏设置
                let nav = MPNavView.md_viewFromXIB() as! MPNavView
                self.navigationItem.titleView = nav
                nav.clickBlock = { [weak self] (sender) in
                    if let btn = sender as? UIButton {
                        if btn.tag == 10001 {
                            self?.clickLeft()
                        }else {
                            self?.clickRight(sender: btn)
                        }
                    }
                }
            }
        }
       
    }
    
    /// 返回
    @objc func clickBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// 设置导航栏左按钮
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - imageName: 图片
    func addRightItem(title:String = "",selectTitle: String = "",imageName:String = "",fontColor: UIColor = UIColor.white) {
//        let rightButton = UIBarButtonItem.init(title: title, style: .plain, target: self, action: #selector(clickRight))
//        let dic = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12)]
//        rightButton.setTitleTextAttributes(dic, for: .normal)
//        rightButton.setTitleTextAttributes(dic, for: .highlighted)
//        rightButton.tintColor = fontColor
//        rightButton.image = UIImage.init(named: imageName)
//        self.navigationItem.rightBarButtonItem = rightButton
        
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitle(title, for: UIControl.State.normal)
        btn.setTitle(selectTitle, for: .selected)
        btn.setTitleColor(fontColor, for: UIControl.State.normal)
        btn.setTitleColor(fontColor, for: UIControl.State.selected)
        btn.setImage(UIImage.init(named: imageName), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(clickRight(sender:)), for: .touchUpInside)
        
        let rightButton = UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    /// 点击导航右按钮
    @objc func clickRight(sender: UIButton) {
        // 添加左右按钮
        if let vcs = self.navigationController?.viewControllers {
            if vcs.count == 1 {
                let vc = MPUserSettingViewController()
                vc.plistName = "usersetting"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    /// 设置导航栏左按钮
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - imageName: 图片
    func addLeftItem(title:String,imageName:String,fontColor: UIColor = UIColor.white, fontSize: CGFloat = 12, margin: CGFloat = 5) {
//        let leftButton = UIBarButtonItem.init(title: title, style: .plain, target: self, action: #selector(clickLeft))
//        let dic = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12)]
//        leftButton.setTitleTextAttributes(dic, for: .normal)
//        leftButton.setTitleTextAttributes(dic, for: .highlighted)
//        leftButton.tintColor = fontColor
//        leftButton.image = UIImage.init(named: imageName)
        
//        let leftButton = UIBarButtonItem(image: UIImage(named: imageName), style: UIBarButtonItemStyle.done, target: self, action: #selector(clickLeft))
//        leftButton.tintColor = UIColor.black
        
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        btn.setTitle(title, for: UIControl.State.normal)
        btn.setTitleColor(fontColor, for: UIControl.State.normal)
        btn.setImage(UIImage.init(named: imageName), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(clickLeft), for: .touchUpInside)
        
        btn.sizeToFit()
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: 0)
//        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -margin, bottom: 0, right: 0)
//        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: margin)
        btn.frame = CGRect(origin: .zero, size: CGSize(width: btn.width + margin, height: btn.height))
        
        let leftButton = UIBarButtonItem(customView: btn)
        self.navigationItem.leftBarButtonItem = leftButton
        
    }
    
    /// 点击导航右按钮
    @objc func clickLeft() {
        // 添加左右按钮
        if let vcs = self.navigationController?.viewControllers {
            if vcs.count == 1 {
                let vc = MPSearchViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //设置状态栏颜色
    @objc open func setStatusBarBackgroundColor(color: UIColor) {
        let statusBarView = UIApplication.shared.value(forKey: "statusBarWindow") as! UIView
        let statusBar = statusBarView.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = color
    }
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let net = NetworkReachabilityManager()
        if net?.isReachable ?? false {
            for view in self.view.subviews {
                if view.isKind(of: PlaceholderView.self) {
                    view.removeFromSuperview()
                }
            }
        }else {
            self.showNoNetworkView()
        }

    }
    
    func showNoNetworkView() {
        let noNetworkView = PlaceholderView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 49))
        noNetworkView.delegate = self
        self.view.addSubview(noNetworkView)
    }

    func requestData() {
        debugPrint("base reloadData ~")
    }
}
extension BaseViewController {
    
}

extension UIViewController {
    
    func showAlerView(showView:UIView,layoutType:PopupLayoutType = .center){
        self.sl_popupController = SnailPopupController()
        self.sl_popupController.layoutType = layoutType //default center
        self.sl_popupController.transitStyle = .default//default
        self.sl_popupController.allowPan = true //default = NO
        self.sl_popupController.presentContentView(showView, duration: 0.75, elasticAnimated: true)
    }
    
}
