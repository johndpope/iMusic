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
    func playingView(download view: MPPlayingView) -> Bool
    func playingView(play view: MPPlayingView, status: Bool)
    func playingView(pre view: MPPlayingView, index: Int)
    func playingView(next view: MPPlayingView, index: Int)
}

class MPPlayingView: BaseView {
    
    var delegate: MPPlayingViewDelegate?
    
    var currentIndex: Int = 0

    var model = [MPSongModel]() {
        didSet {
            collectionView.reloadData()
            
            collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    var currentStatus: Bool = false {
        didSet {
            let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0))
            (cell as? MPPlayingViewCollectionViewCell)?.xib_play.isSelected = currentStatus
        }
    }
    
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
                        if d.playingView(download: self) {
                            collectionView.reloadItems(at: [indexPath])
                        }
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
    
    // MARK: - 滚动时切换歌曲
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        QYTools.shared.Log(log: #function)
        
        if let cell = collectionView.visibleCells.first as? MPPlayingViewCollectionViewCell {
            let tempIndex = collectionView.indexPath(for: cell)?.item ?? 0
            if tempIndex > currentIndex {
                if let d = self.delegate {
                    d.playingView(next: self, index: tempIndex)
                }
            }else {
                if let d = self.delegate {
                    d.playingView(pre: self, index: tempIndex)
                }
            }
            currentIndex = tempIndex
        }
    }
    // MARK: - 控制小窗播放View跟着滑动
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        QYTools.shared.Log(log: "X:    \(scrollView.contentOffset.x.truncatingRemainder(dividingBy: 375))")
        let x = scrollView.contentOffset.x.truncatingRemainder(dividingBy: 375)
        // 显示当前的播放View
        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
            if let width = pv.playView?.frame.width, width != SCREEN_WIDTH {
                pv.playView?.left = -x
            }
        }
    }
    
}
