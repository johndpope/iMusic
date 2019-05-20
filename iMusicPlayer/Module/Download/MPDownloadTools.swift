//
//  MPDownloadTools.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/5/17.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPDownloadTools: NSObject {
    
//    + (void)downloadMusicWithSongId:(NSString *)songId {
//    NSString *api = [NSString stringWithFormat:@"baidu.ting.song.play&songid=%@", songId];
//
//    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
//    GKWYMusicModel *model = [GKWYMusicModel yy_modelWithDictionary:responseObject[@"songinfo"]];
//
//    NSDictionary *bitrate = responseObject[@"bitrate"];
//    model.file_link        = bitrate[@"file_link"];
//    model.file_duration    = bitrate[@"file_duration"];
//    model.file_bitrate     = bitrate[@"file_bitrate"];
//    model.file_size        = bitrate[@"file_size"];
//    model.file_extension   = bitrate[@"file_extension"];
//
//    GKDownloadModel *dModel = [GKDownloadModel new];
//    dModel.fileID           = model.song_id;
//    dModel.fileName         = model.song_name;
//    dModel.fileArtistId     = model.artist_id;
//    dModel.fileArtistName   = model.artist_name;
//    dModel.fileAlbumId      = model.album_id;
//    dModel.fileAlbumName    = model.album_title;
//    dModel.fileCover        = model.pic_radio;
//    dModel.fileUrl          = model.file_link;
//    dModel.fileDuration     = model.file_duration;
//    dModel.fileFormat       = model.file_extension;
//    dModel.fileRate         = model.file_bitrate;
//    dModel.fileSize         = model.file_size;
//    dModel.fileLyric        = model.lrclink;
//
//    [KDownloadManager addDownloadArr:@[dModel]];
//
//    [GKMessageTool showText:@"已加入到下载队列"];
//
//    } failureBlock:^(NSError *error) {
//    NSLog(@"获取详情失败==%@", error);
//    [GKMessageTool showError:@"加入下载失败"];
//    }];
//    }
    
    class func downloadMusicWithSongId(model: MPSongModel) {
        
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
        QYTools.shared.Log(log: "已经加入下载队列")
    }
}
