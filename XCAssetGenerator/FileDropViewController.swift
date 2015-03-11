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
        
        // Observing the File System Setup.
        let sourceClosure: SourceObserver.SourceDirectoryObserverClosure = self.observerClosure()
        directoryObserver = SourceObserver(sourceObserver: sourceClosure)
    }
    
    
    func updateDropView(#state: DropViewState) {
        switch state {
        case .Initial:
            self.dropImageView.image     = NSImage(named: "DropfileInitialState")
            self.pathLabel.stringValue   = "Initial State"
            self.detailLabel.stringValue = "Initial Detail Label"
        case .Hovering:
            self.dropImageView.image     = NSImage(named: "DropfileHoverState")
            self.pathLabel.stringValue   = "Hovering State"
            self.detailLabel.stringValue = "Hovering Detail Label"
        case .SuccessfulDrop:
            self.dropImageView.image     = NSImage(named: "DropfileSuccessState")
            self.pathLabel.stringValue   = self.folderPath?.lastPathComponent ?? ""
            self.detailLabel.stringValue = "Successful Drop Detail Label"
        case .SuccessfulButEmptyDrop:
            self.dropImageView.image     = NSImage(named: "DropfileInitialState")
            self.pathLabel.stringValue   = self.folderPath?.lastPathComponent ?? ""
            self.detailLabel.stringValue = "Directory does not contian any images"
        case .InvalidDrop:
            self.pathLabel.stringValue   = "Invalid Drop"
            self.detailLabel.stringValue = "Invalid Drop Detail Label"
        case .PathNoLongerExists:
            self.dropImageView.image     = nil
            self.pathLabel.stringValue   = self.folderPath ?? "Directory no longer exists"
            self.detailLabel.stringValue = "Directory no longer exists Detail Label"
        }
    }
    
}


// MARK:- ScriptSourcePath Delegate
extension FileDropViewController: ScriptSourcePathDelegate {
    
    func sourcePath() -> String? {
        if let sourcePath = self.folderPath {
            return sourcePath + "/"
        } else {
            return self.folderPath
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

extension FileDropViewController {

    func observerClosure() -> SourceObserver.SourceDirectoryObserverClosure {
        return { (operation: FileSystemOperation, oldPath: String!, newPath: String!) -> Void in
            switch operation {
                
            case FileSystemOperation.DirectoryRenamed:
                
                // Stop observing the old path, and observe the new path using the same callback.
                self.directoryObserver.updatePathForObserver(oldPath: oldPath, newPath: newPath)
                
                // Set the new path and update the state.
                self.folderPath = newPath
                self.updateDropView(state: DropViewState.SuccessfulDrop)
                
            case FileSystemOperation.DirectoryDeleted:
                
                self.updateDropView(state: DropViewState.PathNoLongerExists)
                self.directoryObserver.stopObservingPath(oldPath)
                self.folderPath = nil
                self.delegate?.fileDropControllerDidRemoveSourcePath(self, removedPath: oldPath)
                
            case FileSystemOperation.DirectoryInitializationFailedAsPathDoesNotExist:
                println("Initialization failed cause the path we want to observe does not exist")
                
            case FileSystemOperation.DirectoryUnknownOperationForUnresolvedPath:
                println("We couldnt open the filde to process the change operation")
                
            default:
                break;
            }
            
        }
    }
}
