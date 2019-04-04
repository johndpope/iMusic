//
//  MPMediaLibraryCollectionViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPMediaLibraryCollectionViewCell: UICollectionViewCell {
    
    var model = [MPSongModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var tempModel = [MPSongModel]()
    
    var currentAlbum: GeneralPlaylists?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constant.identifier, bundle: nil), forCellReuseIdentifier: Constant.identifier)
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
    }
    
}
private struct Constant {
    static let identifier = "MPSongTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
}

extension MPMediaLibraryCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.identifier) as! MPSongTableViewCell
        cell.selectionStyle = .none
        cell.updateCell(model: model[indexPath.row], models: self.tempModel, album: currentAlbum)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
