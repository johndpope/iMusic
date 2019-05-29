//
//  CCUserSettingViewController.swift
//  CarConvenient
//
//  Created by Modi on 2019/2/13.
//  Copyright © 2019年 modi. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseAnalytics

class MPUserSettingViewController: BaseTableViewController {

    var authUI: FUIAuth!
    
    var headerView: MPUserSettingHeaderView!
    
    private static let plistPathName = "/usersetting.plist"
    
    var plistName: String = "usersetting" {
        didSet {
            initPlistData()
        }
    }
    
    var groups: NSArray = NSArray()
    
    private func initData() {
        var arr = NSArray()
        let path = Bundle.main.path(forResource: self.plistName, ofType: "plist")
        arr = NSArray(contentsOfFile: path!)!
        debugPrint("arr --> \(arr)")
        self.groups = arr
    }
    
    private func initPlistData() {
        if self.plistName == "usersetting" {
            let tempArr: [[String: Any]] = [["footer":"","items":[["icon":"icon_profile_time","subTitleColor":"#999999","funcKey":"timeOff","titleColor":"#333333","title": NSLocalizedString("定时关闭", comment: "").decryptString(),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""],["icon":"icon_profile_upload","subTitleColor":"#999999","funcKey":"uploadMusic","titleColor":"#333333","title": NSLocalizedString("上传音乐", comment: "").decryptString(),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""],["icon":"icon_profile_message","subTitleColor":"#999999","funcKey":"message","titleColor":"#333333","title": NSLocalizedString("消息", comment: "").decryptString(),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""],["icon":"icon_info","subTitleColor":"#999999","funcKey":"policy","titleColor":"#333333","title": NSLocalizedString("隐私权政策", comment: "").decryptString(),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""],["icon":"icon_profile_no_ad","subTitleColor":"#999999","funcKey":"removeAd","titleColor":"#333333","title": NSLocalizedString("去除广告", comment: "").decryptString(),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""]],"header":""]]
            self.groups = tempArr as NSArray
        }else {
            initData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
//        self.authUI.delegate = self
        HFThirdPartyManager.shared.delegate = self
    }
    
    override func setupStyle() {
        super.setupStyle()
        addLeftItem(title: NSLocalizedString("我", comment: "").decryptString(), imageName: "icon_nav_back", fontColor: UIColor(rgba: "#333333"), fontSize: 18, margin: 16)
    }
    
    override func clickLeft() {
        super.clickLeft()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func setupTableView() {
        super.setupTableView()
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .singleLine
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPUserSettingHeaderView.md_viewFromXIB() as! MPUserSettingHeaderView
        headerView = hv
        
        if let obj = UserDefaults.standard.value(forKey: "UserInfoModel") as? Data, let m = NSKeyedUnarchiver.unarchiveObject(with: obj) as? MPUserSettingHeaderViewModel  {
            hv.updateView(model: m)
        }
        
        tableView.tableHeaderView = hv
        
        hv.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                if btn.tag == 10001 {
                    var alert: HFAlertController?
                    let config = MDAlertConfig()
                    config.title = NSLocalizedString("退出", comment: "").decryptString() + "\n"
                    config.desc = NSLocalizedString("您确定要退出吗？", comment: "").decryptString()
                    config.negativeTitle = NSLocalizedString("取消", comment: "").decryptString()
                    config.positiveTitle = NSLocalizedString("确定", comment: "").decryptString()
                    config.negativeTitleColor = Color.ThemeColor
                    config.positiveTitleColor = Color.ThemeColor
                    alert = HFAlertController.alertController(config: config, ConfirmCallBack: {
                        // 退出登录
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                            hv.normalStyle()
                            // 清空当前的用户数据
                            UserDefaults.standard.setValue(nil, forKey: "UserInfoModel")
                            UserDefaults.standard.synchronize()
                            
                            // 更新首页头像信息
                            NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_RefreshUserPicture), object: nil)
                            
                        } catch let signOutError as NSError {
                            print ("Error signing out: %@", signOutError)
                        }
                    }) {
                        // 取消
                        alert?.dismiss(animated: true, completion: nil)
                    }
                    HFAppEngine.shared.currentViewController()?.present(alert!, animated: true, completion: nil)
                }else {
                    
                    Analytics.logEvent("login_start", parameters: nil)
                    
                    HFThirdPartyManager.shared.loginByThirdParty(type: .Google)
                }
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return (groups.count)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //获取组
        let group = groups.object(at: section) as! NSDictionary
        let item = group["items"] as! NSArray
        return (item.count)
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //获取组
        let group = groups.object(at: indexPath.section) as! NSDictionary
        let item = group["items"] as! NSArray
        let cellInfo = item[indexPath.row] as! NSDictionary
        let cell = MDSettingTableViewCell.cellForItem(tableView: tableView, item: cellInfo)
        //设置数据
        cell.cellInfo = cellInfo
        //        cell.backgroundColor = UIColor.md_cellBackgroundColor
        
