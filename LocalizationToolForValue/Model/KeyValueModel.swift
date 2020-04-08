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
    // 值
    var value: String = ""
    
    var range: NSRange?
    var filePath: String?
    
    var androidString: String {
        var resultValue = value
        resultValue = resultValue.replacingOccurrences(of: "<", with: "&lt;")
        resultValue = resultValue.replacingOccurrences(of: ">", with: "&gt;")
        return "<string name=\"" + key + "\">" + resultValue + "</string>"
    }
    
    var iOSString: String {
        return ""
    }
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
}
