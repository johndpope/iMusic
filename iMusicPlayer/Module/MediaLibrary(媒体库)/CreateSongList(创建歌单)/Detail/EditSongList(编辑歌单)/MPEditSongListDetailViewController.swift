//
//  MPEditSongListDetailViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPEditSongListDetailTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
    static let topHeight = SCREEN_WIDTH * (48/375)
}

class MPEditSongListDetailViewController: BaseTableViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewH: NSLayoutConstraint! {
        didSet {
            topViewH.constant = NavBarHeight
        }
    }
    @IBOutlet weak var xib_selectAll: UIButton!
    
    var model = [MPSongModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        view.sendSubviewToBack(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.bottom.equalTo(self.view.safeArea.bottom).offset(-Constant.rowHeight)
            make.top.equalToSuperview().offset(topViewH.constant)
        }

    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.identifier
        tableView.backgroundColor = UIColor.white
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
        // 将tableView往下挤
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH, height: Constant.topHeight)))
    }
    
    @IBAction func btn_DidClicked(_ sender: UIButton) {
        if sender.tag == 10001 {    // 全选
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                self.selectAll()
            }else {
                self.normalAll()
            }
        }else { // 完成
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
extension MPEditSongListDetailViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPEditSongListDetailTableViewCell
        cell.updateCell(model: model[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.model[indexPath.row].data_isSelected = self.model[indexPath.row].data_isSelected == 1 ? 0 : 1
//        tableView.reloadData()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        checkSelectAll()
    }
}
// MARK: - 操作是否选中
extension MPEditSongListDetailViewController {
    
    /// 是否需要全选
    private func checkSelectAll() {
        var count = 0
        model.forEach { (item) in
            if item.data_isSelected == 1 {
                count++
            }
        }
        if count == model.count {
            self.selectAll()
        }else {
            xib_selectAll.isSelected = false
        }
    }
    
    /// 全选
    private func selectAll() {
        model.forEach { (item) in
            item.data_isSelected = 1
        }
        xib_selectAll.isSelected = true
        tableView.reloadData()
    }
    
    /// 反选
    private func normalAll() {
        model.forEach { (item) in
            item.data_isSelected = 0
        }
        xib_selectAll.isSelected = false
        tableView.reloadData()
    }
}

extension MPEditSongListDetailViewController {
    func addToSongList(song: MPSongModel) {
        let lv = MPAddToSongListView.md_viewFromXIB() as! MPAddToSongListView
        MPModelTools.getCollectListModel(tableName: MPCreateSongListViewController.classCode) { (model) in
            if let m = model {
                lv.model = m
            }
        }
        // 新建歌单
        lv.createSongListBlock = {
            let pv = MPCreateSongListView.md_viewFromXIB(cornerRadius: 4) as! MPCreateSongListView
            pv.clickBlock = {(sender) in
                if let btn = sender as? UIButton {
                    if btn.tag == 10001 {
                        pv.removeFromWindow()
                    }else {
                        // 新建歌单操作
                        if MPModelTools.createSongList(songListName: pv.xib_songListName.text ?? "") {
                            // 刷新数据
                            MPModelTools.getCollectListModel(tableName: MPCreateSongListViewController.classCode) { (model) in
                                if let m = model {
                                    lv.model = m
                                }
                            }
                        }else {
                            SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌单已存在", comment: ""))
                        }
                        pv.removeFromWindow()
                    }
                }
            }
            HFAlertController.showCustomView(view: pv)
        }
        
        // 加入歌单
        lv.addSongListBlock = {(songList) in
            if let tn = songList.data_title {
                if !MPModelTools.checkSongExsistInSongList(song: song, songList: songList) {
                    MPModelTools.saveSongToTable(song: song, tableName: tn)
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲添加成功", comment: ""))
                    // 更新当前歌单图片及数量：+1
                    MPModelTools.updateCountForSongList(songList: songList, finished: {
                        lv.removeFromWindow()
                    })
                }else {
                    SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已在该歌单中", comment: ""))
                }
            }
        }
        
        HFAlertController.showCustomView(view: lv, type: HFAlertType.ActionSheet)
    }
    
    func nextPlay(song: MPSongModel) {
        // 添加到播放列表的下一首: 判断是否在列表中：在则调换到下一首，不在则添加到下一首
        if !MPModelTools.checkSongExsistInPlayingList(song: song) {
            MPModelTools.getCurrentPlayList { (model, currentPlaySong) in
                if var m = model, let cs = currentPlaySong {
                    let index = self.getIndexFromSongs(song: cs, songs: m)
                    let nextIndex = (index+1)%m.count
                    m.insert(song, at: nextIndex)
                }
            }
        }else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已在播放列表中", comment: ""))
        }
    }
    
    func addToPlayList(song: MPSongModel) {
        // 添加到播放列表: 判断是否在列表中：不在则添加
        if !MPModelTools.checkSongExsistInPlayingList(song: song) {
            MPModelTools.getCurrentPlayList { (model, currentPlaySong) in
                if var m = model {
                    m.append(song)
                }
            }
        }else {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("歌曲已在播放列表中", comment: ""))
        }
    }
    
    // 获取当前下标
    private func getIndexFromSongs(song: MPSongModel, songs: [MPSongModel]) -> Int {
        var index = 0
        for i in (0..<songs.count) {
            if song == songs[i] {
                index = i
            }
        }
        return index
    }
    
}
