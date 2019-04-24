//
//  MPSearchResultView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/20.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let songIdentifier = "MPSRSongTableViewCell"
    static let mvIdentifier = "MPSRMVTableViewCell"
    static let collectionIdentifier = "MPSRCollectionTableViewCell"
    static let songListIdentifier = "MPSRSongListTableViewCell"
    static let songRowHeight = SCREEN_WIDTH * (46/375)
    static let mvRowHeight = SCREEN_WIDTH * (46/375)
    static let collectionRowHeight = SCREEN_WIDTH * (76/375)
    static let songListRowHeight = SCREEN_WIDTH * (100/375)
}

class MPSearchResultView: BaseView {
    
    var itemClickedBlock: ((_ duration: String, _ filter: String, _ order: String, _ segIndex: Int) -> Void)?
    
    var model: MPSearchResultModel? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentIndex: Int = 0 {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let tableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "MPSongTableViewCell", bundle: nil), forCellReuseIdentifier: Constant.songIdentifier)
        tableView.register(UINib(nibName: "MPSongTableViewCell", bundle: nil), forCellReuseIdentifier: Constant.mvIdentifier)
        tableView.register(UINib(nibName: Constant.collectionIdentifier, bundle: nil), forCellReuseIdentifier: Constant.collectionIdentifier)
        tableView.register(UINib(nibName: "MPDiscoverTableViewCell", bundle: nil), forCellReuseIdentifier: Constant.songListIdentifier)
        
        QYTools.refreshData(target: self, scrollView: tableView, refresh: #selector(refreshData), loadMore: #selector(pageTurning))
        
        tableView.tableFooterView = UIView()
        
        setupHeaderView()
    }
    
    /// 刷新数据
    @objc open func refreshData() {}
    
    /// 数据翻页
    @objc open func pageTurning() {}
    
    private func setupHeaderView() {
        let hv = MPSearchResultHeaderView.md_viewFromXIB() as! MPSearchResultHeaderView
        tableView.tableHeaderView = hv
        hv.segmentChangeBlock = {(index) in
            self.currentIndex = index
        }
        hv.frameChangeBlock = {
            self.tableView.reloadData()
        }
        
        hv.itemClickedBlock = {(duration, filter, order) in
            if let b = self.itemClickedBlock {
                b(duration, filter, order, self.currentIndex)
            }
        }
    }
    
}
extension MPSearchResultView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        var num = 1
        if currentIndex == 1 {
            num = 2
        }
        return num
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        if currentIndex == 1, section == 0 {
            if let m = model?.data_collection, m.count > 0 {
                num = 1
            }
        }else {
            if currentIndex == 0 {
                num = model?.data_songs?.count ?? 0
            }else if currentIndex == 1 {
                num = model?.data_videos?.count ?? 0
            }else if currentIndex == 2 {
                num = model?.data_playlists?.count ?? 0
            }
        }
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch currentIndex {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.songIdentifier) as! MPSongTableViewCell
            if let models = model?.data_songs {
                (cell as! MPSongTableViewCell).updateCell(model: models[indexPath.row], models: models)
            }
            break
        case 1:
            if indexPath.section == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: Constant.collectionIdentifier) as! MPSRCollectionTableViewCell
                if let models = model?.data_collection {
                    (cell as! MPSRCollectionTableViewCell).updateCell(model: models[indexPath.row])
                }
            }else {
                cell = tableView.dequeueReusableCell(withIdentifier: Constant.mvIdentifier) as! MPSongTableViewCell
                if let models = model?.data_videos {
                    if let amodels = model?.data_collection, amodels.count > 0 {
                        (cell as! MPSongTableViewCell).updateCell(model: models[indexPath.row], models: models, album: amodels[0], sourceType: 1)
                    }else {
                        (cell as! MPSongTableViewCell).updateCell(model: models[indexPath.row], models: models, sourceType: 1)
                    }
                }
            }
            break
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.songListIdentifier) as! MPDiscoverTableViewCell
            if let models = model?.data_playlists {
                (cell as! MPDiscoverTableViewCell).updateCell(model: models[indexPath.row], type: 1)
                (cell as! MPDiscoverTableViewCell).clickBlock = {(sender) in
                    if let btn = sender as? UIButton {
                        DiscoverCent?.requestSearchSongListByYoutube(playlistId: models[indexPath.row].data_originalId ?? "", pageToken: "", complete: { (isSucceed, model, msg) in
                            switch isSucceed {
                            case true:
                                if let m = model?.data_songs {
                                    self.play(model: m, headerSongModel: models[indexPath.row])
                                }
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
        default:
            break
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        switch currentIndex {
        case 0:
            height = Constant.songRowHeight
            break
        case 1:
            if indexPath.section == 0 {
                height = Constant.collectionRowHeight
            }else {
                height = Constant.mvRowHeight
            }
            break
        case 2:
            height = Constant.songListRowHeight
            break
        default:
            break
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch currentIndex {
        case 0:
            break
        case 1:
            if indexPath.section == 0 {
                if let models = model?.data_collection {
                    let vc = MPSongListViewController()
                    vc.headerSongModel = models[indexPath.row]
                    vc.type = 3
                    HFAppEngine.shared.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
                }
            }else {
            }
            break
        case 2:
            if let models = model?.data_playlists {
                let vc = MPSongListViewController()
                vc.headerSongModel = models[indexPath.row]
                vc.type = 3
                HFAppEngine.shared.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
            }
            break
        default:
            break
        }
    }
    
}
extension MPSearchResultView {
    private func play(index: Int = -1, model: [MPSongModel], headerSongModel: GeneralPlaylists) {
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
//            pv.currentSouceType = 0
//            pv.currentSong = cs
//            pv.model = model
//            pv.currentAlbum = headerSongModel
//            pv.bigStyle()
//        }
        
        model[index == -1 ? 0 : index].data_playingStatus = 1
        
        MPModelTools.saveCurrentPlayList(currentList: model)
        
        NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_PlayCurrentList), object: nil)
    }
}
