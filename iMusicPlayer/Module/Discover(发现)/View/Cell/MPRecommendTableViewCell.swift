//
//  MPRecommendTableViewCell.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPRecommendCollectionViewCell"
}

class MPRecommendTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var itemClickedBlock: ((_ index: Int)->Void)? = nil
    
    var models = [MPSongModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.dataSource = self
        collectionView.delegate  = self
        collectionView.register(UINib(nibName: Constant.identifier, bundle: nil), forCellWithReuseIdentifier: Constant.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
}

extension MPRecommendTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.identifier, for: indexPath) as! MPRecommendCollectionViewCell
        cell.updateCell(model: models[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width =  SCREEN_HEIGHT * (252/667)
        let height = SCREEN_WIDTH * (260/375)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let b = itemClickedBlock {
            b(indexPath.row)
        }
    }
    
}
