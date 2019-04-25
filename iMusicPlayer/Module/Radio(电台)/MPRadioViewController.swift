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

private struct Constant {
    static let identifier = "MPRadioCollectionViewCell"
}

class MPRadioViewController: BaseViewController {
    
    var collectionView : UICollectionView!
    
    var currentIndex = 0 {
        didSet {
            self.play()
        }
    }
    
    var model = [MPSongModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        setupCollectionView()
        
        requestData()
    }
    
    private func setupCollectionView() {
        let layout = CDFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20.0
        // 将cell挤成一行
        layout.minimumInteritemSpacing = 100
        layout.sectionInset = UIEdgeInsets(top: 0, left: LAYOUT_LEFTORRIGHT_WIDTH, bottom: 0, right: LAYOUT_LEFTORRIGHT_WIDTH)
        layout.itemSize = CGSize(width: CELL_WIDTH, height: CELL_WIDTH + 80)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Constant.identifier, bundle: nil), forCellWithReuseIdentifier: Constant.identifier)
        view.addSubview(self.collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func requestData() {
        super.requestData()
        
        if MPModelTools.data_RadioModels.count == 0 {
            MPModelTools.getRadioModel(tableName: MPRadioViewController.classCode + "\(SourceType)") { (model) in
                if let m = model {
                    self.model = m
                }
            }
        }else {
            self.model = MPModelTools.data_RadioModels
        }
        
    }
    
    private func play() {
        
        let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as? MPRadioCollectionViewCell
        // 显示当前的播放View
        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingBigView {
//            pv.currentSong = model[currentIndex]
//            pv.model = model
            
            
            model[currentIndex].data_playingStatus = 1
            
            MPModelTools.saveCurrentPlayList(currentList: model)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotCenter.NC_PlayCurrentList), object: nil, userInfo: ["randomMode" : 0])
//            NotificationCenter.default.post(name: NSNotification.Name(NotCenter.NC_PlayCurrentList), object: nil)
            
            pv.smallStyle()
            
            cell?.playBtnShow = false
        }else {
            cell?.playBtnShow = true
        }
        
//        let vc = PlayerViewController()
//        vc.tracks = mappingToTracks()
//        vc.title = "Remote Music ♫"
//        self.navigationController?.pushViewController(vc, animated: true)
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
                self.currentIndex = indexPath.row
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
        
    }
    
}

extension MPRadioViewController {
    private func mappingToTracks() -> [Track] {
        var temps = [Track]()
        model.forEach { (item) in
            let tempM = Track()
            tempM.artist = item.data_singerName
            tempM.title = item.data_songName
            if let url = URL(string: item.data_cache ?? "") {
                tempM.audioFileURL = url
            }
            temps.append(tempM)
        }
        return temps
    }
}
