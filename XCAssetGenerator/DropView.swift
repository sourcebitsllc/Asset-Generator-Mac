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
    func dropViewDidDragFileOutOfView(dropView: DropView) // should be called file already in drag area, but we drag it out to delete it. May not be nessecary.
}


class DropView: NSView {

    var delegate: DropViewDelegate?
    
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
