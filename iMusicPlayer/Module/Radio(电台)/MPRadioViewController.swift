//
//  MPRadioViewController.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/12.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPRadioViewController: BaseViewController {
    
    @IBOutlet weak var xib_title: UILabel!
    @IBOutlet weak var xib_user: UILabel!
    
    var scrollVC: CardViewController?
    
    var model = [MPSongModel]() {
        didSet {
            cardViews = getImageViews(models: model)
        }
    }
    
    var cardViews = [UIImageView]() {
        didSet {
            scrollVC?.cards = cardViews
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        configCardView()
        requestData()
    }
    
    override func requestData() {
        super.requestData()
        
        MPModelTools.getRadioModel(tableName: MPRadioViewController.classCode) { (model) in
            if let m = model {
                self.model = m
                self.configCardView()
            }
        }
        
    }
    
    @IBAction func play(_ sender: UIButton) {
        // 显示当前的播放View
        if let pv = (UIApplication.shared.delegate as? AppDelegate)?.playingView, let window = UIApplication.shared.delegate?.window! {
            pv.isHidden = false
            window.bringSubviewToFront(pv)
        }
        
    }
    
    private func getImageViews(models: [MPSongModel]) -> [UIImageView] {
        var temps = [UIImageView]()
        models.forEach { (model) in
            //设置图片
            if let img = model.data_artworkBigUrl, img != "" {
                let imgUrl = API.baseImageURL + img
                let iv = UIImageView()
                iv.kf.setImage(with: URL(string: imgUrl), placeholder: #imageLiteral(resourceName: "print_load"))
                temps.append(iv)
            }
        }
        return temps
    }
    
    private func configCardView() {
        //1. Create card views to be presented in the CardViewController:
//        let cardViews: [UIView] = [UIImageView(image: #imageLiteral(resourceName: "pic_album_default")), UIImageView(image: #imageLiteral(resourceName: "pic_album_default")), UIImageView(image: #imageLiteral(resourceName: "pic_album_default")), UIImageView(image: #imageLiteral(resourceName: "pic_album_default")), UIImageView(image: #imageLiteral(resourceName: "pic_album_default"))]
        
        //2. Create the cardViewController:
        let cardVc = CardViewControllerFactory.make(cards: cardViews)
        scrollVC = cardVc
//        let cardVc = CardViewController.init(nibName: "CardViewController", bundle: nil)
//        let cardVc = CardViewController()
//        cardVc.cards = cardViews
        
        //3. *Optional* Configure the card view controller:
        
        cardVc.delegate = self
        
        //The number of degrees to rotate the background cards
        cardVc.degreesToRotateCard = 45
        
        //The alpha of the background cards
        cardVc.backgroundCardAlpha = 0.65
        
        //The z translation factor applied to the cards during transition
        cardVc.cardZTranslationFactor = 1/3
        
        //If paging between the cards should be enabled
        cardVc.isPagingEnabled = true
        
        //The transition interpolation applied to the source and destination card during transition
        //The CardInterpolator contains some predefined functions, but feel free to provide your own.
        cardVc.sourceTransitionInterpolator = CardInterpolator.cubicOut
        cardVc.destinationTransitionInterpolator = CardInterpolator.cubicOut
        
        // 添加自控制器
        addChild(cardVc)
        cardVc.view.frame = self.view.frame
        view.addSubview(cardVc.view)
        cardVc.didMove(toParent: self)
        
        // 将歌曲名称和歌手移到最上层
        self.view.sendSubviewToBack(cardVc.view)
    }

}
extension MPRadioViewController: CardViewControllerDelegate {
    func cardViewController(_ cardViewController: CardViewController, didSelect card: UIView, at index: Int) {
        print("did select card at index: \(index)")
    }
    
    
}
