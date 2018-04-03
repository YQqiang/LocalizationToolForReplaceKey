//
//  YQFileModel.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/7.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Cocoa

struct YQFileModel: EnumeratorFileProtocol {
    var filePath: String
    
    var isFolder: Bool {
        return isFolder()
    }
    
    var fileName: String {
        return fileName()
    }
    
    var fileNameWithoutExtension: String {
        return fileNameWithoutExtension()
    }
    
    var fileExtension: String {
        return fileExtension()
    }
}
