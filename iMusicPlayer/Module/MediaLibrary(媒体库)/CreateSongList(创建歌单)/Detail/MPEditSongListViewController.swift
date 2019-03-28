//
//  MPEditSongListViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/19.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPSongTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
    static let detailVcName = "MPEditSongListDetailViewController"
}

class MPEditSongListViewController: BaseTableViewController {
    
    var songListModel: GeneralPlaylists? {
        didSet {
            MPModelTools.getSongInTable(tableName: songListModel?.data_title ?? "") { (model) in
                if let m = model {
                    self.model = m
                }
            }
        }
    }
    
    var model = [MPSongModel]() {
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
        
        addLeftItem(title: NSLocalizedString(songListModel?.data_title ?? "", comment: ""), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
    }
    
    override func clickLeft() {
        super.clickLeft()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        self.identifier = Constant.identifier
        tableView.backgroundColor = UIColor.white
    }
    
    override func setupTableHeaderView() {
        super.setupTableHeaderView()
        
        let hv = MPEditSongListHeaderView.md_viewFromXIB() as! MPEditSongListHeaderView
        hv.count = songListModel?.data_tracksCount ?? 0
        hv.md_btnDidClickedBlock = {[weak self] (sender) in
            if sender.tag == 10001 {
                
            }else {
                let vc = MPEditSongListDetailViewController.init(nibName: Constant.detailVcName, bundle: nil)
                if let m = self?.model {
                    vc.model = m
                }
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        tableView.tableHeaderView = hv
    }
    
}
extension MPEditSongListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) as! MPSongTableViewCell
        cell.updateCell(model: model[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
