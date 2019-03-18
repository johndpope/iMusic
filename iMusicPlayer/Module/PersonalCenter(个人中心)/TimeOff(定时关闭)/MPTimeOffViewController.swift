//
//  MPTimeOffViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPTimeOffTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (45/375)
}

class MPTimeOffViewController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("定时关闭", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
    }
    
    override func clickLeft() {
        super.clickLeft()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func setupTableView() {
        super.setupTableView()
        tableView.backgroundColor = UIColor.white
        self.identifier = Constant.identifier
        
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPTimeOffHeaderView.md_viewFromXIB() as! MPTimeOffHeaderView
        tableView.tableHeaderView = hv
    }
    
}
extension MPTimeOffViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MPTimeOffModel.titleDatas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPTimeOffTableViewCell
        cell.selectionStyle = .none
        cell.updateCell(model: MPTimeOffModel.titleDatas[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 设置选中状态
        let cell = tableView.cellForRow(at: indexPath)
        (cell as! MPTimeOffTableViewCell).markSelected = true
        if indexPath.row ==  MPTimeOffModel.titleDatas.count - 1 {
            let pv = MPTimeOffPopView.md_viewFromXIB(cornerRadius: 4) as! MPTimeOffPopView
            pv.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH-40, height: pv.height))
            HFAlertController.showCustomView(view: pv)
        }
    }
}
