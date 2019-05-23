//
//  MPStyleGenreViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPStyleGenreCollectionViewCell"
    static let sectionIdentifier = "MPStyleGenreCollectionReusableView"
}

class MPStyleGenreViewController: BaseCollectionViewController {
    
    var model: MPStyleGenreModel? {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshData()
    }
    
    override func refreshData() {
        super.refreshData()
        
        MPModelTools.getStyleGenreModel(tableName: MPStyleGenreModel.classCode) { (model) in
            if let m = model {
                self.model = m
            }
        }
        
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        addLeftItem(title: NSLocalizedString("风格及流派", comment: "").decryptString(), imageName: "icon_nav_back", fontColor: Color.FontColor_333, fontSize: 18, margin: 16)
    }
    
    override func clickLeft() {
        super.clickLeft()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
        self.identifier = Constant.identifier
        collectionView.register(UINib(nibName: Constant.sectionIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: Constant.sectionIdentifier)
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }

}
extension MPStyleGenreViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var number = 0
        switch section {
        case 0:
            number = model?.data_recommended?.count ?? 0
            break
        case 1:
            number = model?.data_style?.count ?? 0
            break
        case 2:
            number = model?.data_theme?.count ?? 0
            break
        default:
            break
        }
        return number
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.identifier, for: indexPath) as! MPStyleGenreCollectionViewCell
        var cellModel: Genre?
        switch indexPath.section {
        case 0:
            cellModel = model?.data_recommended?[indexPath.row]
            break
        case 1:
            cellModel = model?.data_style?[indexPath.row]
            break
        case 2:
            cellModel = model?.data_theme?[indexPath.row]
            break
        default:
            break
        }
        if let cm = cellModel {
            cell.updateCell(model: cm)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var sv = UICollectionReusableView()
        if kind == UICollectionView.elementKindSectionHeader {
            sv = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constant.sectionIdentifier, for: indexPath)
            (sv as! MPStyleGenreCollectionReusableView).updateView(model: MPStyleGenreModel.sectionTitleDatas[indexPath.section])
            
        }
        return sv
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (SCREEN_WIDTH-12*4)/3
        let height = width + 8*2 + 20
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: SCREEN_WIDTH, height: 44)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MPChoicenessViewController()
        
        var cellModel: Genre?
        switch indexPath.section {
        case 0:
            cellModel = model?.data_recommended?[indexPath.row]
            break
        case 1:
            cellModel = model?.data_style?[indexPath.row]
            break
        case 2:
            cellModel = model?.data_theme?[indexPath.row]
            break
        default:
            break
        }
        if let cm = cellModel {
            vc.typeID = cm.data_id
            vc.leftTitle = cm.data_title ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
