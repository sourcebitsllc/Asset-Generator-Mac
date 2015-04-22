//
//  FileDropViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/11/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa

/// Derp
/// The animation code here makes absolutely no sense whatsoever. Which evidently is the only viable state
/// in leui of using AutoLayout + CoreAnimation

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
    
    var delegate: FileDropControllerDelegate?
    var directoryObserver: SourceObserver!
    
    var dropImageView: NSImageView!
    var pathLabel: NSTextField!
    var detailLabel: NSTextField!
    
    var pathLabelYPosition: NSLayoutConstraint!
    var detailLabelInitialYPosition: NSLayoutConstraint!
    var detailLabelSecondaryYPosition: NSLayoutConstraint!

    private var folderPath : String?
    private var viewState: DropViewState // FUCK FUCK FUCK FUCK FUC KFUC FUC FUCK FU CU FUCK FUCK FUCKF FUCKF FUC FUKC 
    // FUCK FUC KF CUKC FUCK FUCK FUKC UFL FUCK FUCK FU C UF CUFK CU F KCYF CK FYF  UC DF CK
    
    typealias Trigger = () -> ()
    
    required init?(coder: NSCoder) {
        viewState = .Initial
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropView.delegate = self
    
        dropImageView = NSImageView()
        dropImageView.translatesAutoresizingMaskIntoConstraints = false
        dropImageView.unregisterDraggedTypes() // otherwise, the subview will intercept the dropView calls.
        dropView.addSubview(dropImageView)
        
        let centerX: NSLayoutConstraint = NSLayoutConstraint(item: dropImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
       
        let centerY: NSLayoutConstraint = NSLayoutConstraint(item: dropImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 0.8, constant: 0)
        
        NSLayoutConstraint.activateConstraints([centerX, centerY])
//        dropView.addConstraint(centerX)
//        dropView.addConstraint(centerY)
//        dropView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(imageWidth)]", options: nil, metrics: ["imageWidth": 150], views: ["imageView": dropImageView]))
//         dropView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView(imageHeight)]", options: nil, metrics: ["imageHeight": 150], views: ["imageView": dropImageView]))
        
        directoryObserver = SourceObserver(delegate: self)
        
        pathLabel = NSTextField()
        pathLabel.translatesAutoresizingMaskIntoConstraints = false
        pathLabel.editable = false
        pathLabel.backgroundColor = NSColor.controlColor()
        pathLabel.bordered = false
        pathLabel.font = NSFont.systemFontOfSize(13)
        
        dropView.addSubview(pathLabel)
        
        let center1X: NSLayoutConstraint = NSLayoutConstraint(item: pathLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        
        
        detailLabel = NSTextField()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.stringValue = "Drop a folder with slices here."
        detailLabel.editable = false
        detailLabel.textColor = NSColor.secondaryLabelColor()
        detailLabel.backgroundColor = NSColor.controlColor()
        detailLabel.bordered = false
        detailLabel.font = NSFont.systemFontOfSize(13)
        
        dropView.addSubview(detailLabel)
        
        let center2X: NSLayoutConstraint = NSLayoutConstraint(item: detailLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        
        
        
        // Initialize state
        updateDropView(state: DropViewState.Initial)
        
        pathLabelYPosition = NSLayoutConstraint(item: pathLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.45, constant: 0)
        detailLabelInitialYPosition = NSLayoutConstraint(item: detailLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.44, constant: 0)
        detailLabelSecondaryYPosition = NSLayoutConstraint(item: detailLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.59, constant: 0)

        NSLayoutConstraint.activateConstraints([center1X])
        NSLayoutConstraint.activateConstraints([center2X, detailLabelInitialYPosition])
        
    }
    
    
    func updateDropView(#state: DropViewState) {
        
        switch state {
        case .Initial:
            dropImageView.image     = NSImage(named: "DropfileInitialState")
            detailLabel.stringValue = NSLocalizedString("Drop a folder with slices here.", comment: "")
            viewState = state
        case .Hovering:
            dropImageView.image     = NSImage(named: "DropfileHoverState")
        case .SuccessfulDrop:
            dropImageView.image     = NSImage(named: "DropfileSuccessState")
            retaculateAnimation(viewState, to: state)
            viewState = state
            // Make sure all changes are commited.
//            self.dropView.layoutSubtreeIfNeeded()
//            
//            NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> () in
//                
//                self.pathLabel.stringValue   = self.folderPath?.lastPathComponent ?? ""
//                self.detailLabel.stringValue = NSLocalizedString("Hit Create button to add your slices to the project.", comment: "")
//                self.pathLabelYPosition.active = true
//                self.pathLabel.alphaValue = 0
//                
//                
//                }, completionHandler: {
//                    self.detailLabelInitialYPosition.active = false
//                    self.detailLabelSecondaryYPosition.active = true
//
//                    NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
//                        context.duration = 0.25
//                        context.allowsImplicitAnimation = true
//                        
//                        self.pathLabel.animator().alphaValue = 1 // This cna be moved up since all the animations will have the same duration basically.
//                        self.dropView.layoutSubtreeIfNeeded()
//                        }, completionHandler: nil)
//            })
           

        case .SuccessfulButEmptyDrop:
            dropImageView.image     = NSImage(named: "DropfileInitialState")
//            pathLabel.stringValue   = folderPath?.lastPathComponent ?? ""
//            detailLabel.stringValue = NSLocalizedString("Drop a folder that contains slice-able images.", comment: "")
            retaculateAnimation(viewState, to: state)
            viewState = state
        case .InvalidDrop:
            dropImageView.image     = NSImage(named: "DropfileInitialState")
            detailLabel.stringValue = NSLocalizedString("Drop a folder that contains slice-able images.", comment: "")
            retaculateAnimation(viewState, to: state)
            viewState = state
        case .PathNoLongerExists:
            dropImageView.image     = nil
            pathLabel.stringValue   = folderPath ?? ""
            detailLabel.stringValue = NSLocalizedString("Seems like your folder has disappeared! Select it again.", comment: "")
            viewState = state
        case .Done(let amount):
            dropImageView.image     = NSImage(named: "DropfileDoneState")
            detailLabel.stringValue = pluralize(amount, singular: "slice", plural: "slices") + " added to the project"
            viewState = state
        }
        
        
        
    }
    
    func retaculateAnimation(from: DropViewState, to: DropViewState) {
        switch (from, to) {
        case (.Initial, .SuccessfulDrop) :
            fallthrough
        case (.InvalidDrop, .SuccessfulDrop):
            let detail = NSLocalizedString("Hit Create button to add your slices to the project.", comment: "")
            transitionToSuccess(detail, animated: true)
        case (_, .SuccessfulDrop):
            let detail = NSLocalizedString("Hit Create button to add your slices to the project.", comment: "")
            transitionToSuccess(detail, animated: false)
        case (.Initial, .SuccessfulButEmptyDrop):
            let detail = NSLocalizedString("Drop a folder that contains slice-able images.", comment: "")
            transitionToSuccess(detail, animated: true)
        case (_, .InvalidDrop):
            let detail = NSLocalizedString("Drop a folder that contains slice-able images.", comment: "")
            transitionToInvalid(detail, animated: true)
        case (_,_):
            break
        }
    }
    
    
    func transitionToInvalid(detail: String, animated: Bool) {
        let u: () -> () = {
            self.detailLabel.stringValue = detail

//            self.pathLabel.stringValue   = self.folderPath?.lastPathComponent ?? ""
        }
        
        var s: Trigger?
        var c: Trigger?
        if animated {
            s = {
                self.pathLabel.alphaValue = 0
                self.pathLabelYPosition.active = false
                self.detailLabelSecondaryYPosition.active = false
            }
            
            c = {
                
                self.detailLabelInitialYPosition.active = true
//                self.pathLabel.animator().alphaValue = 0
            }
        }
        
        animate(update: u, stage: s, commit: c)
    }
    func transitionToSuccess(detail: String, animated: Bool) {
        let u: () -> () = {
            self.detailLabel.stringValue = detail
            self.pathLabel.stringValue   = self.folderPath?.lastPathComponent ?? ""
        }
        
        var s: Trigger?
        var c: Trigger?
        if animated {
            s = {
                self.pathLabel.alphaValue = 0
                self.pathLabelYPosition.active = true
            }
            
            c = {
                self.detailLabelInitialYPosition.active = false
                self.detailLabelSecondaryYPosition.active = true
                self.pathLabel.animator().alphaValue = 1
            }
        }
        
        animate(update: u, stage: s, commit: c)
    }
    
    ///
    /// This makes no sense whatsoever. I wrote it in hope of writing it once and never having to return to it again.
    ///
    func animate(#update: Trigger,stage: Trigger?, commit: Trigger?, completion: (() -> ())? = nil) {
        // Make sure all previous changes are commited.
        self.dropView.layoutSubtreeIfNeeded()
        update()
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> () in
            
            if let stage = stage { stage() }
            }, completionHandler: {
                if let commit = commit { commit() }
                NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
//                    context.duration = 10
                    context.duration = 0.5
                    context.allowsImplicitAnimation = true
                    self.dropView.layoutSubtreeIfNeeded()
                    }, completionHandler: completion)
        })
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
            updateDropView(state: viewState) // Bug
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
