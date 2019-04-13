//
//  ViewController.swift
//  Card_hjw
//
//  Created by hejianwu on 16/10/26.
//  Copyright © 2016年 ShopNC. All rights reserved.
//

import UIKit

//屏幕的高
let APP_FRAME_HEIGHT : CGFloat! = UIScreen.main.bounds.height
//屏幕的宽
let APP_FRAME_WIDTH : CGFloat = UIScreen.main.bounds.width
//layout上下距离
let LAYOUT_LEFTORRIGHT_WIDTH : CGFloat = (APP_FRAME_WIDTH-40)/5 + 20
let CELL_WIDTH : CGFloat = (APP_FRAME_WIDTH-40)*3/5
let CELL_HEIGHT : CGFloat = APP_FRAME_HEIGHT*3/7

var desLabel : UILabel!

private struct Constant {
    static let identifier = "MPRadioCollectionViewCell"
}

class MPRadioViewController: BaseViewController {
    
    var data = [String]()
    var collectionView : UICollectionView!
    
    var currentIndex = 0
    
    var model = [MPSongModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        data = ["test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg","test.jpg"]
        
        let str = "我的足迹（1 / \(data.count)）"
        desLabel = UILabel(frame: CGRect(x: 0, y: 25, width: APP_FRAME_WIDTH, height: 14))
        desLabel.textAlignment = .center
        desLabel.font = UIFont.systemFont(ofSize: 14)
        let attributeString = NSMutableAttributedString(string: str)
        attributeString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 10),
                                     range: NSMakeRange(4, attributeString.length-4))
        attributeString.addAttributes([NSAttributedString.Key.baselineOffset : 0.36*(14-10)], range: NSMakeRange(4, attributeString.length-4))
        desLabel.attributedText = attributeString
//        self.view.addSubview(desLabel)
        
        setupCollectionView()
        
        requestData()
    }
    
    private func setupCollectionView() {
        let layout = CDFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: LAYOUT_LEFTORRIGHT_WIDTH, bottom: 0, right: LAYOUT_LEFTORRIGHT_WIDTH)
        layout.itemSize = CGSize(width: CELL_WIDTH, height: CELL_HEIGHT)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        //        collectionView.register(CDViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(CDViewCell.self))
        collectionView.register(UINib(nibName: Constant.identifier, bundle: nil), forCellWithReuseIdentifier: Constant.identifier)
        collectionView.reloadData()
        view.addSubview(self.collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func requestData() {
        super.requestData()
        DispatchQueue.main.async {
            MPModelTools.getRadioModel(tableName: MPRadioViewController.classCode) { (model) in
                if let m = model {
                    self.model = m
                }
            }
        }
    }
    
    private func play() {
        // 显示当前的播放View
        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
            pv.currentSong = model[currentIndex]
            pv.model = model
            pv.top = SCREEN_HEIGHT - TabBarHeight - 48
//            sender.isHidden = true
            // 隐藏状态栏
            
        }
    }

}

extension MPRadioViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    //UICollectionView代理方法
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: Constant.identifier, for: indexPath) as! MPRadioCollectionViewCell
        let row = indexPath.row
        cell.updateCell(model: model[row])
        
        cell.playBtnShow = row == 0 ? true : false
        
        cell.clickBlock = {(sender) in
            if let btn = sender as? UIButton {
                self.play()
                cell.playBtnShow = false
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("点击图片\(indexPath.row)")
        currentIndex = indexPath.row
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //center是collectionView的frame的中心点 pInView是中心点对应到collectionVIew的contentView的坐标
        let pInView = self.view.convert(self.collectionView.center, to: self.collectionView)
        let indexPathNow = self.collectionView.indexPathForItem(at: pInView)!
        let rowNum = indexPathNow.row + 1
        
        currentIndex = indexPathNow.row
        
        let str = "我的足迹（\(rowNum) / \(data.count)）"
        let attributeString = NSMutableAttributedString(string: str)
        attributeString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 10),
                                     range: NSMakeRange(4, attributeString.length-4))
        attributeString.addAttributes([NSAttributedString.Key.baselineOffset : 0.36*(14-10)], range: NSMakeRange(4, attributeString.length-4))
        desLabel.attributedText = attributeString
    }
    
}

