//
//  YQTableViewDelegate.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/8.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Cocoa

class YQTableViewDelegate: NSObject {
    
    var fileModels: [YQFileModel]? {
        didSet {
            reloadTableView()
        }
    }
    
    var tableview: NSTableView? {
        didSet {
            tableview?.register(NSNib(nibNamed: "YQTableCellView", bundle: nil)!, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "YQTableCellView"))
        }
    }
    
}

// MARK: - public action
extension YQTableViewDelegate {
    func reloadTableView() {
        tableview?.reloadData()
    }
}

// MARK: - NSTableViewDataSource
extension YQTableViewDelegate: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fileModels?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        print("------ \(row)")
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "YQTableCellView"), owner: self) as? YQTableCellView
        cell?.fileModel = fileModels?[row]
        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }

}

// MARK: - NSTableViewDelegate
extension YQTableViewDelegate: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if let filePath = fileModels?[row].filePath {
            NSWorkspace.shared.openFile(filePath)
        }
        return true
    }
}

