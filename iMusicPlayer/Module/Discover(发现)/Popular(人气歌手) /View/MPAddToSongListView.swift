//
//  MPAddToSongListView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/15.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPAddToSongListTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (58/375)
}

class MPAddToSongListView: BaseView {
    
    @IBOutlet weak var tableView: UITableView!
    
    var createSongListBlock: (()->Void)?
    
    var addSongListBlock: ((_ model: GeneralPlaylists)->Void)?
    
    var model = [GeneralPlaylists]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: Constant.identifier, bundle: nil), forCellReuseIdentifier: Constant.identifier)
    }
    
}

extension MPAddToSongListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.identifier) as! MPAddToSongListTableViewCell
        if indexPath.row == 0 {
            cell.type = 1
        }else {
            cell.updateCell(model: model[indexPath.row - 1])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let b = createSongListBlock {
                b()
            }
        }else {
            if let b = addSongListBlock {
                let m = model[indexPath.row - 1]
                b(m)
            }
        }
    }
    
}
