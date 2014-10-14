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
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController, path: String)
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController)
}

enum DropViewState {
    case InitialState
    case HoveringState
    case SuccessfulDropState
    case InvalidDropState
    case PathNoLongerExistsState
}

class FileDropViewController: NSViewController, DropViewDelegate, ScriptSourcePathDelegate {

    @IBOutlet var dropView: DropView!
    @IBOutlet var pathLabel: NSTextField!
    @IBOutlet var detailLabel: NSTextField!
    
    var delegate: FileDropControllerDelegate?
    
    var dropImageView: NSImageView!
    var center: CGPoint!
    
    private var folderPath : String?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dropView.delegate = self
    
        self.dropImageView = NSImageView()
        self.dropImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.dropImageView.unregisterDraggedTypes() // otherwise, the subview will intercept the dropView calls.
        self.updateDropView(state: DropViewState.InitialState)
        
        self.dropView.addSubview(self.dropImageView)
        
        var centerX: NSLayoutConstraint = NSLayoutConstraint(item: self.dropImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.dropView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
       
        var centerY: NSLayoutConstraint = NSLayoutConstraint(item: self.dropImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 0.8, constant: 0)
        
        self.dropView.addConstraint(centerX)
        self.dropView.addConstraint(centerY)
        self.dropView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(imageWidth)]", options: nil, metrics: ["imageWidth": 150], views: ["imageView": self.dropImageView]))
         self.dropView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView(imageHeight)]", options: nil, metrics: ["imageHeight": 150], views: ["imageView": self.dropImageView]))
        
    }
    
    
    func updateDropView(#state: DropViewState) {
        switch state {
        case .InitialState:
            self.dropImageView.image     = NSImage(named: "DropfileInitialState")
            self.pathLabel.stringValue   = "Initial State"
            self.detailLabel.stringValue = "Initial Detail Label"
        case .HoveringState:
            self.dropImageView.image     = NSImage(named: "DropfileHoverState")
            self.pathLabel.stringValue   = "Hovering State"
            self.detailLabel.stringValue = "Hovering Detail Label"
        case .SuccessfulDropState:
            self.dropImageView.image     = NSImage(named: "DropfileSuccessState")
            self.pathLabel.stringValue   = self.folderPath ?? ""
            self.detailLabel.stringValue = "Successful Drop Detail Label"
        case .InvalidDropState:
            self.pathLabel.stringValue   = "Invalid Drop"
            self.detailLabel.stringValue = "Invalid Drop Detail Label"
        case .PathNoLongerExistsState:
            self.dropImageView.image     = nil
            self.pathLabel.stringValue   = "Directory no longer exists"
            self.detailLabel.stringValue = "Directory no longer exists Detail Label"
        }
    }
    
    func validateIfSourcePathStillExists() {
        if let source = self.folderPath {
            if !PathValidator.directoryExists(path: source) {
                self.updateDropView(state: DropViewState.PathNoLongerExistsState)
            } else {
                self.updateDropView(state: DropViewState.SuccessfulDropState)
            }
        } else {
            self.updateDropView(state: DropViewState.InitialState)
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
    
    func dropViewShouldAcceptDraggedPath(dropView: DropView, paths: [String]) -> Bool {
        let pathname = paths[0]
        return PathValidator.directoryExists(path: pathname)
    }
    
    func dropViewDidDropFileToView(dropView: DropView, filePath: String) {
        self.folderPath = filePath
        self.updateDropView(state: DropViewState.SuccessfulDropState)
    
        self.delegate?.fileDropControllerDidSetSourcePath(self,path: self.folderPath!)
    }
    
    
    func dropViewDidDragValidFileIntoView(dropView: DropView) {
        if !self.hasValidSourceProject() {
            self.updateDropView(state: DropViewState.HoveringState)
        }
    }
    
    func dropViewDidDragInvalidFileIntoView(dropView: DropView) {
        self.updateDropView(state: DropViewState.InvalidDropState)
    }
    
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        if !self.hasValidSourceProject() {
            self.updateDropView(state: DropViewState.InitialState)
        } else {
            self.updateDropView(state: DropViewState.SuccessfulDropState)
        }
    }
    
}