        if indexPath.section == 0 && indexPath.row == 0 { // 头像设置
            let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 55, height: 35)))
//            view.backgroundColor = UIColor.purple
            let iv = UIImageView(image: UIImage(named: "img_head_n"))
            view.addSubview(iv)
            let iv1 = UIImageView(image: UIImage(named: "global_btn_right_n"))
            iv1.sizeToFit()
            view.addSubview(iv1)
            
            iv1.snp.makeConstraints { (make) in
                make.centerY.equalTo(iv.snp.centerY)
                make.left.equalTo(iv.snp.right).offset(13)
                make.right.equalToSuperview()
                make.width.equalTo(iv1.snp.width)
                make.height.equalTo(iv1.snp.height)
            }
            iv.snp.makeConstraints { (make) in
                make.left.top.bottom.equalToSuperview()
                make.width.height.equalTo(34)
                make.right.equalTo(iv1.snp.left)
            }
            cell.accessoryView = view
        }
        cell.selectionStyle = .none
        return cell
    }
    
    //处理点击事件
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //获取组
        let group = groups.object(at: indexPath.section) as! NSDictionary
        let item = group["items"] as! NSArray
        let cellInfo = item[indexPath.row] as! NSDictionary
        
        //判断targetVC   targetVC
        if let targetType = cellInfo["targetVC"] as? String {
            let vc = getVCByClassString(targetType)
            //判断是否是相同模板的设置界面跳转
            if (vc?.isKind(of: MDSettingController.self))! {
                let targetPlist = cellInfo["targetPlist"] as? String
                let targetVC = vc as! MDSettingController
                targetVC.plistName = targetPlist!
            }
            
            //设置控制器属性
            let title = cellInfo["title"] as? String
            vc?.title = title
            //跳转控制器
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
        //判断plist中是否配置有funcKey参数：有就执行方法
        if let funcKey = cellInfo["funcKey"] as? String {
            //将字符串转为一个可执行方法
            let sel = NSSelectorFromString(funcKey)
            //执行配置的方法
            self.perform(sel)
        }
        
        if let switcher = cellInfo["accessoryType"] as? String, switcher == "UISwitch" {
            if indexPath.row == 0 {
                if let sw = tableView.cellForRow(at: indexPath)?.accessoryView as? UISwitch, !sw.isOn {
                    // 隐藏另外的按钮
                    let tempItems = item
                    if var tms = tempItems as? [[String: Any]], tms.count == 5 {
                        tms.remove(at: 1)
                        tms.remove(at: 1)
                        let mutDics = NSMutableDictionary.init(dictionary: (groups[indexPath.section] as! NSDictionary))
                        mutDics.setValue(tms, forKey: "items")
                        let mutGroups = NSMutableArray.init(array: groups)
                        mutGroups[indexPath.section] = mutDics
                        groups = mutGroups
                        tableView.reloadData()
                    }else {
                        
                    }
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 0
        if section != 0 {
            height = 44
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //获取组
        var title = ""
        let group = groups.object(at: section) as! NSDictionary
        if let t = group["header"] as? String {
            title = t
        }
        return title
    }
    
}

//MARK: -- 根据类文件字符串转换为ViewController：自定义的类需要重写初始化方法：init否则报空nil
extension MPUserSettingViewController {
    /// 类文件字符串转换为ViewController
    /// - Parameter childControllerName: VC的字符串
    /// - Returns: ViewController
    func getVCByClassString(_ childControllerName: String) -> UIViewController?{
        
        // 1.获取命名空间
        // 通过字典的键来取值,如果键名不存在,那么取出来的值有可能就为没值.所以通过字典取出的值的类型为AnyObject?
        guard let clsName = Bundle.main.infoDictionary!["CFBundleExecutable"] else {
            print("命名空间不存在")
            return nil
        }
        // 2.通过命名空间和类名转换成类
        let cls : AnyClass? = NSClassFromString((clsName as! String) + "." + childControllerName)
        debugPrint(clsName)
        // swift 中通过Class创建一个对象,必须告诉系统Class的类型
        guard let clsType = cls as? UIViewController.Type else {
            print("无法转换成UIViewController")
            return nil
        }
        // 3.通过Class创建对象
        let childController = clsType.init()
        
        return childController
    }
}
// MARK: - 点击事件
extension MPUserSettingViewController {
    
    /// 定时关闭
    @objc func timeOff() {
        let vc = MPTimeOffViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /// 上传音乐
    @objc func uploadMusic() {
        let vc = MPUploadMusicViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /// 我的消息
    @objc func message() {
        SVProgressHUD.showInfo(withStatus: NSLocalizedString("目前不可用，请稍后再重试", comment: "").decryptString())
        return
    }
    /// 隐私政策
    @objc func policy() {
        let path = Bundle.main.path(forResource: "policy", ofType: "plist")
        if let p = path, let policys = NSDictionary(contentsOfFile: p) {
            let vc = MDWebViewController()
            vc.title = NSLocalizedString("隐私权政策", comment: "").decryptString()
            vc.text = policys["policy_1"] as! String
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    /// 意见反馈
    @objc func feedback() {
        
    }
    /// 去广告
    @objc func removeAd() {
        SVProgressHUD.showInfo(withStatus: NSLocalizedString("目前不可用，请稍后再重试", comment: "").decryptString())
        return
    }
}
import GoogleSignIn
extension MPUserSettingViewController: HFThirdPartyManagerDelegate {
    func GoogleLoginDidComlete(_ isSucced: Bool, _ msg: String, _ data: GIDGoogleUser?) {
        switch isSucced {
        case true:
            
            guard let authentication = data?.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if error != nil {
                    return
                }
                // firebase授权成功：获取用户信息
                if let userInfo = authResult?.additionalUserInfo?.profile {
                    guard let picture = userInfo["picture"] as? String, let name = userInfo["name"] as? String, let email = userInfo["email"] as? String else {
                        return
                    }
                    
                    var uid = userInfo["id"] as? String ?? ""
                    if uid == "" {
                        uid = userInfo["sub"] as? String ?? ""
                    }
                    
                    let did = UIDevice.current.identifierForVendor?.uuidString ?? "JA8888"
                    let t = MPUserSettingHeaderViewModel.init(picture: picture, name: name, email: email, uid: uid, did: did)
                    self.headerView.updateView(model: t)
                    
                    Analytics.logEvent("login_success", parameters: nil)
                    
                    // 异步保存用户信息
                    DispatchQueue.init(label: "SaveUserInfo").async {
                        DiscoverCent?.requestLogin(name: t.name, avatar: t.picture, contact: t.email, did: t.did, uid: t.uid, complete: { (isSucceed, msg) in
                            switch isSucceed {
                            case true:
//                                SVProgressHUD.showInfo(withStatus: "用户信息保存成功~")
                                //  用户已经登陆：拉去云端数据并合并到本地
                                DiscoverCent?.requestUserCloudList(contact: t.email, uid: t.uid, complete: { (isSucceed, model, msg) in
                                    switch isSucceed {
                                    case true:
                                        if let m = model, let local = DiscoverCent?.data_CloudListUploadModel {
                                            // 合并数据并赋值给本地模型
                                            MPModelTools.mergeLocalAndCloudListModel(local: local, cloud: m, finished: { (model) in
                                                DiscoverCent?.data_CloudListUploadModel = model
                                                // 通知更新列表数据
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_RefreshLocalModels), object: nil)
                                            })
                                        }
                                        break
                                    case false:
                                        SVProgressHUD.showError(withStatus: msg)
                                        break
                                    }
                                })
                                break
                            case false:
                                SVProgressHUD.showError(withStatus: msg)
                                break
                            }
                        })
                    }
                    
                }
               
            }
            
            break
        case false:
            
            Analytics.logEvent("login_failed", parameters: nil)
            
            SVProgressHUD.showError(withStatus: msg)
            break
        }
    }
}
