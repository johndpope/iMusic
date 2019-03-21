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
        tableView.register(UINib(nibName: Constant.songIdentifier, bundle: nil), forCellReuseIdentifier: Constant.songIdentifier)
        tableView.register(UINib(nibName: Constant.mvIdentifier, bundle: nil), forCellReuseIdentifier: Constant.mvIdentifier)
        tableView.register(UINib(nibName: Constant.collectionIdentifier, bundle: nil), forCellReuseIdentifier: Constant.collectionIdentifier)
        tableView.register(UINib(nibName: Constant.songListIdentifier, bundle: nil), forCellReuseIdentifier: Constant.songListIdentifier)
        
        tableView.tableFooterView = UIView()
        
        setupHeaderView()
    }
    
    private func setupHeaderView() {
        let hv = MPSearchResultHeaderView.md_viewFromXIB() as! MPSearchResultHeaderView
        tableView.tableHeaderView = hv
        hv.segmentChangeBlock = {(index) in
            self.currentIndex = index
        }
        hv.frameChangeBlock = {
            self.tableView.reloadData()
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
        var num = 10
        if currentIndex == 1, section == 0 {
            num = 1
        }
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch currentIndex {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.songIdentifier) as! MPSRSongTableViewCell
            break
        case 1:
            if indexPath.section == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: Constant.collectionIdentifier) as! MPSRCollectionTableViewCell
            }else {
                cell = tableView.dequeueReusableCell(withIdentifier: Constant.mvIdentifier) as! MPSRMVTableViewCell
            }
            break
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: Constant.songListIdentifier) as! MPSRSongListTableViewCell
            break
        default:
            break
        }
        
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
    
}
