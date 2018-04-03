//
//  YQGradientView.swift
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/6.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Cocoa

final class YQGradientView: NSView {
    
    @IBInspectable var lowGradientColor: NSColor = NSColor(deviceRed:0.08, green:0.66, blue:0.84, alpha:1.00)
    @IBInspectable var highGradientColor: NSColor = NSColor(deviceRed:0.05, green:0.47, blue:0.73, alpha:1.00)
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let path = NSBezierPath()
        path.appendRect(dirtyRect)

        let gradient = NSGradient(colors: [lowGradientColor, highGradientColor], atLocations: [0, 1], colorSpace: NSColorSpace.deviceRGB)
        gradient?.draw(in: path, angle: -90)
    }
    
}
