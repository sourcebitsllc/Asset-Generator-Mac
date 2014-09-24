//
//  FileDropViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/11/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

let kBottomBarHeight: CGFloat = 30
protocol FileDropControllerDelegate {
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController)
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController)
}

class FileDropViewController: NSViewController, DropViewDelegate, ScriptSourcePathDelegate {

    @IBOutlet var dropView: DropView!
    @IBOutlet var pathLabel: NSTextField!
    var delegate: FileDropControllerDelegate?
    
    var dropImageView: NSImageView!
    var center: CGPoint!
    
    private var folderPath : String?
    
    
    required init(coder: NSCoder!) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropView.delegate = self
    
        self.center = CGPoint(x: (self.view.frame.width - 150) / 2, y: (self.view.frame.height - 150 + 20 + kBottomBarHeight) / 2)
        self.dropImageView = NSImageView(frame: NSRect(origin: center, size: CGSize(width: 150, height: 150)))
        self.dropImageView.autoresizingMask = NSAutoresizingMaskOptions.ViewMinXMargin | NSAutoresizingMaskOptions.ViewMaxXMargin | NSAutoresizingMaskOptions.ViewMinYMargin | NSAutoresizingMaskOptions.ViewMaxYMargin
        
        self.dropImageView.image = NSImage(named: "DropfileInitialState")
        self.dropImageView.unregisterDraggedTypes() // otherwise, the subview will intercept the dropView calls.
        
        dropView.addSubview(self.dropImageView)
    }
    
    override func loadView() {
        super.loadView()
    }
    
    // MARK:- ScriptSourcePath Delegate
    func sourcePath() -> String? {
        if let sourcePath = self.folderPath {
            return sourcePath + "/"
        } else {
            return self.folderPath
        }
    }
    
    func hasValidSourceProject() -> Bool {
        return (self.folderPath? != nil) ? true : false
    }
    
    // MARK: - DropViewDelegate required functions.
    func dropViewDidDropFileToView(dropView: DropView, filePath: String) {
        self.folderPath = filePath
        self.pathLabel.stringValue = filePath
        self.dropImageView.image = NSImage(named: "DropfileSuccessState")
        
        self.delegate?.fileDropControllerDidSetSourcePath(self)
    }
    
    func dropViewDidDragFileIntoView(dropView: DropView) {
//        dropView.layer!.backgroundColor = NSColor.init(red: 144/255, green: 230/255, blue: 33/255, alpha:1).CGColor
        if !self.hasValidSourceProject() {
            self.dropImageView.image = NSImage(named: "DropfileHoverState")
        }
    }
    
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        NSLog("File dragged out of view");
        if !self.hasValidSourceProject() {
            self.dropImageView.image = NSImage(named: "DropfileInitialState")
        }
//        dropView.layer!.backgroundColor = NSColor.clearColor().CGColor
    }
    
}
