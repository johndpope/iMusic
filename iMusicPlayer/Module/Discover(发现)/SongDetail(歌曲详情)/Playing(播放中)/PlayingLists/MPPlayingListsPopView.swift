//
//  MPPlayingListsPopView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPMediaLibraryTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (52/375)
}

class MPPlayingListsPopView: UITableViewCell {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var playingBv: UIView!
    @IBOutlet weak var relatedBv: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constant.identifier, bundle: nil), forCellReuseIdentifier: Constant.identifier)
        tableView.tableFooterView = UIView()
    }

    @IBAction func btn_DidClicked(_ sender: UIButton) {
        switch sender.tag {
        case 10001:
            playingBv.isHidden = false
            relatedBv.isHidden = true
            break
        case 10002:
            playingBv.isHidden = true
            relatedBv.isHidden = false
            break
        case 10003:
            if let sv = self.superview {
                sv.removeFromSuperview()
            }
            break
        default:
            break
        }
    }
}


extension MPPlayingListsPopView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [5,8,3].randomElement()!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.identifier) as! MPMediaLibraryTableViewCell
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
