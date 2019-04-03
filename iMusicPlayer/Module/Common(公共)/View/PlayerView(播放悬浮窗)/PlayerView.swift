//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

protocol PlayerVCDelegate {
    func didMinimize()
    func didmaximize()
    func swipeToMinimize(translation: CGFloat, toState: stateOfVC)
    func didEndedSwipe(toState: stateOfVC)
}

import UIKit
import AVFoundation
class PlayerView: UIView {
    
    //MARK: Properties
    @IBOutlet weak var minimizeButton: UIButton!
    @IBOutlet weak var player: UIView! {
        didSet {
            player.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.minimizeGesture(_:))))
        }
    }
    var video: Video!
    var delegate: PlayerVCDelegate?
    var state = stateOfVC.hidden
    var direction = Direction.none
    var videoPlayer = AVPlayer()
    
    //MARK: Methods
    func customization() {
        self.backgroundColor = UIColor.clear
        self.player.layer.anchorPoint.applying(CGAffineTransform.init(translationX: -0.5, y: -0.5))
        self.player.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.tapPlayView)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.tapPlayView), name: NSNotification.Name("open"), object: nil)
    }
    
    func animate()  {
        switch self.state {
        case .fullScreen:
            UIView.animate(withDuration: 0.3, animations: {
                self.minimizeButton.alpha = 1
                self.player.transform = CGAffineTransform.identity
                UIApplication.shared.isStatusBarHidden = true
            })
        case .minimized:
            UIView.animate(withDuration: 0.3, animations: {
                UIApplication.shared.isStatusBarHidden = false
                self.minimizeButton.alpha = 0
                let scale = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                let trasform = scale.concatenating(CGAffineTransform.init(translationX: -self.player.bounds.width/4, y: -self.player.bounds.height/4))
                self.player.transform = trasform
            })
        default: break
        }
    }
    
    func changeValues(scaleFactor: CGFloat) {
        self.minimizeButton.alpha = 1 - scaleFactor
        let scale = CGAffineTransform.init(scaleX: (1 - 0.5 * scaleFactor), y: (1 - 0.5 * scaleFactor))
        let trasform = scale.concatenating(CGAffineTransform.init(translationX: -(self.player.bounds.width / 4 * scaleFactor), y: -(self.player.bounds.height / 4 * scaleFactor)))
        self.player.transform = trasform
    }
    
    @objc func tapPlayView()  {
        self.videoPlayer.play()
        self.state = .fullScreen
        self.delegate?.didmaximize()
        self.animate()
    }
    
    @IBAction func minimize(_ sender: UIButton) {
        self.state = .minimized
        self.delegate?.didMinimize()
        self.animate()
    }
    
    @objc func minimizeGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            let velocity = sender.velocity(in: nil)
            if abs(velocity.x) < abs(velocity.y) {
                self.direction = .up
            } else {
                self.direction = .left
            }
        }
        var finalState = stateOfVC.fullScreen
        switch self.state {
        case .fullScreen:
            let factor = (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
            self.changeValues(scaleFactor: factor)
            self.delegate?.swipeToMinimize(translation: factor, toState: .minimized)
            finalState = .minimized
        case .minimized:
            if self.direction == .left {
                finalState = .hidden
                let factor: CGFloat = sender.translation(in: nil).x
                self.delegate?.swipeToMinimize(translation: factor, toState: .hidden)
            } else {
                finalState = .fullScreen
                let factor = 1 - (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
                self.changeValues(scaleFactor: factor)
                self.delegate?.swipeToMinimize(translation: factor, toState: .fullScreen)
            }
        default: break
        }
        if sender.state == .ended {
            self.state = finalState
            self.animate()
            self.delegate?.didEndedSwipe(toState: self.state)
            if self.state == .hidden {
                self.videoPlayer.pause()
            }
        }
    }
    
    //MARK: View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.customization()
//        Video.fetchVideo { [weak self] downloadedVideo in
//            guard let weakSelf = self else {
//                return
//            }
//            weakSelf.video = downloadedVideo
//            weakSelf.videoPlayer = AVPlayer.init(url: weakSelf.video.videoLink)
//            let playerLayer = AVPlayerLayer.init(player: weakSelf.videoPlayer)
//            playerLayer.frame = weakSelf.player.frame
//            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//            weakSelf.player.layer.addSublayer(playerLayer)
//
//            if weakSelf.state != .hidden {
//                weakSelf.videoPlayer.play()
//            }
//        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 代码方式创建可以在这里添加自定义控件
        
        self.customization()
//        Video.fetchVideo { [weak self] downloadedVideo in
//            guard let weakSelf = self else {
//                return
//            }
//            weakSelf.video = downloadedVideo
//            weakSelf.videoPlayer = AVPlayer.init(url: weakSelf.video.videoLink)
//            let playerLayer = AVPlayerLayer.init(player: weakSelf.videoPlayer)
//            playerLayer.frame = weakSelf.player.frame
//            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//
//            weakSelf.player.layer.addSublayer(playerLayer)
//            if weakSelf.state != .hidden {
//                weakSelf.videoPlayer.play()
//            }
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
