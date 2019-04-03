//
//  MPPlayingView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/21.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

private struct Constant {
    static let identifier = "MPPlayingViewCollectionViewCell"
    static let rowHeight = SCREEN_WIDTH * (48/375)
}

protocol MPPlayingViewDelegate {
    func playingView(toDetail view: MPPlayingView)
    func playingView(download view: MPPlayingView)
    func playingView(play view: MPPlayingView, status: Bool)
}

class MPPlayingView: BaseView {
    
    var delegate: MPPlayingViewDelegate?
    
    var currentSong: MPSongModel?

    var model = [MPSongModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var currentStatus: Bool = false
    
    // MARK: - TableView
    private lazy var collectionView: UICollectionView  = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.layout = layout
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(UINib(nibName: Constant.identifier, bundle: nil), forCellWithReuseIdentifier: Constant.identifier)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = UIColor.white
        cv.bounces = true
        cv.isPagingEnabled = true
        return cv
    }()
    
    /// 向外提供布局变量
    open var layout: UICollectionViewFlowLayout?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        
        collectionView.backgroundView = nil
        collectionView.backgroundColor = UIColor.clear
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
extension MPPlayingView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.identifier, for: indexPath) as! MPPlayingViewCollectionViewCell
        cell.updateCell(model: model[indexPath.row])
        cell.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                switch btn.tag {
                case 10001: // 播放详情
                    if let d = self.delegate {
                        d.playingView(toDetail: self)
                    }
                    break
                case 10002: // 下载、收藏
                    if let d = self.delegate {
                        d.playingView(download: self)
                    }
                    break
                case 10003: // 暂停、播放
                    if let d = self.delegate {
                        d.playingView(play: self, status: self.currentStatus)
                    }
                    break
                default:
                    break
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: SCREEN_WIDTH, height: Constant.rowHeight)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
