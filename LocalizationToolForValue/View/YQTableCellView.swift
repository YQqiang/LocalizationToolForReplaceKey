//
//  YQTableCellView.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/7.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Cocoa

class YQTableCellView: NSTableCellView {

    var fileModel: YQFileModel? {
        didSet {
            guard let model = fileModel else {
                return
            }
            if ["png", "jpg", "jpeg"].contains(model.fileExtension) {
                fileType.image = NSImage(contentsOfFile: model.filePath)
            } else {
                fileType.image = model.isFolder ? NSImage.init(imageLiteralResourceName: "folder") : NSImage.init(imageLiteralResourceName: "file")                
            }
            fileName.stringValue = model.fileName
            
            print("------- filename = \(fileName.stringValue)")
        }
    }
    
    
    @IBOutlet weak var fileType: NSImageView!
    @IBOutlet weak var fileName: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
