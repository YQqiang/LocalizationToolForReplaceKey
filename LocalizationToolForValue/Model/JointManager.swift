//
//  JointManager.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/9.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Foundation

enum LanguageType: String {
    case ch = "chValue"
    case en = "enValue"
    case ge = "geValue"
    case jp = "jpValue"
}

final class JointManager {
    static let shared = JointManager.init()
    private init(){}
    
    private let defaultHomePath = NSHomeDirectory() + "/Desktop"
    private let defaultOutFolderName = "LocalizationToolForReplaceKey"
    
    lazy var homePath: String = defaultHomePath
    
    lazy var outFolderName: String = defaultOutFolderName
    
    var outPath: String {
        let path = homePath + "/" + outFolderName
        return path
    }
    
    func Joint(_ keyValueModels: [KeyValueModel]) {
        var chContent = ""
        keyValueModels.forEach { (keyValueModel) in
            chContent = chContent + "\"" + keyValueModel.key + "\" = \"" + keyValueModel.chValue + "\";" + "\n"
        }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: outPath) {
            try! fileManager.createDirectory(atPath: outPath, withIntermediateDirectories: true, attributes: nil)
        }

        try? chContent.write(toFile: "\(outPath)/ch.Strings", atomically: true, encoding: String.Encoding.utf8)
    }
    
    func Joint(_ fileName: String, content: String) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: outPath) {
            try! fileManager.createDirectory(atPath: outPath, withIntermediateDirectories: true, attributes: nil)
        }
        try? content.write(toFile: "\(outPath)/\(fileName).Strings", atomically: true, encoding: String.Encoding.utf8)
    }
    
    /// 恢复默认的输出路径
    func restoreDefaultPath() {
        homePath = defaultHomePath
        outFolderName = defaultOutFolderName
    }
}
