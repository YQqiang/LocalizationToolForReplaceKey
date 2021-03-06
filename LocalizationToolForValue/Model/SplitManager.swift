//
//  SplitManager.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/9.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Foundation

enum CodeFileType {
    case OC
    case Swift
    case js
    case html
    case c
}

enum SplitFileType {
    case strings
    case codeFileType(codeFileType: CodeFileType)
    case json
    case xls
    case db
    case xml
    case properties
}

final class SplitManager {
    static let shared = SplitManager.init()
    private init(){}
    
    func split(_ fileModel: YQFileModel, forEach: ((KeyValueModel) -> Bool)? = nil) -> [KeyValueModel] {
        var splitFiletype: SplitFileType = .strings
        if ["strings", "txt"].contains(fileModel.fileExtension.lowercased()) {
            splitFiletype = .strings
        }
        if ["json"].contains(fileModel.fileExtension.lowercased()) {
            splitFiletype = .json
        }
        if ["swift"].contains(fileModel.fileExtension.lowercased()) {
            splitFiletype = .codeFileType(codeFileType: .Swift)
        }
        if ["m"].contains(fileModel.fileExtension.lowercased()) {
            splitFiletype = .codeFileType(codeFileType: .OC)
        }
        if ["js"].contains(fileModel.fileExtension.lowercased()) {
            splitFiletype = .codeFileType(codeFileType: .js)
        }
        if ["html"].contains(fileModel.fileExtension.lowercased()) {
            splitFiletype = .codeFileType(codeFileType: .html)
        }
        if ["c"].contains(fileModel.fileExtension.lowercased()) {
            splitFiletype = .codeFileType(codeFileType: .c)
        }
        if ["xml"].contains(fileModel.fileExtension.lowercased()) {
            splitFiletype = .xml
        }
        if ["properties"].contains(fileModel.fileExtension.lowercased()) {
            splitFiletype = .properties
        }
        return split(fileModel, splitFileType: splitFiletype, forEach: forEach)
    }
}

extension SplitManager {
    
    private func splitProperties(_ fileModel: YQFileModel) -> [KeyValueModel] {
        var sourceKeyValueModels = [KeyValueModel]()
        let jsonContent = try? String.init(contentsOfFile: fileModel.filePath)
        if let lines = jsonContent?.components(separatedBy: "\n") {
            for (index, line) in lines.enumerated() {
                let keyValue = line.components(separatedBy: "=")
                if keyValue.count == 2 {
                    let keyP = keyValue.first!.trimmingCharacters(in: .whitespaces)
                    let valueS = keyValue.last!
                    let keyValueModel = KeyValueModel(key: keyP, value: valueS)
                    keyValueModel.filePath = "\(index)"
                    sourceKeyValueModels.append(keyValueModel)
                }
            }
        }
        return sourceKeyValueModels
    }
    
    private func splitStrings(_ fileModel: YQFileModel, separateStr: String) -> [KeyValueModel] {
        var sourceKeyValueModels = [KeyValueModel]()
        let jsonContent = try? String.init(contentsOfFile: fileModel.filePath)
        if let lines = jsonContent?.components(separatedBy: "\n") {
            for (index, line) in lines.enumerated() {
                let keyValue = line.components(separatedBy: "\" = \"")
                if keyValue.count == 2 {
                    var keyP = keyValue.first!.trimmingCharacters(in: .whitespaces)
                    var valueS = keyValue.last!
                    var dropString = "\""
                    if keyP.hasPrefix(dropString) {
                        keyP = keyP.replacingOccurrences(of: dropString, with: "")
                    }
                    
                    dropString = "\";"
                    if valueS.hasSuffix(dropString) {
                        valueS = valueS.replacingOccurrences(of: dropString, with: "")
                    }
                    let keyValueModel = KeyValueModel(key: keyP, value: valueS)
                    keyValueModel.filePath = "\(index)"
                    sourceKeyValueModels.append(keyValueModel)
                }
            }
        }
        return sourceKeyValueModels
    }
    
    private func split(_ fileModel: YQFileModel, splitFileType: SplitFileType, forEach: ((KeyValueModel) -> Bool)?) -> [KeyValueModel] {
        switch splitFileType {
        case .strings:
            if let _ = forEach {
                return splitStrings(fileModel, forEach: forEach)
            }
            return splitStrings(fileModel, separateStr: "\" = \"")
        case .json:
            return splitJson(fileModel)
        case .codeFileType(codeFileType: let type):
            return splitCodeFile(fileModel, codeFileType: type, forEach: forEach)
        case .xml:
            return splitXml(fileModel)
        case .properties:
            return splitProperties(fileModel)
        default:
            break
        }
        return [KeyValueModel]()
    }
    
