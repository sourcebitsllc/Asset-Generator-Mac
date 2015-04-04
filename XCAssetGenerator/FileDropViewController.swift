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
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController, path: Path, previousPath: String?)
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController, removedPath: String)
}

enum DropViewState {
    case Initial
    case Hovering
    case SuccessfulDrop
    case SuccessfulButEmptyDrop
    case InvalidDrop
    case PathNoLongerExists
}

class FileDropViewController: NSViewController {

    @IBOutlet var dropView: DropView!
    @IBOutlet var pathLabel: NSTextField!
    @IBOutlet var detailLabel: NSTextField!
    
    var delegate: FileDropControllerDelegate?
    var directoryObserver: SourceObserver!
    
    var dropImageView: NSImageView!
    
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
        self.updateDropView(state: DropViewState.Initial)
        
        self.dropView.addSubview(self.dropImageView)
        
        let centerX: NSLayoutConstraint = NSLayoutConstraint(item: self.dropImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.dropView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
       
        let centerY: NSLayoutConstraint = NSLayoutConstraint(item: self.dropImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 0.8, constant: 0)
        
        self.dropView.addConstraint(centerX)
        self.dropView.addConstraint(centerY)
        self.dropView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(imageWidth)]", options: nil, metrics: ["imageWidth": 150], views: ["imageView": self.dropImageView]))
         self.dropView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView(imageHeight)]", options: nil, metrics: ["imageHeight": 150], views: ["imageView": self.dropImageView]))
        
        
        directoryObserver = SourceObserver(delegate: self)
    }
    
    
    func updateDropView(#state: DropViewState) {
        switch state {
        case .Initial:
            self.dropImageView.image     = NSImage(named: "DropfileInitialState")
            self.pathLabel.stringValue   = NSLocalizedString("Initial State", comment: "")
            self.detailLabel.stringValue = NSLocalizedString("Initial Detail Label", comment: "")
        case .Hovering:
            self.dropImageView.image     = NSImage(named: "DropfileHoverState")
            self.pathLabel.stringValue   = NSLocalizedString("Hovering State", comment: "")
            self.detailLabel.stringValue = NSLocalizedString("Hovering Detail Label", comment: "")
        case .SuccessfulDrop:
            self.dropImageView.image     = NSImage(named: "DropfileSuccessState")
            self.pathLabel.stringValue   = self.folderPath?.lastPathComponent ?? ""
            self.detailLabel.stringValue = NSLocalizedString("Successful Drop Detail Label", comment: "")
        case .SuccessfulButEmptyDrop:
            self.dropImageView.image     = NSImage(named: "DropfileInitialState")
            self.pathLabel.stringValue   = self.folderPath?.lastPathComponent ?? ""
            self.detailLabel.stringValue = NSLocalizedString("Drop Has No Images Detail Label", comment: "")
        case .InvalidDrop:
            self.pathLabel.stringValue   = NSLocalizedString("Invalid Drop", comment: "")
            self.detailLabel.stringValue = NSLocalizedString("Invalid Drop Detail Label", comment: "")
        case .PathNoLongerExists:
            self.dropImageView.image     = nil
            self.pathLabel.stringValue   = self.folderPath ?? "Directory no longer exists"
            self.detailLabel.stringValue = NSLocalizedString("Directory No Longer Exists Detail Label", comment: "")
        }
    }
    
}


// MARK:- ScriptSourcePath Delegate
extension FileDropViewController: ScriptSourcePathDelegate {
    
    var sourcePath: String? {
        get {
            if let sourcePath = self.folderPath {
                return sourcePath + "/"
            } else {
                return self.folderPath
            }
        }
    }
    
    func hasValidSourceProject() -> Bool {
        return (self.folderPath? != nil) ? PathValidator.directoryContainsImages(path: self.folderPath!) : false
    }
}


// MARK: - DropViewDelegate required functions.
extension FileDropViewController: DropViewDelegate {
    
    func dropViewShouldAcceptDraggedPath(dropView: DropView, paths: [String]) -> Bool {
        let pathname = paths[0]
        return PathValidator.directoryExists(path: pathname)
    }
    
    func dropViewDidDropFileToView(dropView: DropView, filePath: String) {
        let old = self.folderPath
        self.folderPath = filePath
        if PathValidator.directoryContainsImages(path: filePath) {
            self.updateDropView(state: DropViewState.SuccessfulDrop)
        } else {
            self.updateDropView(state: DropViewState.SuccessfulButEmptyDrop)
        }
        
        self.directoryObserver.observeSource(filePath)
        self.delegate?.fileDropControllerDidSetSourcePath(self,path: self.folderPath!, previousPath: old)
    }
    
    
    func dropViewDidDragValidFileIntoView(dropView: DropView) {
        if !self.hasValidSourceProject() {
            self.updateDropView(state: DropViewState.Hovering)
        }
    }
    
    func dropViewDidDragInvalidFileIntoView(dropView: DropView) {
        self.updateDropView(state: DropViewState.InvalidDrop)
    }
    
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        if !self.hasValidSourceProject() {
            self.updateDropView(state: DropViewState.Initial)
        } else {
            self.updateDropView(state: DropViewState.SuccessfulDrop)
        }
    }
}


extension FileDropViewController: FileSystemObserverDelegate {

    func FileSystemDirectoryDeleted(path: String!) {
        self.updateDropView(state: DropViewState.PathNoLongerExists)
        self.directoryObserver.stopObservingPath(path)
        self.folderPath = nil
        self.delegate?.fileDropControllerDidRemoveSourcePath(self, removedPath: path)
    }
    
    
    func FileSystemDirectory(oldPath: String!, renamedTo newPath: String!) {
        self.directoryObserver.updatePathForObserver(oldPath: oldPath, newPath: newPath)
        self.folderPath = newPath
        self.updateDropView(state: DropViewState.SuccessfulDrop)
    }
    
    func FileSystemDirectoryError(error: NSError!) {
        // TODO:
    }
}
