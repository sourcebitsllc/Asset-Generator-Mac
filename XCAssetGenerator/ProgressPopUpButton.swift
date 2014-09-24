//
//  ProgressPopUpButton.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/22/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

// TODO: Basically this class and the whole MacOSX API is a big practical joke. Why else wouldnt NSPopUpButton inherit form NSVIew? ucksake. Everything in this drawrect is fragile and hard-coded which will probably break in the near future.
// FIXME: This whole dump
class ProgressPopUpButton: NSPopUpButton {
    
    var progress: CGFloat = 0
    var maxValue: CGFloat
    var minValue: CGFloat
    
    var progressColor: NSColor!
    var clearColor: NSColor
    var line : LineProgressIndicator!

    
    // MARK:- Initializers.
    
    override init(frame buttonFrame: NSRect, pullsDown flag: Bool) {
        maxValue = 100
        minValue = 0
        progress = 0
        
        clearColor = NSColor(calibratedRed: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        super.init(frame: buttonFrame, pullsDown: flag)
        setup()
        
    }
    
    required init(coder: NSCoder!) {
        maxValue = 100
        minValue = 0
        progress = 0
        clearColor = NSColor(calibratedRed: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        super.init(coder: coder)
        setup()
        
    }
    
    
    func setup() {
        self.maxValue = 100
        self.minValue = 0
        self.progress = self.minValue
        
        self.clearColor = NSColor(calibratedRed: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        var lineRect = NSRect(x: 0, y: self.frame.height - 5, width: self.frame.width, height: 3)
        
        let clippingRect = NSRect(x: 0.3, y: 2, width: self.frame.width - 0, height: self.frame.height-5)
        var clippingPath = NSBezierPath(roundedRect: clippingRect , xRadius: 3, yRadius: 3)
        
        //        line = LineProgressIndicator(frame: lineRect, progressColor: NSColor.blueColor(), clearColor: NSColor.brownColor(), clippingMask: clippingPath)
        //        self.addSubview(line)
        //        line.doubleValue = 50
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        self.wantsLayer = true

        let clippingRect = NSRect(x: 0.3, y: 2, width: self.frame.width - 0, height: self.frame.height-5)
        NSBezierPath(roundedRect: clippingRect , xRadius: 3, yRadius: 3).addClip()
//        NSColor.greenColor().set()
//        NSBezierPath(roundedRect: clippingRect , xRadius: 3, yRadius: 3).stroke()
        
        // Clear background color
        var progressLineRect = NSRect(x: 0, y: self.frame.height - 5, width: self.frame.width, height: 2)
        NSColor.clearColor().set()
        self.clearColor.set()
        NSRectFill(progressLineRect)
//
//        
        // Draw progress line
        var activeRect: NSRect = progressLineRect
        self.progressColor.set()
        activeRect.size.width = floor(activeRect.size.width * (self.progress / self.maxValue))
        NSRectFill(activeRect)
//
//        // Drawing code here.
    }
    
    func setProgress(progress p : CGFloat) {
        progress = p
        self.setNeedsDisplay()
    }
    
    func setProgressColor(color: NSColor) {
        progressColor = color
        self.setNeedsDisplay()
    }
    
    
//    override func layoutSubtreeIfNeeded() {
//        println("layout")
//        self.setup()
//        println()
//    }
    
}
