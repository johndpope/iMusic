//
//  MPCacheTools.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/5/27.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import Cache



class MPCacheTools: NSObject {
    
    static let sharedStorage = DiskStorage(config: DiskConfig(name: "cache"), path: "songcache", transformer: TransformerFactory.forData())

    class func addCache(model: MPSongModel) {
        do {
            try sharedStorage.setObject(NSData(contentsOfFile: model.data_cachePath) as Data, forKey: model.data_cachePath.md5())
        }catch {
            print(error)
        }
    }
    
    class func cachePath(key: String) -> String {
        return sharedStorage.path
    }
    
}
