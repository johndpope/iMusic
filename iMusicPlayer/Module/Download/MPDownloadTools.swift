//
//  MPDownloadTools.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/5/17.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class MPDownloadTools: NSObject {
    
    class func downloadMusicWithSongId(model: MPSongModel) {
        
        Analytics.logEvent("download_start", parameters: nil)
        
        let dModel = GKDownloadModel()
        dModel.fileID           = model.data_songId;
        dModel.fileName         = model.data_songName;
//        dModel.fileArtistId     = model.data_id;
        dModel.fileArtistName   = model.data_singerName;
//        dModel.fileAlbumId      = model.album_id;
//        dModel.fileAlbumName    = model.album_title;
        dModel.fileCover             = model.data_artworkBigUrl;
        dModel.fileUrl               = model.data_cache;
        dModel.fileDuration     = "\(model.data_durationInSeconds)";
        dModel.fileFormat          = "mp3";
//        dModel.fileRate             = "128";
//        dModel.fileSize             = "5423173";
        
        GKDownloadManager.sharedInstance()?.addDownloadArr([dModel])
        QYTools.shared.Log(log: "已经加入下载队列".decryptLog())
    }
    
    /// 检查文件是否存在
    ///
    /// - Parameter model: 歌曲模型
    /// - Returns: 是否存在
    class func checkCacheSongExist(model: MPSongModel) -> Bool {
        let fm = FileManager.default
//        let exist = fm.fileExists(atPath: path)
        let tempPath: NSString = NSTemporaryDirectory() as NSString
        let path = tempPath.appendingPathComponent(model.data_cachePath.components(separatedBy: "/").last ?? "")
        // TODO: 判断文件是否存在
        var isSave = fm.fileExists(atPath: path)
        print(isSave)
//        var directory: ObjCBool = ObjCBool(true)
//        isSave = fm.fileExists(atPath: path, isDirectory: &directory)
//        print(isSave)
        
        return isSave
    }
}
