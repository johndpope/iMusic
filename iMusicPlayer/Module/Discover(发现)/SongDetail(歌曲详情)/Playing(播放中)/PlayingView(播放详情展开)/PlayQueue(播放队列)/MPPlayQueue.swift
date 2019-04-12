//
//  MPPlayQueue.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/12.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPPlayQueue: NSObject {
    var url: URL? = nil
    var count: Int = 0
    
    init(url: URL?, count: Int) {
        self.url = url
        self.count = count
    }
}
