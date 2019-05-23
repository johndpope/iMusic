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
//        dModel.fileFormat          = model.file_extension;
//        dModel.fileRate             = model.file_bitrate;
//        dModel.fileSize             = model.file_size;
//        dModel.fileLyric            = model.data_lyrics;
        
        GKDownloadManager.sharedInstance()?.addDownloadArr([dModel])
        QYTools.shared.Log(log: "已经加入下载队列".decryptLog())
    }
}
