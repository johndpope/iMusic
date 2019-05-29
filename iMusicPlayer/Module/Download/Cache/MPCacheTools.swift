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
    
//    static let sharedStorage = DiskStorage(config: DiskConfig(name: "cache"), path: "cacheList", transformer: TransformerFactory.forData())
    
    static let diskConfig = DiskConfig(name: "iMusicPlayer.CacheMusic")
    static let memoryConfig = MemoryConfig(expiry: .never, countLimit: 3, totalCostLimit: 0)
    
    static let sharedStorage = try! Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forData()
    )
//    static let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).last ?? ""
//
//    static let sharedStorage = try! DiskStorage(config: diskConfig, path: cachePath + "/iMusicPlayer.CacheMusic.new", transformer: TransformerFactory.forData())
    
    class func cachePath(path: String) -> String {
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).last
        return ((cachePath! as NSString).appendingPathComponent(diskConfig.name) as NSString).appendingPathComponent(path.md5().md5().uppercased())
    }
    
    class func cacheMusic(path: String) {
        do {
            // 1.判断是否存在该音乐
            let exist = try sharedStorage.existsObject(forKey: path.md5())
            // 2.
            if !exist {
                try sharedStorage.setObject(NSData(contentsOfFile: path) as Data, forKey: path.md5())
            }
        }catch {
            QYTools.shared.Log(log: error.localizedDescription)
        }
    }
    
}
