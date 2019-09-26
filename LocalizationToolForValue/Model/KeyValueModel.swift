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
    
    var range: NSRange?
    var filePath: String?
    
    init(key: String, chValue: String) {
        self.key = key
        self.chValue = chValue
    }
    
}
