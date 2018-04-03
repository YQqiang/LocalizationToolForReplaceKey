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
    
    func split(_ fileModel: YQFileModel) -> [KeyValueModel] {
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
        return split(fileModel, splitFileType: splitFiletype)
    }
}

extension SplitManager {
    
    private func split(_ fileModel: YQFileModel, splitFileType: SplitFileType) -> [KeyValueModel] {
        switch splitFileType {
        case .strings:
            return splitStrings(fileModel)
        case .json:
            return splitJson(fileModel)
        case .codeFileType(codeFileType: let type):
            return splitCodeFile(fileModel, codeFileType: type)
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
    
    private func splitStrings(_ fileModel: YQFileModel) -> [KeyValueModel] {
        let content = try? String.init(contentsOfFile: fileModel.filePath, encoding: String.Encoding.utf8)
        var sourceKeyValueModels = [KeyValueModel]()
        if let content = content {
            let regular = try? NSRegularExpression(pattern: "(?<=\").*?(?=\" = \")", options: .caseInsensitive)
            let matches = regular?.matches(in: content, options: .reportProgress, range: NSRange.init(location: 0, length: content.count))
            if let checkResults = matches {
                for checkResult in checkResults {
                    let key = (content as NSString).substring(with: checkResult.range)
                    if !key.hasPrefix("I18N") {
                        let keyValueModel = KeyValueModel(key: key, chValue: "", enValue: "", geValue: "", jpValue: "")
                        keyValueModel.filePath = fileModel.filePath
                        keyValueModel.range = checkResult.range
                        sourceKeyValueModels.append(keyValueModel)
                    }
                }
            }
        }
        return sourceKeyValueModels
    }
    
    private func splitCodeFile(_ fileModel: YQFileModel, codeFileType: CodeFileType) -> [KeyValueModel] {
        let content = try? String.init(contentsOfFile: fileModel.filePath, encoding: String.Encoding.utf8)
        var sourceKeyValueModels = [KeyValueModel]()
        if let content = content {
            var regular = try? NSRegularExpression(pattern: "(?<=NSLocalizedString\\(@\").*?(?=\",)", options: .caseInsensitive)
            if codeFileType == .Swift {
                regular = try? NSRegularExpression(pattern: "(?<=NSLocalizedString\\(\").*?(?=\",)", options: .caseInsensitive)
            }
            let matches = regular?.matches(in: content, options: .reportProgress, range: NSRange.init(location: 0, length: content.count))
            if let checkResults = matches {
                for checkResult in checkResults {
                    let key = (content as NSString).substring(with: checkResult.range)
                    if !key.hasPrefix("I18N") {
                        let keyValueModel = KeyValueModel(key: key, chValue: "", enValue: "", geValue: "", jpValue: "")
                        keyValueModel.filePath = fileModel.filePath
                        keyValueModel.range = checkResult.range
                        sourceKeyValueModels.append(keyValueModel)
                    }
                }
            }
        }
        return sourceKeyValueModels
    }
}
