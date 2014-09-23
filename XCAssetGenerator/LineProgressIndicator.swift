//
//  LineProgressIndicator.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/22/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

class LineProgressIndicator: NSProgressIndicator {

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var progressColor: NSColor
    init(frame: NSRect, progressColor pColor: NSColor) {
        progressColor = pColor
        var pFrame = frame
        pFrame.size.height = 3
        
        super.init(frame: pFrame)
        indeterminate = false
        style = NSProgressIndicatorStyle.BarStyle
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        self.wantsLayer = true

        // Clear background color
   
        NSColor.clearColor().set()
        NSRectFill(dirtyRect)
        // Draw progress line
        var activeRect: NSRect = dirtyRect
        self.progressColor.set()
        var progress = CGFloat(self.doubleValue / self.maxValue)
        activeRect.size.width = floor(activeRect.size.width * progress)
        NSRectFill(activeRect)
        
        // Draw empty line
        var passiveRect: NSRect = dirtyRect
        passiveRect.size.width -= activeRect.size.width
        passiveRect.origin.x = activeRect.size.width
        NSColor.greenColor().set()
        NSRectFill(passiveRect)

    }
    
}
