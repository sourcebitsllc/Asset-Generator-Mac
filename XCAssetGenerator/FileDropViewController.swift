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

enum DropViewState {
    case InitialState
    case HoveringState
    case SuccessfulDropState
    case InvalidDropState
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
        self.dropView.delegate = self
    
        self.dropImageView = NSImageView()
        self.dropImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.dropImageView.unregisterDraggedTypes() // otherwise, the subview will intercept the dropView calls.
        self.updateDropView(DropViewState.InitialState)
        
        self.dropView.addSubview(self.dropImageView)
        
        var centerX: NSLayoutConstraint = NSLayoutConstraint(item: self.dropImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.dropView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
       
        var centerY: NSLayoutConstraint = NSLayoutConstraint(item: self.dropImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 0.8, constant: 0)
        
        self.dropView.addConstraint(centerX)
        self.dropView.addConstraint(centerY)
        self.dropView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(imageWidth)]", options: nil, metrics: ["imageWidth": 150], views: ["imageView": self.dropImageView]))
         self.dropView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView(imageHeight)]", options: nil, metrics: ["imageHeight": 150], views: ["imageView": self.dropImageView]))
        
    }
    
    
    func updateDropView(state: DropViewState) {
        switch state {
        case .InitialState:
            self.pathLabel.stringValue = "Initial State"
            self.dropImageView.image = NSImage(named: "DropfileInitialState")
        case .HoveringState:
            self.pathLabel.stringValue = "Hovering State"
            self.dropImageView.image = NSImage(named: "DropfileHoverState")
        case .SuccessfulDropState:
            self.pathLabel.stringValue = self.folderPath
            self.dropImageView.image = NSImage(named: "DropfileSuccessState")
        case .InvalidDropState:
            self.pathLabel.stringValue = "Invalid Drop"
        }
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
        self.updateDropView(DropViewState.SuccessfulDropState)
        
        self.delegate?.fileDropControllerDidSetSourcePath(self)
    }
    
    func dropViewDidDragFileIntoView(dropView: DropView) {
//        dropView.layer!.backgroundColor = NSColor.init(red: 144/255, green: 230/255, blue: 33/255, alpha:1).CGColor
        if !self.hasValidSourceProject() {
            self.updateDropView(DropViewState.HoveringState)
        }
    }
    
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        NSLog("File dragged out of view");
        if !self.hasValidSourceProject() {
            self.updateDropView(DropViewState.InitialState)
        }
    }
    
}
