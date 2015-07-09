//
//  DropView.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/11/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa

protocol DropViewDelegate {
    func dropViewShouldAcceptDraggedPath(dropView: DropView, paths: [Path]) -> Bool
    func dropViewDidDropFileToView(dropView: DropView, paths: [Path])
    func dropViewDidDragValidFileIntoView(dropView: DropView) // Should be called when folder enters drag areas.
    func dropViewDidDragInvalidFileIntoView(dropView: DropView)
    func dropViewDidDragFileOutOfView(dropView: DropView)
    func dropViewNumberOfAcceptableItems(dropView: DropView, items: [Path]) -> Int
}

protocol DropViewMouseDelegate {
    func dropViewDidRightClick(dropView: DropView, event: NSEvent)
}


class DropView: NSView {

    var delegate: DropViewDelegate?
    var mouse: DropViewMouseDelegate?
    // MARK:- Initializers
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    convenience init() {
        self.init()
        setup()
    }
    
    func setup() {
        registerForDraggedTypes([NSFilenamesPboardType])
        self.wantsLayer = true
    }
    
    
    // MARK:- Drag Handlers.
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        let paths = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as! [String]
        let acceptDrag = delegate?.dropViewShouldAcceptDraggedPath(self, paths: paths) ?? false
        if acceptDrag {
            sender.numberOfValidItemsForDrop = delegate?.dropViewNumberOfAcceptableItems(self, items: paths)
                                               ?? sender.numberOfValidItemsForDrop
            delegate?.dropViewDidDragValidFileIntoView(self)
            return NSDragOperation.Copy
        } else {
            delegate?.dropViewDidDragInvalidFileIntoView(self)
            return NSDragOperation.None
        }
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        delegate?.dropViewDidDragFileOutOfView(self)
    }
//    override func draggingExited(sender: NSDraggingInfo?)  {
//        self.delegate?.dropViewDidDragFileOutOfView(self)
//    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool  {
        return true
    }
    
    override func concludeDragOperation(sender: NSDraggingInfo?) {
        let filenames = sender!.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as! [String]
        delegate?.dropViewDidDropFileToView(self, paths: filenames)
    }
    
}

extension DropView {
    override func rightMouseDown(theEvent: NSEvent) {
        mouse?.dropViewDidRightClick(self, event: theEvent)
    }
    
    // HACK: `MenuForEvent` for some reason does not propogate properly on CTRL+Click (but does on right click...) so work around it.
    override func mouseDown(theEvent: NSEvent) {
        if (theEvent.type == NSEventType.LeftMouseDown) && (theEvent.modifierFlags.rawValue & NSEventModifierFlags.ControlKeyMask.rawValue != 0) {
            mouse?.dropViewDidRightClick(self, event: theEvent)
        }
    }

}
