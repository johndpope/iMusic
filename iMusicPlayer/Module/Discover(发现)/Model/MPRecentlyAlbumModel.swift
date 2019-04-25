//
//  MPRecentlyAlbumModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/4/24.
//  Copyright © 2019年 Modi. All rights reserved.
//

import UIKit

/// 最近播放类型：1：最近播放单曲 2：最新歌曲列表 3：我的最爱  4：歌手  5：专辑 6: 排行榜 7: Top 100  8：创建的歌单
class MPRecentlyAlbumModel: BaseModel {
    
//    var data_singleSong: [GeneralPlaylists]?
    var data_latest: [GeneralPlaylists]?
    var data_favorite: [GeneralPlaylists]?
    var data_songer: [GeneralPlaylists]?
    var data_album: [GeneralPlaylists]?
    var data_ranking: [GeneralPlaylists]?
    var data_top100: [GeneralPlaylists]?
    var data_myList: [GeneralPlaylists]?
    
}
