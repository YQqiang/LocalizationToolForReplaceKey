//
//  EnumeratorFileProtocol.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/9.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Foundation

protocol EnumeratorFileProtocol {
    var filePath: String { get set }
}

extension EnumeratorFileProtocol {
    /// 是否是文件夹
    func isFolder() -> Bool {
        var folder: ObjCBool = false
        FileManager.default.fileExists(atPath: filePath, isDirectory: &folder)
        return folder.boolValue
    }
    
    /// 文件名称
    func fileName() -> String {
        return (filePath as NSString?)?.lastPathComponent ?? ""
    }
    
    /// 不带扩展名的文件名称
    func fileNameWithoutExtension() -> String {
        return (fileName() as NSString?)?.deletingPathExtension ?? ""
    }
    
    /// 文件扩展名
    func fileExtension() -> String {
        return (filePath as NSString?)?.pathExtension ?? ""
    }
}

extension EnumeratorFileProtocol {
    /// 获取到当前文件目录下的每一个文件
    ///
    /// - Parameter forEach: 回调闭包
    func enumeratorFile(_ forEach: ((String) -> Void)?) {
        if !isFolder() {
            if let closure = forEach {
                closure(filePath)
            }
            return;
        }
        let fileManager = FileManager.default
        let homePath = (filePath as NSString).expandingTildeInPath
        let directoryEnumerator = fileManager.enumerator(atPath: homePath)
        var fileName: String? = (directoryEnumerator?.nextObject() as! String?)
        while (fileName != nil) {
            if let closure = forEach {
                closure(homePath + "/" + fileName!)
            }
            fileName = (directoryEnumerator?.nextObject() as! String?)
        }
    }
}
