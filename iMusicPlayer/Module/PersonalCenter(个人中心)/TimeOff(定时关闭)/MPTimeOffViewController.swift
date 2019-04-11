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
    
    var headerView: MPTimeOffHeaderView?
    
    var dataSources = MPTimeOffModel().models()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 获取当前的定时任务
        if AppEngine!.generalTimerTime > 0 {
            AppEngine?.runGeneralTimerTimer(duration: 60, callback: { [weak self] (time, _) in
                self?.updateHeaderView(time: time)
            })
        }
        
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
        headerView = hv
        tableView.tableHeaderView = hv
    }
    
}
extension MPTimeOffViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        if let titles = dataSources["titles"] as? [String]{
            num = titles.count
        }
        return num
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPTimeOffTableViewCell
        cell.selectionStyle = .none
        if let titles = dataSources["titles"] as? [String], let selecteds = dataSources["selected"] as? [Bool] {
            cell.updateCell(model: titles[indexPath.row])
            cell.markSelected = selecteds[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 设置选中状态
        var tempSels = MPTimeOffModel.selecteds
        tempSels[indexPath.row] = true
        dataSources["selected"] = tempSels
        tableView.reloadData()
        
        if indexPath.row ==  MPTimeOffModel.titleDatas.count - 1 {
            let pv = MPTimeOffPopView.md_viewFromXIB(cornerRadius: 4) as! MPTimeOffPopView
            pv.bounds = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH-40, height: pv.height))
            HFAlertController.showCustomView(view: pv)
            
            pv.clickBlock = {(sender) in
                if let btn = sender as? UIButton {
                    if btn.tag == 10001 {
                        pv.removeFromWindow()
                    }else {
                        if let time = Double(pv.xib_time.text ?? "0") {
                            // 停止当前的定时器开启新的定时器
                            HFAppEngine.shared.stopGeneralTimer()
                            self.handleTimerAction(time: time)
                            pv.removeFromWindow()
                        }
                    }
                }
            }
            
        }else {
            var time: Double = 0
            switch indexPath.row {
            case 0: // 不开启定时任务：结束当前定时任务
                time = 0
                break
            case 1: // 15
                time = 15
                break
            case 2: // 30
                time = 30
                break
            case 3: // 45
                time = 45
                break
            case 4: // 60
                time = 60
                break
            default:
                break
            }
            // 停止当前的定时器开启新的定时器
            HFAppEngine.shared.stopGeneralTimer()
            self.handleTimerAction(time: time)
        }
    }
    
}
// MARK: - 处理定时任务
extension MPTimeOffViewController {
    
    /// 指定时间内关闭播放任务
    ///
    /// - Parameter time: 时间
    private func handleTimerAction(time: Double) {
        let seconds: Int = Int(time * 60)
        // 开启计时器
        HFAppEngine.shared.runGeneralTimerTimer(duration: seconds, callback: { (time, changeTime) in
            self.updateHeaderView(time: time)
        })
    }
    
    private func updateHeaderView(time: Int) {
        
        if time == 0 {
            self.endTimerAction()
            return
        }
        
        //分钟计算
        let minutes = (time)/60;
        //秒计算
        let second = (time)%60;
        var str = NSLocalizedString("计时结束后，将暂停播放歌曲", comment: "")
        if minutes == 0 && second == 0 {
            str = NSLocalizedString("计时结束后，将暂停播放歌曲", comment: "")
        }else {
            str = "\(minutes)" + NSLocalizedString("分", comment: "") + "\(second)" + NSLocalizedString("秒", comment: "") + NSLocalizedString("后，将暂停播放歌曲", comment: "")
        }
        QYTools.shared.Log(log: str)
        // 更新title
        self.headerView?.model = str
    }
    
    /// 计时任务结束：关闭播放控制、提示蒙版
    private func endTimerAction() {
        // 显示当前的播放View
        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
            // 暂停播放隐藏播放窗口
            pv.playView?.pauseVideo()
            pv.hiddenStyle()
            // 显示倒计时结束蒙版
            let pv = MPTimeOffEndView.md_viewFromXIB() as! MPTimeOffEndView
            pv.bounds = window.frame
            HFAlertController.showCustomView(view: pv)
        }
    }
}
