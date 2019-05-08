//
//  YQDragDropView.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/6.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Cocoa

@objc protocol YQDragDropViewDelegate:NSObjectProtocol {
    @objc optional func draggingEntered(_ dragDropView: YQDragDropView)
    @objc optional func draggingExit(_ dragDropView: YQDragDropView)
    func draggingFileAccept(_ dragDropView: YQDragDropView, files:[String])
}

final class YQDragDropView: NSView {
    
    @IBInspectable var image: NSImage? {
        didSet {
            if let img = image {
                imageV.image = img
            }
        }
    }
    
    @IBInspectable var text: String? {
        didSet {
            if let txt = text {
                textF.stringValue = txt
            }
        }
    }
    
    @IBInspectable var textColor: NSColor? {
        didSet {
            textF.textColor = textColor
        }
    }
    
    @IBInspectable var fontSize: CGFloat = 16 {
        didSet {
            textF.font = NSFont.systemFont(ofSize: fontSize)
        }
    }
    
    var delegate : YQDragDropViewDelegate?
    
    fileprivate lazy var imageV: NSImageView = {
        let imageV = NSImageView()
        imageV.isEnabled = false
        imageV.unregisterDraggedTypes()
        addSubview(imageV)
        return imageV
    }()
    
    fileprivate lazy var textF: NSTextField = {
        let textField = NSTextField()
        textField.isEnabled = false
        textField.isEditable = false
        textField.backgroundColor = NSColor.clear
        textField.isBordered = false
        textField.alignment = .center
        textField.font = NSFont.systemFont(ofSize: fontSize)
        addSubview(textField)
        return textField
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createView()
        
        imageV.translatesAutoresizingMaskIntoConstraints = false
        let imgVConstraintCenterY = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: imageV, attribute: .bottom, multiplier: 1, constant: 0)
        let imgVConstraintCenterX = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: imageV, attribute: .centerX, multiplier: 1, constant: 0)
        addConstraints([imgVConstraintCenterY, imgVConstraintCenterX])
        
        textF.translatesAutoresizingMaskIntoConstraints = false
        let textFConstraintTop = NSLayoutConstraint(item: imageV, attribute: .bottom, relatedBy: .equal, toItem: textF, attribute: .top, multiplier: 1, constant: -24)
        let textFConstraintLeft = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: textF, attribute: .left, multiplier: 1, constant: -32)
        let textFConstraintRight = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: textF, attribute: .right, multiplier: 1, constant: 32)
        let textFConstraintBottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: textF, attribute: .bottom, multiplier: 1, constant: 0)
        addConstraints([textFConstraintTop, textFConstraintLeft, textFConstraintRight, textFConstraintBottom])
        
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
}

extension YQDragDropView {
    private func createView() {
        registerForDraggedTypes([.backwardsCompatibleFileURL])
//        layer?.borderColor = NSColor.red.cgColor
//        layer?.borderWidth = 3
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(draggingEntered(_:))) {
                delegate.draggingEntered!(self);
            }
        }
        let pastboard = sender.draggingPasteboard
        if (pastboard.types?.contains(.backwardsCompatibleFileURL))! {
            return .copy
        }
        return .every
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(draggingExited(_:))) {
                delegate.draggingExit!(self);
            }
        }
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let files: [String]? = sender.draggingPasteboard.propertyList(forType: .backwardsCompatibleFileURL) as? [String]
        print("------ \(String(describing: files))")
        if self.delegate != nil, let files = files {
            self.delegate?.draggingFileAccept(self, files: files);
        }
        return true
    }
}

extension NSPasteboard.PasteboardType {
    static let backwardsCompatibleFileURL: NSPasteboard.PasteboardType = {
        return NSPasteboard.PasteboardType("NSFilenamesPboardType")
    }()
}
