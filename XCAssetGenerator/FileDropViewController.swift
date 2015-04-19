//
//  FileDropViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/11/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa

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
    case Done(Int)
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
        dropView.delegate = self
    
        dropImageView = NSImageView()
        dropImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dropImageView.unregisterDraggedTypes() // otherwise, the subview will intercept the dropView calls.
        updateDropView(state: DropViewState.Initial)
        
        dropView.addSubview(dropImageView)
        
        let centerX: NSLayoutConstraint = NSLayoutConstraint(item: dropImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
       
        let centerY: NSLayoutConstraint = NSLayoutConstraint(item: dropImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 0.8, constant: 0)
        
        dropView.addConstraint(centerX)
        dropView.addConstraint(centerY)
//        dropView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(imageWidth)]", options: nil, metrics: ["imageWidth": 150], views: ["imageView": dropImageView]))
//         dropView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView(imageHeight)]", options: nil, metrics: ["imageHeight": 150], views: ["imageView": dropImageView]))
        
        
        directoryObserver = SourceObserver(delegate: self)
    }
    
    
    func updateDropView(#state: DropViewState) {
        switch state {
        case .Initial:
            dropImageView.image     = NSImage(named: "DropfileInitialState")
            detailLabel.stringValue = NSLocalizedString("Drop a folder with slices here.", comment: "")
        case .Hovering:
            dropImageView.image     = NSImage(named: "DropfileHoverState")
        case .SuccessfulDrop:
            dropImageView.image     = NSImage(named: "DropfileSuccessState")
            pathLabel.stringValue   = folderPath?.lastPathComponent ?? ""
            detailLabel.stringValue = NSLocalizedString("Hit Create button to add your slices to the project.", comment: "")
        case .SuccessfulButEmptyDrop:
            dropImageView.image     = NSImage(named: "DropfileInitialState")
            pathLabel.stringValue   = folderPath?.lastPathComponent ?? ""
            detailLabel.stringValue = NSLocalizedString("Drop a folder that contains slice-able images.", comment: "")
        case .InvalidDrop:
            detailLabel.stringValue = NSLocalizedString("Drop a folder that contains slice-able images.", comment: "")
        case .PathNoLongerExists:
            dropImageView.image     = nil
            pathLabel.stringValue   = folderPath ?? ""
            detailLabel.stringValue = NSLocalizedString("Seems like your folder has disappeared! Select it again.", comment: "")
        case .Done(let amount):
            dropImageView.image     = NSImage(named: "DropfileDoneState")
            detailLabel.stringValue = pluralize(amount, singular: "slice", plural: "slices") + " added to the project"
        }
    }
    
    func displayDoneState(total: Int) {
        updateDropView(state: .Done(total))
    }
    
    private func pluralize(amount: Int, singular: String, plural: String) -> String {
        switch amount {
        case 0:
            return "No \(plural)"
        case 1:
            return "1 \(singular)"
        case let a:
            return "\(a) \(plural)"
        }
    }
}


// MARK:- ScriptSourcePath Delegate
extension FileDropViewController: AssetGeneratorSource {
    
    var sourcePath: String? {
        get {
            if let sourcePath = folderPath {
                return sourcePath + "/"
            } else {
                return folderPath
            }
        }
    }
    
    func hasValidSourceProject() -> Bool {
        return (folderPath != nil) ? PathValidator.directoryContainsImages(path: folderPath!) : false
    }
}


// MARK: - DropViewDelegate required functions.
extension FileDropViewController: DropViewDelegate {
    
    func dropViewShouldAcceptDraggedPath(dropView: DropView, paths: [String]) -> Bool {
        let pathname = paths[0]
        return PathValidator.directoryExists(path: pathname)
    }
    
    func dropViewDidDropFileToView(dropView: DropView, filePath: String) {
        let old = folderPath
        folderPath = filePath
        if PathValidator.directoryContainsImages(path: filePath) {
            updateDropView(state: DropViewState.SuccessfulDrop)
        } else {
            updateDropView(state: DropViewState.SuccessfulButEmptyDrop)
        }
        
        directoryObserver.observeSource(filePath)
        delegate?.fileDropControllerDidSetSourcePath(self,path: folderPath!, previousPath: old)
    }
    
    
    func dropViewDidDragValidFileIntoView(dropView: DropView) {
        if !hasValidSourceProject() {
            updateDropView(state: DropViewState.Hovering)
        }
    }
    
    func dropViewDidDragInvalidFileIntoView(dropView: DropView) {
        updateDropView(state: DropViewState.InvalidDrop)
    }
    
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        if !hasValidSourceProject() {
            updateDropView(state: DropViewState.Initial)
        } else {
            updateDropView(state: DropViewState.SuccessfulDrop)
        }
    }
}


extension FileDropViewController: FileSystemObserverDelegate {

    func FileSystemDirectoryDeleted(path: String!) {
        updateDropView(state: DropViewState.PathNoLongerExists)
        directoryObserver.stopObservingPath(path)
        folderPath = nil
        delegate?.fileDropControllerDidRemoveSourcePath(self, removedPath: path)
    }
    
    
    func FileSystemDirectory(oldPath: String!, renamedTo newPath: String!) {
        directoryObserver.updatePathForObserver(oldPath: oldPath, newPath: newPath)
        folderPath = newPath
        updateDropView(state: DropViewState.SuccessfulDrop)
    }
    
    func FileSystemDirectoryError(error: NSError!) {
        // TODO:
    }
}
