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
            self.tableView.reloadData()
        }
    }
    
}
extension MPSearchResultView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.songIdentifier) as! MPSRSongTableViewCell
        return cell
    }
    
}
