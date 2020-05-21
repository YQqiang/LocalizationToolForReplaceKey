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
    
    func JointCommon(keyValueModels: [KeyValueModel], fileExtension: String) {
        if ["c", "xml"].contains(fileExtension.lowercased()) {
            JointForXML(keyValueModels)
            JointForWeb(keyValueModels, fileName: "webserver")
        } else if ["properties"].contains(fileExtension.lowercased()) {
            JointForWeb(keyValueModels, fileName: "localization")
        }
        JointKey(keyValueModels: keyValueModels)
    }
    
    func JointKey(keyValueModels: [KeyValueModel]) {
        let content = keyValueModels.map { $0.key }.joined(separator: "\n")
        let finalPath = outPath + "/web"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: finalPath) {
            try! fileManager.createDirectory(atPath: finalPath, withIntermediateDirectories: true, attributes: nil)
        }
        try? content.write(toFile: "\(finalPath)/\("key").txt", atomically: true, encoding: String.Encoding.utf8)
    }
    
    func JointForIOS(_ keyValueModels: [KeyValueModel]) {
        let chContent = keyValueModels.map({$0.iOSString}).joined(separator: "\n")
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: outPath) {
            try! fileManager.createDirectory(atPath: outPath, withIntermediateDirectories: true, attributes: nil)
        }
        try? chContent.write(toFile: "\(outPath)/ch.Strings", atomically: true, encoding: String.Encoding.utf8)
    }
    
    func JointForWeb(_ keyValueModels: [KeyValueModel], fileName: String) {
        let chContent = keyValueModels.map({$0.webString}).joined(separator: "\n")
        let finalPath = outPath + "/web"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: finalPath) {
            try! fileManager.createDirectory(atPath: finalPath, withIntermediateDirectories: true, attributes: nil)
        }
        try? chContent.write(toFile: "\(finalPath)/\(fileName).properties", atomically: true, encoding: String.Encoding.utf8)
    }
    
    func JointForXML(_ keyValueModels: [KeyValueModel]) {
        let chContent = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<root>\n" + keyValueModels.map({$0.xmlString}).joined(separator: "\n") + "\n</root>"
        
        let finalPath = outPath + "/web"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: finalPath) {
            try! fileManager.createDirectory(atPath: finalPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        try? chContent.write(toFile: "\(finalPath)/webserver.xml", atomically: true, encoding: String.Encoding.utf8)
    }
    
    func JointForAndroid(_ keyValueModels: [KeyValueModel]) {
        let chContent = keyValueModels.map({$0.androidString}).joined(separator: "\n")
        
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
