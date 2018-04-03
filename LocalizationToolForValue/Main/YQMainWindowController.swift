//
//  YQMainWindowController.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/8.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Cocoa

class YQMainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.titlebarAppearsTransparent = true
        window?.standardWindowButton(.zoomButton)?.isHidden = true
        window?.titleVisibility = .hidden
    }

}
