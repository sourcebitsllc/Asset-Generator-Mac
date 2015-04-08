//
//  ProgressPopUpButton.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/22/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

class ProgressPopUpButton: NSPopUpButton {

    var line: NSView!
    // TODO: let color be property
    
    // MARK:- Initializers.
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        var maskFrame = self.bounds
        maskFrame.size.height = maskFrame.size.height - 4
        maskFrame.size.width = maskFrame.size.width + 51
        
        var outerClip = NSView(frame: maskFrame)
        outerClip.wantsLayer = true
        outerClip.layer?.cornerRadius = 3
        
        line = NSView(frame: NSRect(x: 0, y: 0, width:0, height: 2))
        line.wantsLayer = true
        line.layer?.masksToBounds = true
        
        outerClip.addSubview(line)
        self.addSubview(outerClip)
    }
    

    
    func setProgress(#progress : CGFloat) {
        let width = ( line.superview!.bounds.size.width * (progress / 100) )
        line.animator().frame.size.width = width
    }
    
    func resetProgress() {
        let width = line.superview!.bounds.size.width
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
            self.line.animator().frame.size.width = width
            }, completionHandler: { () -> Void in
                
                NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
                    self.line.animator().alphaValue = 0
                    }, completionHandler: { () -> Void in
                        self.line.frame.size.width = 0
                        self.line.alphaValue = 1
                })
        })
        
    }
    
    func setProgressColor(color: NSColor = NSColor(calibratedRed: 0.047, green: 0.261, blue: 0.993, alpha: 1)) {
        line.layer!.backgroundColor = color.CGColor
    }
}
