//
//  JointManager.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/9.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Foundation

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
    
    func JointForIOS(_ keyValueModels: [KeyValueModel]) {
        var chContent = ""
        keyValueModels.forEach { (keyValueModel) in
            chContent = chContent + "\"" + keyValueModel.key + "\" = \"" + keyValueModel.value + "\";" + "\n"
        }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: outPath) {
            try! fileManager.createDirectory(atPath: outPath, withIntermediateDirectories: true, attributes: nil)
        }

        try? chContent.write(toFile: "\(outPath)/ch.Strings", atomically: true, encoding: String.Encoding.utf8)
    }
    
    func JointForWeb(_ keyValueModels: [KeyValueModel], fileName: String) {
        var chContent = ""
        keyValueModels.forEach { (keyValueModel) in
            chContent = chContent + keyValueModel.key + "=" + keyValueModel.value + "\n"
        }
        let finalPath = outPath + "/web"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: finalPath) {
            try! fileManager.createDirectory(atPath: finalPath, withIntermediateDirectories: true, attributes: nil)
        }
        try? chContent.write(toFile: "\(finalPath)/\(fileName).properties", atomically: true, encoding: String.Encoding.utf8)
    }
    
    func JointForAndroid(_ keyValueModels: [KeyValueModel]) {
        var chContent = ""
        keyValueModels.forEach { (keyValueModel) in
            //<string name="I18N_INSIGHT_MESSAGE_DELETE_SURE">Are you sure to delete?</string>
            var value = keyValueModel.value
            value = value.replacingOccurrences(of: "<", with: "&lt;")
            value = value.replacingOccurrences(of: ">", with: "&gt;")
            keyValueModel.value = value
            chContent = chContent + "<string name=\"" + keyValueModel.key + "\">" + keyValueModel.value + "</string>" + "\n"
        }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: outPath) {
            try! fileManager.createDirectory(atPath: outPath, withIntermediateDirectories: true, attributes: nil)
        }

        try? chContent.write(toFile: "\(outPath)/android.xml", atomically: true, encoding: String.Encoding.utf8)
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
