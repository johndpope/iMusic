//
//  MDSettingTableViewCell.swift
//  Lottery
//
//  Created by mac on 2018/3/19.
//  Copyright © 2018年 modi. All rights reserved.
//

import UIKit

class MDSettingTableViewCell: UITableViewCell {

    var cellInfo: NSDictionary = [:] {
        didSet {
            setupData()
        }
    }
    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    var switcherBlock: ((_ sw: UISwitch, _ index: Int)->Void)?
    
    private func setupData() {
        //设置标题文字
        self.textLabel?.text = cellInfo["title"] as? String
        
        if let tColor = cellInfo["titleColor"] as? String {
            self.textLabel?.textColor = UIColor.init(rgba: tColor)
        }
        
        if let tFontSize = cellInfo["titleFontSize"] as? CGFloat {
            self.textLabel?.font = UIFont.systemFont(ofSize: tFontSize)
        }
        
        //设置副标题：为空默认不显示
        self.detailTextLabel?.text = cellInfo["subTitle"] as? String
        
        //判断副标题是否有特定颜色
        if let subColor = cellInfo["subTitleColor"] as? String {
            debugPrint("subColor ----> \(subColor)")
            self.detailTextLabel?.textColor = UIColor.init(rgba: subColor)
        }
        
        if let stFontSize = cellInfo["subTitleFontSize"] as? CGFloat {
            self.detailTextLabel?.font = UIFont.systemFont(ofSize: stFontSize)
        }
        
        //设置图标
        if let icon = cellInfo["icon"] as? String {
            let image = UIImage(named: icon)
            self.imageView?.image = image
            let item = CGSize(width: 36, height: 36)
            UIGraphicsBeginImageContextWithOptions(item, false, UIScreen.main.scale)
            let rect = CGRect(x: 0, y: 0, width: item.width, height: item.height)
            self.imageView?.image?.draw(in: rect)
            self.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        //通过plist中类型判断View类型在动态的设置accessoryView
        if let accesoryType = cellInfo["accessoryType"] as? String {
            let clz = NSClassFromString(accesoryType)
//            debugPrint("view ---> \(clz)")
            let viewcls = clz as! UIView.Type
            let view = viewcls.init()
            if view.isKind(of: UIImageView.self) {
                let accesoryView = cellInfo["accessoryView"] as? String
                let iv = view as! UIImageView
                iv.image = UIImage(named: accesoryView!)
                //设置大小：否则不显示
                iv.sizeToFit()
            }else if view.isKind(of: UISwitch.self) {
                let switcher = view as! UISwitch
                //添加开关监听事件
                switcher.addTarget(self, action: #selector(self.switchChange(sender:)), for: .valueChanged)
                
                //恢复开关状态
                if let switchKey = cellInfo["switchKey"] as? String {
                    let ud = UserDefaults.standard
                    if let isOn = ud.value(forKey: switchKey) as? Bool {
                        switcher.isOn = isOn
                    }
                }
                
            }
            self.accessoryView = view
        }
    }
    
    @objc private func switchChange(sender: UISwitch) {
        //保存开关状态：userdefault
        let ud = UserDefaults.standard
        //根据不同的UISwitch设置不同的key
        if let switchKey = cellInfo["switchKey"] as? String {
            ud.set(sender.isOn, forKey: switchKey)
            //同步:立即保存
            ud.synchronize()
            
            debugPrint("Home ----> \(NSHomeDirectory())")
        }

        if let b = self.switcherBlock, let title = self.textLabel?.text {
            var index = 0
            switch title {
            case "推送开关":
                index = 0
                break
            case "通知铃声":
                index = 1
                break
            case "小红点通知":
                index = 2
                break
            default:
                break
            }
            b(sender, index)
        }
        
    }
    
    class func cellForItem(tableView: UITableView, item: NSDictionary) -> MDSettingTableViewCell {
        
        //重用ID：当Cell的style类型不同时用同一个ID会出现两种不同类型的Cell错误显示：不同类型需要设置不同重用ID
        var ID = "CELL"
        if let cellStyle = item["cellStyle"] as? String {
            ID = cellStyle
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: ID) as? MDSettingTableViewCell
        if cell == nil {
            if let cellStyle = item["cellStyle"] as? String {
                cell = MDSettingTableViewCell(style: getCellStyle(cs: cellStyle), reuseIdentifier: ID)
            }else {
                cell = MDSettingTableViewCell(style: .default, reuseIdentifier: ID)
            }
        }
        return cell!
    }
    
    class private func getCellStyle(cs: String) -> UITableViewCell.CellStyle {
        var style: UITableViewCell.CellStyle?
        switch cs {
        case "default":
            style = UITableViewCell.CellStyle.default
        case "value1":
            style = UITableViewCell.CellStyle.value1
        case "value2":
            style = UITableViewCell.CellStyle.value2
        case "subtitle":
            style = UITableViewCell.CellStyle.subtitle
        default:
            style = UITableViewCell.CellStyle.default
        }
        return style!
    }

}
