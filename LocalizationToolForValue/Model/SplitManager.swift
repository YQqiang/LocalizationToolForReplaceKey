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
}

final class SplitManager {
    static let shared = SplitManager.init()
    private init(){}
    
    func split(_ fileModel: YQFileModel, forEach: ((KeyValueModel) -> Void)? = nil) -> [KeyValueModel] {
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
        return split(fileModel, splitFileType: splitFiletype, forEach: forEach)
    }
}

extension SplitManager {
    
    private func splitStrings(_ fileModel: YQFileModel, separateStr: String) -> [KeyValueModel] {
        let content = try? String.init(contentsOfFile: fileModel.filePath, encoding: String.Encoding.utf8)
        let arr = content?.components(separatedBy: "\n")
        var sourceKeyValueModels = [KeyValueModel]()
        arr?.forEach({ (str) in
            let keyValue = str.components(separatedBy: separateStr)
            if keyValue.count == 2 {
                sourceKeyValueModels.append(KeyValueModel(key: keyValue.first!, chValue: keyValue.last!, enValue: keyValue.last!, geValue: "", jpValue: ""))
            }
        })
        return sourceKeyValueModels
    }
    
    private func split(_ fileModel: YQFileModel, splitFileType: SplitFileType, forEach: ((KeyValueModel) -> Void)?) -> [KeyValueModel] {
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
        default:
            break
        }
        return [KeyValueModel]()
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
    
    private func splitStrings(_ fileModel: YQFileModel, forEach: ((KeyValueModel) -> Void)?) -> [KeyValueModel] {
        return enumeratorFile(fileModel, prefix: "\"", suffix: "\" = \"", forEach: forEach)
    }
    
    private func splitCodeFile(_ fileModel: YQFileModel, codeFileType: CodeFileType, forEach: ((KeyValueModel) -> Void)?) -> [KeyValueModel] {
        var prefix = "NSLocalizedString\\(@\""
        let suffix = "\","
        if codeFileType == .Swift {
            prefix = "NSLocalizedString\\(\""
        }
        return enumeratorFile(fileModel, prefix: prefix, suffix: suffix, forEach: forEach)
    }
    
    private func enumeratorFile(_ fileModel: YQFileModel, prefix: String, suffix: String, forEach: ((KeyValueModel) -> Void)?) -> [KeyValueModel] {
        let content = try? String.init(contentsOfFile: fileModel.filePath, encoding: String.Encoding.utf8)
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
                        closure(keyValueModel)
                    }
                }
            }
        }
        return sourceKeyValueModels
    }
}
