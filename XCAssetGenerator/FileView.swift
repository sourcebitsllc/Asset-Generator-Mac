//
//  FileView.swift
//  XCAssetGenerator
//
//  Created by Pranav Shah on 7/30/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

protocol FileViewDelegate {
    func fileDraggedToView(fileView : FileView, path : String)
}

class FileView : NSView {
    var highlight = false
    var delegate : FileViewDelegate?
    
    init(coder: NSCoder!) {
        super.init(coder: coder)
        setup()
    }
    
    init(frame frameRect: NSRect)  {
        super.init(frame: frameRect)
        setup()
    }
    
    init()  {
        super.init()
        setup()
    }
    
    func setup() {
        self.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    override func draggingEntered(sender: NSDraggingInfo!) -> NSDragOperation {
        highlight = true
        setNeedsDisplayInRect(self.bounds)
        return NSDragOperation.Generic
    }
    
    override func draggingExited(sender: NSDraggingInfo!)  {
        highlight = false
        setNeedsDisplayInRect(self.bounds)
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo!) -> Bool
    {
        highlight = false
        setNeedsDisplayInRect(self.bounds)
        return true
    }
    
    override func performDragOperation(sender: NSDraggingInfo!) -> Bool  {
        return true
    }
    
    override func concludeDragOperation(sender: NSDraggingInfo!)  {
        var filenames = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as Array<String>
        var filename = filenames[0]
        
        delegate?.fileDraggedToView(self, path: filename)
    }
    
    override func drawRect(dirtyRect: NSRect)  {
        super.drawRect(dirtyRect)
        
        if highlight {
            NSColor.grayColor().set()
            NSBezierPath.setDefaultLineWidth(5)
            NSBezierPath.strokeRect(self.bounds)
        }
    }

}