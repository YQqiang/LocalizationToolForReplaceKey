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
    private let defaultOutFolderName = "LocalizationToolForValue"
    
    lazy var homePath: String = defaultHomePath
    
    lazy var outFolderName: String = defaultOutFolderName
    
    var outPath: String {
        let path = homePath + "/" + outFolderName
        return path
    }
    
    func Joint(_ keyValueModels: [KeyValueModel]) {
        var chContent = ""
        var enContent = ""
        var geContent = ""
        var jpContent = ""
        keyValueModels.forEach { (keyValueModel) in
            chContent = chContent + "\"" + keyValueModel.key + "\" = \"" + keyValueModel.chValue + "\";" + "\n"
            enContent = enContent + "\"" + keyValueModel.key + "\" = \"" + keyValueModel.enValue + "\";" + "\n"
            geContent = geContent + "\"" + keyValueModel.key + "\" = \"" + keyValueModel.geValue + "\";" + "\n"
            jpContent = jpContent + "\"" + keyValueModel.key + "\" = \"" + keyValueModel.jpValue + "\";" + "\n"
        }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: outPath) {
            try! fileManager.createDirectory(atPath: outPath, withIntermediateDirectories: true, attributes: nil)
        }

        try? chContent.write(toFile: "\(outPath)/ch.Strings", atomically: true, encoding: String.Encoding.utf8)
        try? enContent.write(toFile: "\(outPath)/en.Strings", atomically: true, encoding: String.Encoding.utf8)
        try? geContent.write(toFile: "\(outPath)/ge.Strings", atomically: true, encoding: String.Encoding.utf8)
        try? jpContent.write(toFile: "\(outPath)/jp.Strings", atomically: true, encoding: String.Encoding.utf8)
    }
    
    /// 恢复默认的输出路径
    func restoreDefaultPath() {
        homePath = defaultHomePath
        outFolderName = defaultOutFolderName
    }
}
