//
//  MPRankingViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/14.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPRankingTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (124/375)
}

class MPRankingViewController: BaseTableViewController {
    
    var tempModels: Charts? {
        didSet {
            if let t = tempModels {
                models = self.mappingToMPRankingTempModel(model: t)
            }
        }
    }
    
    var models = [MPRankingTempModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("排行榜", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
    }
    
    override func clickLeft() {
        super.clickLeft()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.identifier
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
    }
    
    override func refreshData() {
        super.refreshData()
        
//        models = MPRankingModel.getModel()
//        tableView.mj_header.endRefreshing()
    }
    
}
extension MPRankingViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MPRankingTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPRankingTableViewCell
        cell.updateCell(model: models[indexPath.row])
        cell.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                if var source = self.models[indexPath.row].data_title {
                    source.removeLast()
                    let tableName = source
                    NSArray.bg_drop(source)
                    MPModelTools.getRankingModel(rankType: source, tableName: source) { (models) in
                        if let m = models {
                            self.play(model: m, headerModel: self.models[indexPath.row])
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MPAlbumListViewController()
        vc.headerModel = models[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension MPRankingViewController {
    func mappingToMPRankingTempModel(model: Charts) -> [MPRankingTempModel]  {
        var temps = [MPRankingTempModel]()
        if let oricon = model.data_oricon, oricon.count > 0 {
            let tempM = MPRankingTempModel(image: "img_ranking_oricon", title: "Oricon" + NSLocalizedString("榜", comment: ""), updateTime: NSLocalizedString("每周三更新", comment: ""), songOne: oricon.first?.data_title, songTwo: oricon[1].data_title)
            temps.append(tempM)
        }
        if let mnet = model.data_mnet, mnet.count > 0 {
            let tempM = MPRankingTempModel(image: "img_ranking_ment", title: "Ment" + NSLocalizedString("榜", comment: ""), updateTime: NSLocalizedString("每周一更新", comment: ""), songOne: mnet.first?.data_title, songTwo: mnet[1].data_title)
            temps.append(tempM)
        }
        if let billboard = model.data_billboard, billboard.count > 0 {
            let tempM = MPRankingTempModel(image: "img_ranking_billboard", title: "Billboard" + NSLocalizedString("榜", comment: ""), updateTime: NSLocalizedString("每周三更新", comment: ""), songOne: billboard.first?.data_title, songTwo: billboard[1].data_title)
            temps.append(tempM)
        }
        if let iTunes = model.data_iTunes, iTunes.count > 0 {
            let tempM = MPRankingTempModel(image: "img_ranking_itunes", title: "ITunes" + NSLocalizedString("榜", comment: ""), updateTime: NSLocalizedString("每周一更新", comment: ""), songOne: iTunes.first?.data_title, songTwo: iTunes[1].data_title)
            temps.append(tempM)
        }
        if let listen = model.data_listen, listen.count > 0 {
            let tempM = MPRankingTempModel(image: "img_ranking_musicz_play", title: "Listen" + NSLocalizedString("榜", comment: ""), updateTime: NSLocalizedString("每日更新", comment: ""), songOne: listen.first?.data_title, songTwo: listen[1].data_title)
            temps.append(tempM)
        }
        if let collection = model.data_collection, collection.count > 0 {
            let tempM = MPRankingTempModel(image: "img_ranking_collection", title: "Collection" + NSLocalizedString("榜", comment: ""), updateTime: NSLocalizedString("每日更新", comment: ""), songOne: collection.first?.data_title, songTwo: collection[1].data_title)
            temps.append(tempM)
        }
        if let uK = model.data_uK, uK.count > 0 {
            let tempM = MPRankingTempModel(image: "img_ranking_uk", title: "UK" + NSLocalizedString("榜", comment: ""), updateTime: NSLocalizedString("每周一更新", comment: ""), songOne: uK.first?.data_title, songTwo: uK[1].data_title)
            temps.append(tempM)
        }
        return temps
    }
}

import ObjectMapper
extension MPRankingViewController {
    private func play(index: Int = -1, model: [MPSongModel], headerModel: MPRankingTempModel) {
        // 显示当前的播放View
//        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
//            var cs: MPSongModel?
//            // 循序不能倒过来
//            if index != -1 {
//                cs = model[index]
//            }else {
//                cs = model.first
//            }
//            // 随机播放
//            pv.currentSong = cs
//            pv.model = model
//            // 构造当前播放专辑列表模型
//            let json: [String : Any] = ["id": 0, "title": headerModel.data_title ?? "", "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": headerModel.data_image ?? "pic_album_default", "tracksCount": model.count, "recentlyType": 6]
//            //        let album = GeneralPlaylists(JSON: json)
//            let album = Mapper<GeneralPlaylists>().map(JSON: json)
//            pv.currentAlbum = album
//            pv.bigStyle()
//        }
        
        // 构造当前播放专辑列表模型
        let json: [String : Any] = ["id": 0, "title": headerModel.data_title ?? "", "description": "", "originalId": "PLw-EF7Go2fRtjDCxwUkcvIuhR1Lip-Hl2", "type": "YouTube", "img": headerModel.data_image ?? "pic_album_default", "tracksCount": model.count, "recentlyType": 6]
        let album = GeneralPlaylists(JSON: json)
        album?.data_songs = model
        MPModelTools.saveRecentlyAlbum(album: album!)
        
        model[index == -1 ? 0 : index].data_playingStatus = 1
        
        MPModelTools.saveCurrentPlayList(currentList: model)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, userInfo: ["randomMode" : 0])
//        NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_PlayCurrentList), object: nil)
    }
}
