//
//  LineProgressIndicator.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/22/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

enum LineProgressThickness : Int {
    case LineProgressThicknessTiny = 1
    case LineProgressThicknessSmall = 2
    case LineProgressThicknessRegular = 3
    case LineProgressThicknessLarge = 5
    
}

class LineProgressIndicator: NSProgressIndicator {

    var progressColor: NSColor!
    var clearColor: NSColor
    
    let clippingMask: NSBezierPath?
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    
    init(frame: NSRect, progressColor pColor: NSColor, clearColor cColor: NSColor, clippingMask mask: NSBezierPath?) {
        progressColor = pColor
        clearColor = cColor
        clippingMask = mask
        
        var pFrame = frame
        pFrame.size.height = 3
        
        super.init(frame: frame)
        indeterminate = false
        style = NSProgressIndicatorStyle.BarStyle
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        self.wantsLayer = true
        
        let clippingRect = NSRect(x: 0, y: 0, width: self.frame.width - 0, height: self.frame.height)
        println("\(clippingRect)")
//        var bez = NSBezierPath(roundedRect: clippingRect , xRadius: 3, yRadius: 3)
////        bez.addClip()
//        NSColor.greenColor().set()
//        bez.lineWidth = 2
//        bez.stroke()
//        
//         Clear background color
        var progressLineRect = NSRect(x: 0, y: self.frame.height - 5, width: self.frame.width, height: 2)
        NSColor.clearColor().set()
        self.clearColor.set()
        NSRectFill(progressLineRect)
        
        
        // Draw progress line
        var activeRect: NSRect = progressLineRect
        self.progressColor.set()
        activeRect.size.width = floor(activeRect.size.width * CGFloat((50 / self.maxValue)))
        NSRectFill(activeRect)

        
        // Drawing code here.

    }
    
}
