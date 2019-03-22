//
//  LyricsView.swift
//  SpotlightLyrics
//
//  Created by Scott Rong on 2017/4/2.
//  Copyright © 2017 Scott Rong. All rights reserved.
//

import UIKit


open class LyricsView: UITableView, UITableViewDataSource, UITableViewDelegate {
    // 滑动时播放View
    private var scrollPlayView: MPScrollPlayView?
    
    private var scrollToCell: UITableViewCell?
    
    private var parser: LyricsParser? = nil
    
    private var lyricsViewModels: [LyricsCellViewModel] = []
    
    private var lastIndex: Int? = nil
    
    private(set) public var timer: LyricsViewTimer = LyricsViewTimer()
    
    // MARK: Public properties
    
    public var currentLyric: String? {
        get {
            guard let lastIndex = lastIndex else {
                return nil
            }
            guard lastIndex < lyricsViewModels.count else {
                return nil
            }
            
            return lyricsViewModels[lastIndex].lyric
        }
    }
    
    public var defaultLyricsHeight: CGFloat = SCREEN_WIDTH * (352/375)
    
    public var lyrics: String? = nil {
        didSet {
            reloadViewModels()
        }
    }
    
    public var lyricFont: UIFont = .systemFont(ofSize: 16) {
        didSet {
            reloadViewModels()
        }
    }
    
    public var lyricHighlightedFont: UIFont = .systemFont(ofSize: 16) {
        didSet {
            reloadViewModels()
        }
    }
    
    public var lyricTextColor: UIColor = .black {
        didSet {
            reloadViewModels()
        }
    }
    
    public var lyricHighlightedTextColor: UIColor = .lightGray {
        didSet {
            reloadViewModels()
        }
    }
    
    public var lineSpacing: CGFloat = 16 {
        didSet {
            reloadViewModels()
        }
    }
    
    // MARK: Initializations
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        register(LyricsCell.self, forCellReuseIdentifier: "LyricsCell")
        separatorStyle = .none
        clipsToBounds = true
        
        dataSource = self
        delegate = self
        
        timer.lyricsView = self
    }
    
    /**
     * 添加滑动控制条
     */
    open func addScrollPlayView() {
        let pv = MPScrollPlayView.md_viewFromXIB() as! MPScrollPlayView
        pv.frame = CGRect(x: 0, y: defaultLyricsHeight/2, width: SCREEN_WIDTH, height: 64)
        pv.isHidden = true
        self.scrollPlayView = pv
        if let sv = self.superview {
            sv.addSubview(pv)
            sv.bringSubviewToFront(pv)
        }
        
        pv.md_btnDidClickedBlock = {(sender) in
            // 播放当前的进度
            if let cell = self.scrollToCell, let index = self.indexPath(for: cell)?.row {
                let lyricsModel = self.parser?.lyrics[index + 1]
                if let time = lyricsModel?.time {
                    pv.updateTime(model: "\(Int(time))".md_dateDistanceTimeWithBeforeTime(format: "mm:ss"))
                    self.timer.seek(toTime: time)
                }
            }
            
        }
    }
    
    open func removeScrollPlayView() {
        scrollPlayView?.removeFromSuperview()
    }
    
    // MARK: UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyricsViewModels.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = self.lyricsViewModels[indexPath.row]
        return lineSpacing + cellViewModel.calcHeight(containerWidth: self.bounds.width)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: "LyricsCell", for: indexPath) as! LyricsCell
        cell.update(with: lyricsViewModels[indexPath.row])
        tableView.separatorStyle = .none
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        scrollPlayView?.isHidden = false
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.scrollPlayView?.isHidden = true
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollPlayView?.isHidden = false
    }
    
//    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
//            self.scrollPlayView?.isHidden = true
//        }
//    }
//
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 获取当前的View的centerY所在的Cell, 滚动tableView到当前的Cell
        var centerCell = UITableViewCell()
        if visibleCells.count/2 >= 0 {  // 偶数
            centerCell = visibleCells[visibleCells.count/2 + 1]
        }else {
            centerCell = visibleCells[visibleCells.count/2]
        }
        
        if let indexPath = self.indexPath(for: centerCell) {
            self.scrollToRow(at: indexPath, at: .middle, animated: true)
            // 设置滑动到的Cell
            scrollToCell = centerCell
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.scrollPlayView?.isHidden = true
        }
    }
    
    
    
    // MARK:
    
    private func reloadViewModels() {
        lyricsViewModels.removeAll()
        
        guard let lyrics = self.lyrics?.emptyToNil() else {
            reloadData()
            return
        }
        
        parser = LyricsParser(lyrics: lyrics)
        
        for lyric in parser!.lyrics {
            let viewModel = LyricsCellViewModel.cellViewModel(lyric: lyric.text,
                                                              font: lyricFont,
                                                              highlightedFont: lyricHighlightedFont,
                                                              textColor: lyricTextColor,
                                                              highlightedTextColor: lyricHighlightedTextColor
            )
            lyricsViewModels.append(viewModel)
        }
        reloadData()
        contentInset = UIEdgeInsets(top: frame.height / 2, left: 0, bottom: frame.height / 2, right: 0)
    }
    
    // MARK: Controls
    
    internal func scroll(toTime time: TimeInterval, animated: Bool) {
        guard let lyrics = parser?.lyrics else {
            return
        }
        
        guard let index = lyrics.index(where: { $0.time >= time }) else {
            // when no lyric is before the time passed in means scrolling to the first
            if (lyricsViewModels.count > 0) {
                scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: animated)
            }
            return
        }
        
        guard lastIndex == nil || index - 1 != lastIndex else {
            return
        }
        
        if let lastIndex = lastIndex {
            lyricsViewModels[lastIndex].highlighted = false
        }
        
        if index > 0 {
            lyricsViewModels[index - 1].highlighted = true
            scrollToRow(at: IndexPath(row: index - 1, section: 0), at: .middle, animated: animated)
            lastIndex = index - 1
        }
    }
}
