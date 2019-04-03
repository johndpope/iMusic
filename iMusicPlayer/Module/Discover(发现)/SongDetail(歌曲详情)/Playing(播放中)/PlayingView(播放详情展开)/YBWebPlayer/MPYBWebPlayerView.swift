//
//  MPYBWebPlayerView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/3.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

class MPYBWebPlayerView: BaseView {
    
    @IBOutlet weak var xib_webBgView: WKWebView! {
        didSet {
            xib_webView = WKWebView()
            xib_webBgView.addSubview(xib_webView)
            xib_webView.snp.makeConstraints { (make) in
                make.edges.equalTo(xib_webBgView)
            }
        }
    }
    var xib_webView: WKWebView!
    
    var url: String = API.baseURL
    
    var text: String = API.baseURL
    
    var id: String = "" {
        didSet {
            self.playById(id: id)
            self.play()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.htmlAction()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.htmlAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func htmlAction() {
        //        xib_webView.loadHTMLString(url, baseURL: nil)
        if url != API.baseURL, url.contains("http") {
            if let reUrl = URL(string: self.url) {
                let urlReq = URLRequest(url: reUrl)
                xib_webView.load(urlReq)
            }
        }else {
            xib_webView.loadHTMLString(self.text, baseURL: nil)
        }
        xib_webView.navigationDelegate = self
    }
    
}
extension MPYBWebPlayerView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        SVProgressHUD.dismiss()
    }
}
extension MPYBWebPlayerView {
    func playById(id: String) {
        let js = "javascript:loadVideoById(" + id + ")"
        xib_webView.evaluateJavaScript(js) { (rs, error) in
            QYTools.shared.Log(log: rs.debugDescription)
            QYTools.shared.Log(log: error.debugDescription)
        }
    }
    
    func play() {
        let js = "javascript:playVideo()"
        xib_webView.evaluateJavaScript(js) { (rs, error) in
            QYTools.shared.Log(log: rs.debugDescription)
            QYTools.shared.Log(log: error.debugDescription)
        }
    }
}
