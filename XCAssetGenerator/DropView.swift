//
//  DropView.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/11/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

protocol DropViewDelegate {
    
    func dropViewDidDropFileToView(dropView: DropView, filePath: String)
    func dropViewDidDragFileIntoView(dropView: DropView) // Should be called when folder enters drag areas.
    func dropViewDidDragFileOutOfView(dropView: DropView) // should be called file already in drag area, but we drag it out to delete it. May not be nessecary.
}

class DropView: NSView {

    var delegate: DropViewDelegate?
    
//    override func drawRect(dirtyRect: NSRect) {
//        super.drawRect(dirtyRect)
//
//        // Drawing code here.
//    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.setup()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
        self.registerForDraggedTypes([NSFilenamesPboardType])
        self.wantsLayer = true
    }
    
    override func draggingEntered(sender: NSDraggingInfo!) -> NSDragOperation {
        delegate?.dropViewDidDragFileIntoView(self)
        return NSDragOperation.Copy
    }
    
    override func draggingExited(sender: NSDraggingInfo!)  {
        delegate?.dropViewDidDragFileOutOfView(self)
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo!) -> Bool {
        return true
    }
    
    override func performDragOperation(sender: NSDraggingInfo!) -> Bool  {
        return true
    }
    
    override func concludeDragOperation(sender: NSDraggingInfo!)  {
        var filenames = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as Array<String>
        var filename = filenames[0]
        
        delegate?.dropViewDidDropFileToView(self, filePath: filename)
    }
    
    
}
