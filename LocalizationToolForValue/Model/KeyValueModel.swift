//
//  KeyValueModel.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/9.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Foundation

class KeyValueModel: Decodable {
    // 键
    var key: String = ""
    // 中文
    var chValue: String = ""
    // 英文
    var enValue: String = ""
    // 德文
    var geValue: String = ""
    // 日文
    var jpValue: String = ""
    
    var range: NSRange?
    var filePath: String?
    
    init(key: String, chValue: String, enValue: String, geValue: String, jpValue: String) {
        self.key = key
        self.chValue = chValue
        self.enValue = enValue
        self.geValue = geValue
        self.jpValue = jpValue
    }
    
}
