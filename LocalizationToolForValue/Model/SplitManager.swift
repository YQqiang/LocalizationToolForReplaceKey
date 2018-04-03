//
//  SplitManager.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/9.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Foundation

enum SplitFileType {
    case strings(separateStr: String)
    case json
    case xls
    case db
}

final class SplitManager {
    static let shared = SplitManager.init()
    private init(){}
    
    func split(_ fileModel: YQFileModel) -> [KeyValueModel] {
        var splitFiletype: SplitFileType = .strings(separateStr: "")
        if ["strings", "txt"].contains(fileModel.fileExtension) {
            splitFiletype = .strings(separateStr: "\" = \"")
        }
        if ["json"].contains(fileModel.fileExtension) {
            splitFiletype = .json
        }
        return split(fileModel, splitFileType: splitFiletype)
    }
}

extension SplitManager {
    
    private func split(_ fileModel: YQFileModel, splitFileType: SplitFileType) -> [KeyValueModel] {
        switch splitFileType {
        case .strings(separateStr: let separateStr):
            return splitStrings(fileModel, separateStr: separateStr)
        case .json:
            return splitJson(fileModel)
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
    
    private func splitStrings(_ fileModel: YQFileModel, separateStr: String) -> [KeyValueModel] {
        let content = try? String.init(contentsOfFile: fileModel.filePath, encoding: String.Encoding.utf8)
        let arr = content?.components(separatedBy: "\n")
        var sourceKeyValueModels = [KeyValueModel]()
        arr?.forEach({ (str) in
            let keyValue = str.components(separatedBy: separateStr)
            if keyValue.count == 2 {
                sourceKeyValueModels.append(KeyValueModel(key: keyValue.first!, chValue: "", enValue: keyValue.last!, geValue: "", jpValue: ""))
            }
        })
        return sourceKeyValueModels
    }
}
