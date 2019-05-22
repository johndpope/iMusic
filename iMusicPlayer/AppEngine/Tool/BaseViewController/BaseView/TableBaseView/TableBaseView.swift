//
//  TableBaseView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/15.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class TableBaseView: BaseView {

    let tableView: UITableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       setupTableView()
    }
    
    open func setupTableHeaderView(){}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupTableView()
    }
    
    private func setupTableView() {
        self.addSubview(tableView)
//        tableView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        tableView.tableFooterView = UIView()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupTableHeaderView()
    }
    
    private static let plistPathName = "/songTools.plist"
    
    var plistName: String = "songTools" {
        didSet {
            initPlistData()
        }
    }
    
    var groups: NSArray = NSArray() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private func initData() {
        var arr = NSArray()
        let path = Bundle.main.path(forResource: self.plistName, ofType: "plist")
        arr = NSArray(contentsOfFile: path!)!
        debugPrint("arr --> \(arr)")
        self.groups = arr
    }
    
    
    private func initPlistData() {
        if self.plistName == "extensionTools" {
            let tempArr: [[String: Any]] = [["footer":"","items":[["icon":"icon_add_to_next-2","subTitleColor":"#999999","funcKey":"timeOff","titleColor":"#333333","title": NSLocalizedString("定时关闭", comment: ""),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""],["icon":"icon_add_to_next-1","subTitleColor":"#999999","funcKey":"playVideo","id":"1","title": NSLocalizedString("播放MV", comment: ""),"titleColor":"#333333","titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""],["icon":"icon_add_to_playlist-1","subTitleColor":"#999999","funcKey":"songInfo","titleColor":"#333333","title": NSLocalizedString("信息", comment: ""),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""]],"header":""]]
            self.groups = tempArr as NSArray
        }else if self.plistName == "createSLExtensionTools" {
            let tempArr: [[String: Any]] = [["footer":"","items":[["icon":"icon_add_to_next(1)","subTitleColor":"#999999","funcKey":"modifyAlbumName","titleColor":"#333333","title": NSLocalizedString("更改名称", comment: ""),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""],["icon":"icon_add_to_playlist(1)","subTitleColor":"#999999","funcKey":"deleteSongList","titleColor":"#333333","title": NSLocalizedString("删除", comment: ""),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""]],"header":""]]
            self.groups = tempArr as NSArray
        }else if self.plistName == "songTools" {
            let tempArr: [[String: Any]] = [["footer":"","items":[["icon":"icon_add","subTitleColor":"#999999","funcKey":"addToSongList","titleColor":"#333333","title": NSLocalizedString("加入到歌单", comment: ""),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""],["icon":"icon_add_to_next_1","subTitleColor":"#999999","funcKey":"nextPlay","titleColor":"#333333","title": NSLocalizedString("播放下一首", comment: ""),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""],["icon":"icon_add_to_playlist","subTitleColor":"#999999","funcKey":"addToPlayList","titleColor":"#333333","title": NSLocalizedString("添加到当前播放列表", comment: ""),"titleFontSize":14,"subTitleFontSize":12,"cellStyle":"value1","accessoryType":"UIImageView","accessoryView":""]],"header":""]]
            self.groups = tempArr as NSArray
        }else {
            initData()
        }
    }
    
}
extension TableBaseView: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return (groups.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //获取组
        let group = groups.object(at: section) as! NSDictionary
        let item = group["items"] as! NSArray
        return (item.count)
    }
    
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            HFAppEngine.shared.currentViewController()?.navigationController?.pushViewController(vc!, animated: true)
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
extension TableBaseView {
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