    private func splitXml(_ fileModel: YQFileModel) -> [KeyValueModel] {
        var sourceKeyValueModels = [KeyValueModel]()
        let jsonContent = try? String.init(contentsOfFile: fileModel.filePath)
        if let lines = jsonContent?.components(separatedBy: "\n") {
            for line in lines {
                var keyValue = line.components(separatedBy: "\">")
                if keyValue.count != 2 {
                    keyValue = line.components(separatedBy: "\" >")
                }
                if keyValue.count == 2 {
                    var keyP = keyValue.first!.trimmingCharacters(in: .whitespaces)
                    var valueS = keyValue.last!.trimmingCharacters(in: .controlCharacters)
                    var dropString = "<string name=\""
                    if keyP.hasPrefix(dropString) {
                        keyP = keyP.replacingOccurrences(of: dropString, with: "")
                    }
                    
                    dropString = "</string>"
                    if valueS.hasSuffix(dropString) {
                        valueS = valueS.replacingOccurrences(of: dropString, with: "")
                    }
                    let keyValueModel = KeyValueModel(key: keyP, value: valueS)
                    sourceKeyValueModels.append(keyValueModel)
                }
            }
        }
        return sourceKeyValueModels
    }
    
    private func splitJson(_ fileModel: YQFileModel) -> [KeyValueModel] {
        var sourceKeyValueModels = [KeyValueModel]()
        let jsonContent = try? String.init(contentsOfFile: fileModel.filePath)
        let jsonData = jsonContent?.data(using: .utf8)
        let deCoder = JSONDecoder()
        if let data = jsonData {
            let keyValueModels = try? deCoder.decode([KeyValueModel].self, from: data)
            if let models = keyValueModels {
                sourceKeyValueModels = sourceKeyValueModels + models
            }
        }
        return sourceKeyValueModels
    }
    
    private func splitStrings(_ fileModel: YQFileModel, forEach: ((KeyValueModel) -> Bool)?) -> [KeyValueModel] {
        return enumeratorFile(fileModel, prefix: "\"", suffix: "\" = \"", forEach: forEach)
    }
    
    private func splitCodeFile(_ fileModel: YQFileModel, codeFileType: CodeFileType, forEach: ((KeyValueModel) -> Bool)?) -> [KeyValueModel] {
        var prefix = "NSLocalizedString\\(@\""
        var suffix = "\","
        if codeFileType == .Swift {
            prefix = "NSLocalizedString\\(\""
        }
        if codeFileType == .js {
            prefix = "localized\\('"
            suffix = "'"
            var part = enumeratorFile(fileModel, prefix: prefix, suffix: suffix, forEach: forEach)
            prefix = "localized\\(\""
            suffix = "\""
            part += enumeratorFile(fileModel, prefix: prefix, suffix: suffix, forEach: forEach)
            prefix = "localized\\([\""
            suffix = "\""
            part += enumeratorFile(fileModel, prefix: prefix, suffix: suffix, forEach: forEach)
            prefix = "localized\\(['"
            suffix = "'"
            part += enumeratorFile(fileModel, prefix: prefix, suffix: suffix, forEach: forEach)
            return part
        }
        if codeFileType == .html {
            prefix = "I18N_"
            suffix = "'"
            let part = enumeratorFile(fileModel, prefix: prefix, suffix: suffix, containPrefix: true, forEach: forEach)
            prefix = "I18N_"
            suffix = "\""
            return part + enumeratorFile(fileModel, prefix: prefix, suffix: suffix, containPrefix: true, forEach: forEach)
        }
        if codeFileType == .c {
            prefix = "I18"
            suffix = "\","
            return enumeratorFile(fileModel, prefix: prefix, suffix: suffix, containPrefix: true, forEach: forEach)
        }
        return enumeratorFile(fileModel, prefix: prefix, suffix: suffix, forEach: forEach)
    }
    
    private func enumeratorFile(_ fileModel: YQFileModel, prefix: String, suffix: String, containPrefix: Bool = false, loop: Bool = true, forEach: ((KeyValueModel) -> Bool)?) -> [KeyValueModel] {
        let content = try? String.init(contentsOfFile: fileModel.filePath)
        var sourceKeyValueModels = [KeyValueModel]()
        if let content = content {
            let pattern = containPrefix ? "(?=\(prefix)).*?(?=\(suffix))" : "(?<=\(prefix)).*?(?=\(suffix))"
            let regular = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regular?.matches(in: content, options: .reportProgress, range: NSRange.init(location: 0, length: content.count))
            if let checkResults = matches {
                for checkResult in checkResults {
                    let key = (content as NSString).substring(with: checkResult.range)
                    let keyValueModel = KeyValueModel(key: key, value: "")
                    keyValueModel.filePath = fileModel.filePath
                    keyValueModel.range = checkResult.range
                    sourceKeyValueModels.append(keyValueModel)
                    if let closure = forEach {
                        let haveTargetKey = closure(keyValueModel)
                        if haveTargetKey && loop && !["strings", "txt"].contains(fileModel.fileExtension.lowercased()) {
                            for _ in 0..<checkResults.count {
                                _ = enumeratorFile(fileModel, prefix: prefix, suffix: suffix, containPrefix: containPrefix, loop: false, forEach: closure)
                            }
                        }
                    }
                }
            }
        }
        return sourceKeyValueModels
    }
}
