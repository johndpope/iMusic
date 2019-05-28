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
    
    static let sharedStorage = DiskStorage(config: DiskConfig(name: "cache"), path: "cacheList", transformer: TransformerFactory.forData())
    static let ss = try! Storage(
            diskConfig: DiskConfig(name: "CacheModels"),
            memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
            transformer: TransformerFactory.forData()
    )

    class func addCache(model: MPSongModel) {
        do {
            try sharedStorage.removeAll()
            if let data = NSData(contentsOfFile: model.data_cachePath) as Data? {
                try sharedStorage.setObject(data, forKey: model.data_cachePath.md5())
            }
//            try ss.setObject(NSData(contentsOfFile: model.data_cachePath) as Data, forKey: "data")
        }catch {
            print(error)
        }
    }
    
    class func cachePath(key: String) -> String {
        return sharedStorage.path
    }
    
}
