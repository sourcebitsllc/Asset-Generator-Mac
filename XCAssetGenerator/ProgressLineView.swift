//
//  ProgressLineView.swift
//  XCAssetGenerator
//
//  Created by Bader on 6/11/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa


class ProgressLineView: NSView {
    private let line: NSView
    
    var lineWidth: CGFloat = 3 {
        didSet {
            line.frame.size.height = lineWidth
        }
    }
    
    var color: NSColor = NSColor.blackColor() {
        didSet {
            line.layer?.backgroundColor = color.CGColor
        }
    }
    
    init(width: CGFloat) {
        let frame = NSRect(x: 0, y: 0, width: width, height: lineWidth)
        line = NSView(frame: NSRect(x: 0, y: 0, width: 0, height: lineWidth))
        super.init(frame: frame)
        line.wantsLayer = true
        line.layer?.masksToBounds = true
        line.layer?.backgroundColor = color.CGColor
        self.addSubview(line)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateTo(#progress: Float) {
        let width = self.bounds.size.width * (CGFloat(progress) / 100)
        line.animator().frame.size.width = width
    }
    
    func forceAnimateFullProgress() {
        line.animator().frame.size.width = self.frame.size.width
    }
    
    func animateFadeOut() {
        line.animator().alphaValue = 0
    }
    
    func resetProgress() {
        line.animator().frame.size.width = 0
    }
    
    func initiateProgress() {
        line.animator().frame.size.width = 0
        line.alphaValue = 1
    }
}