//
//  MPTimeOffModel.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/18.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

class MPTimeOffModel: NSObject {
    static let titleDatas = [NSLocalizedString("不开启", comment: ""), NSLocalizedString("15分钟后", comment: ""), NSLocalizedString("30分钟后", comment: ""), NSLocalizedString("45分钟后", comment: ""), NSLocalizedString("60分钟后", comment: ""), NSLocalizedString("自定义", comment: "")]
    static let selecteds = [false, false,false,false,false,false]
    func models() -> [String: Any] {
        let datas = ["titles": MPTimeOffModel.titleDatas,  "selected": MPTimeOffModel.selecteds] as [String : Any]
        return datas
    }
}
