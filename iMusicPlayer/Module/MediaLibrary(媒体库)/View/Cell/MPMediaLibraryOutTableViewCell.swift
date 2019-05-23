//
//  MPMediaLibraryOutTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPMediaLibraryCollectionViewCell"
}

class MPMediaLibraryOutTableViewCell: UITableViewCell {
    
    var model = [MPSongModel]() {
        didSet {
            offestModel = getModelsByOffest(model: model)
        }
    }
    
    var offestModel = [[MPSongModel]]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var itemClickedBlock: ((_ index: Int)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.dataSource = self
        collectionView.delegate  = self
        collectionView.register(UINib(nibName: Constant.identifier, bundle: nil), forCellWithReuseIdentifier: Constant.identifier)
        collectionView.showsHorizontalScrollIndicator = false
//        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = .horizontal
    }
    
}

extension MPMediaLibraryOutTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offestModel.count > 5 ? 5 : offestModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.identifier, for: indexPath) as! MPMediaLibraryCollectionViewCell
        cell.model = offestModel[indexPath.row]
        cell.tempModel = self.model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width =  SCREEN_WIDTH - 50
        let height = SCREEN_WIDTH * (172/375)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let b = itemClickedBlock {
            b(indexPath.row)
        }
    }
}
extension MPMediaLibraryOutTableViewCell {
    
    /// 获取分割的数据源
    ///
    /// - Parameter model: 数据源
    /// - Returns: 分割后的数据源
    private func getModelsByOffest(model: [MPSongModel]) -> [[MPSongModel]] {
        var temp = [[MPSongModel]]()
        let total = model.count/3
        for i in 0...total {
            if i*3 + 3 < model.count {
                temp.append((model as NSArray).subarray(with: NSRange(location: i*3, length: 3)) as! [MPSongModel])
            }else {
                temp.append((model as NSArray).subarray(with: NSRange(location: i*3, length: model.count -  i*3)) as! [MPSongModel])
            }
        }
        return temp
    }
}
