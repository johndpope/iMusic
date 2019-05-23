//
//  MPTimeOffModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPTimeOffModel: NSObject {
    static let titleDatas = [NSLocalizedString("关闭", comment: "").decryptString(), "15" + NSLocalizedString("分钟后", comment: "").decryptString(), "30" + NSLocalizedString("分钟后", comment: "").decryptString(), "45" + NSLocalizedString("分钟后", comment: "").decryptString(), "60" + NSLocalizedString("分钟后", comment: "").decryptString(), NSLocalizedString("自定义", comment: "").decryptString()]
    static let selecteds = [false, false,false,false,false,false]
    func models() -> [String: Any] {
        let datas = ["titles": MPTimeOffModel.titleDatas,  "selected": MPTimeOffModel.selecteds] as [String : Any]
        return datas
    }
}
