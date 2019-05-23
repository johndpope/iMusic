//
//  MPMediaLibraryModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/13.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPMediaLibraryModel: NSObject {
    static let categoryDatas = SourceType == 1 ? [NSLocalizedString("我的音乐收藏", comment: "").decryptString(), NSLocalizedString("我的下载", comment: "").decryptString(), NSLocalizedString("可离线播放", comment: "").decryptString(), NSLocalizedString("我的歌单", comment: "").decryptString(), NSLocalizedString("我的歌单收藏", comment: "").decryptString()] : [NSLocalizedString("我的音乐收藏", comment: "").decryptString(), NSLocalizedString("我的歌单", comment: "").decryptString(), NSLocalizedString("我的歌单收藏", comment: "").decryptString()]
}
