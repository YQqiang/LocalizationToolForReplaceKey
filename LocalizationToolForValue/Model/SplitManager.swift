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
}

enum SplitFileType {
    case strings
    case codeFileType(codeFileType: CodeFileType)
    case json
    case xls
    case db
    case xml
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
        if ["xml"].contains(fileModel.fileExtension.lowercased()) {
            splitFiletype = .xml
        }
        return split(fileModel, splitFileType: splitFiletype, forEach: forEach)
    }
}

extension SplitManager {
    
    private func splitStrings(_ fileModel: YQFileModel, separateStr: String) -> [KeyValueModel] {
        var sourceKeyValueModels = [KeyValueModel]()
        let jsonContent = try? String.init(contentsOfFile: fileModel.filePath)
        if let lines = jsonContent?.components(separatedBy: "\n") {
            for line in lines {
                let keyValue = line.components(separatedBy: "\" = \"")
                if keyValue.count == 2 {
                    var keyP = keyValue.first!.trimmingCharacters(in: .whitespaces)
                    var valueS = keyValue.last!
                    var dropString = "\""
                    if keyP.hasPrefix(dropString) {
                        keyP = keyP.replacingOccurrences(of: dropString, with: "")
                    }
                    
                    dropString = "\";\r"
                    if valueS.hasSuffix(dropString) {
                        valueS = valueS.replacingOccurrences(of: dropString, with: "")
                    }
                    let keyValueModel = KeyValueModel(key: keyP, chValue: valueS, enValue: valueS, geValue: valueS, jpValue: valueS)
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
                let keyValue = line.components(separatedBy: "\">")
                if keyValue.count == 2 {
                    var keyP = keyValue.first!.trimmingCharacters(in: .whitespaces)
                    var valueS = keyValue.last!
                    var dropString = "<string name=\""
                    if keyP.hasPrefix(dropString) {
                        keyP = keyP.replacingOccurrences(of: dropString, with: "")
                    }
                    
                    dropString = "</string>"
                    if valueS.hasSuffix(dropString) {
                        valueS = valueS.replacingOccurrences(of: dropString, with: "")
                    }
                    let keyValueModel = KeyValueModel(key: keyP, chValue: valueS, enValue: valueS, geValue: valueS, jpValue: valueS)
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
        let suffix = "\","
        if codeFileType == .Swift {
            prefix = "NSLocalizedString\\(\""
        }
        return enumeratorFile(fileModel, prefix: prefix, suffix: suffix, forEach: forEach)
    }
    
    private func enumeratorFile(_ fileModel: YQFileModel, prefix: String, suffix: String, loop: Bool = true, forEach: ((KeyValueModel) -> Bool)?) -> [KeyValueModel] {
        let content = try? String.init(contentsOfFile: fileModel.filePath)
        var sourceKeyValueModels = [KeyValueModel]()
        if let content = content {
            let regular = try? NSRegularExpression(pattern: "(?<=\(prefix)).*?(?=\(suffix))", options: .caseInsensitive)
            let matches = regular?.matches(in: content, options: .reportProgress, range: NSRange.init(location: 0, length: content.count))
            if let checkResults = matches {
                for checkResult in checkResults {
                    let key = (content as NSString).substring(with: checkResult.range)
                    let keyValueModel = KeyValueModel(key: key, chValue: "", enValue: "", geValue: "", jpValue: "")
                    keyValueModel.filePath = fileModel.filePath
                    keyValueModel.range = checkResult.range
                    sourceKeyValueModels.append(keyValueModel)
                    if let closure = forEach {
                        let haveTargetKey = closure(keyValueModel)
                        if haveTargetKey && loop && !["strings"].contains(fileModel.fileExtension.lowercased()) {
                            for _ in 0..<checkResults.count {
                                _ = enumeratorFile(fileModel, prefix: prefix, suffix: suffix, loop: false, forEach: closure)
                            }
                        }
                    }
                }
            }
        }
        return sourceKeyValueModels
    }
}
