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
    
    @IBOutlet weak var playingBtn: UIButton!
    @IBOutlet weak var relatedBtn: UIButton!
    @IBOutlet weak var playingBv: UIView!
    @IBOutlet weak var relatedBv: UIView!
    
    var noDataView: MPNoDataView!
    
    var updateRelateSongsBlock: ((_ type: Int)->Void)?
    
    var model = [MPSongModel]() {
        didSet {
            tableView.reloadData()
            if model.count == 0 {
                noDataView.isHidden = false
            }else {
                noDataView.isHidden = true
            }
        }
    }
    
    var sourceType = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constant.identifier, bundle: nil), forCellReuseIdentifier: Constant.identifier)
        tableView.tableFooterView = UIView()
        
        setupNoDataView(image: "pic_noresault", text: NSLocalizedString("无歌曲列表", comment: ""))
    }
    
    private func setupNoDataView(image: String, text: String) {
        // 添加无数据提示View
        let sv = MPNoDataView.md_viewFromXIB() as! MPNoDataView
        let x: CGFloat = 20
        let y = tableView.height * 1/4
        let width = (tableView.width - 40)
        let height = SCREEN_WIDTH * (180/375)
        sv.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
        sv.updateView(image: image, text: text)
        sv.isHidden = true
        noDataView = sv
        tableView.addSubview(sv)
        //        sv.snp.makeConstraints { (make) in
        //            make.centerX.equalTo(tableView.centerX)
        //            make.centerY.equalTo(tableView.centerY).offset(-tableView.height*1/4)
        //            make.width.equalTo(width)
        //            make.height.equalTo(height)
        //        }
    }

    @IBAction func btn_DidClicked(_ sender: UIButton) {
        switch sender.tag {
        case 10001:
            if playingBv.isHidden {
                playingBv.isHidden = false
                relatedBv.isHidden = true
                playingBtn.setTitleColor(Color.ThemeColor, for: .normal)
                relatedBtn.setTitleColor(Color.FontColor_666, for: .normal)
                // 获取相关歌曲
                if let b = updateRelateSongsBlock {
                    b(0)
                }
            }
            break
        case 10002:
            if !playingBv.isHidden {
                playingBv.isHidden = true
                relatedBv.isHidden = false
                relatedBtn.setTitleColor(Color.ThemeColor, for: .normal)
                playingBtn.setTitleColor(Color.FontColor_666, for: .normal)
                // 获取相关歌曲
                if let b = updateRelateSongsBlock {
                    b(1)
                }
            }
            break
        case 10003:
            self.removeFromWindow()
            break
        default:
            break
        }
    }
}


extension MPPlayingListsPopView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.identifier) as! MPMediaLibraryTableViewCell
        cell.selectionStyle = .none
        cell.updateCell(model: model[indexPath.row], sourceType: self.sourceType)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.rowHeight
    }
}
