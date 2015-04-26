//
//  FileDropViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/11/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa

/// Derp
/// The animation code is rough to say the least.

protocol FileDropControllerDelegate {
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController, path: Path, previousPath: String?)
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController, removedPath: String)
}


class FileDropViewController: NSViewController {

    enum DropViewState {
        case Initial
        case Hovering
        case SuccessfulDrop
        case SuccessfulButEmptyDrop
        case InvalidDrop
        case PathNoLongerExists
        case Done(Int)
    }
    
    enum DropViewLabelPosition {
        case ExpandedLabels
        case CollapsedLabel
    }
    
    enum DropLabelAnimation {
        case Collapse
        case Expand
        case Inplace
    }
    
    @IBOutlet var dropView: DropView!
    
    var delegate: FileDropControllerDelegate?
    var directoryObserver: SourceObserver!
    
    var dropImageView: NSImageView!
    var pathLabel: NSTextField!
    var detailLabel: NSTextField!
    
    // Since the Path label does not move + im not removing it form subview. Why not just animate its alpha state only?
    /// Save yourself the shame of manipulating NSLayoutcontraints.
    var detailLabelInitialYPosition: NSLayoutConstraint!
    var detailLabelSecondaryYPosition: NSLayoutConstraint!
    
    private var folderPath : String?
    private var viewState: DropViewState // FUCK FUCK FUCK FUCK FUC KFUC FUC FUCK FU CU FUCK FUCK FUCKF FUCKF FUC FUKC 
    // FUCK FUC KF CUKC FUCK FUCK FUKC UFL FUCK FUCK FU C UF CUFK CU F KCYF CK FYF  UC DF CK
    private var currentViewState: DropViewState
    
    typealias Stage = () -> ()
    typealias AnimationStage = (NSAnimationContext) -> ()
    
    
    
    required init?(coder: NSCoder) {
        viewState = .Initial
        currentViewState = .Initial
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropView.delegate = self
    
        dropImageView = NSImageView()
        dropImageView.translatesAutoresizingMaskIntoConstraints = false
        dropImageView.unregisterDraggedTypes() // otherwise, the subview will intercept the dropView calls.
        dropView.addSubview(dropImageView)
        
        let centerImageX: NSLayoutConstraint = NSLayoutConstraint(item: dropImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
       
        let centerImageY: NSLayoutConstraint = NSLayoutConstraint(item: dropImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 0.8, constant: 0)
        
        NSLayoutConstraint.activateConstraints([centerImageX, centerImageY])
        
        pathLabel = NSTextField()
        pathLabel.translatesAutoresizingMaskIntoConstraints = false
        pathLabel.editable = false
        pathLabel.backgroundColor = NSColor.controlColor()
        pathLabel.bordered = false
        pathLabel.font = NSFont.systemFontOfSize(13)
        
        dropView.addSubview(pathLabel)
        
        let centerPathX  = NSLayoutConstraint(item: pathLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let centerPathY = NSLayoutConstraint(item: pathLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.45, constant: 0)
        
        detailLabel = NSTextField()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.editable = false
        detailLabel.textColor = NSColor.secondaryLabelColor()
        detailLabel.backgroundColor = NSColor.controlColor()
        detailLabel.bordered = false
        detailLabel.font = NSFont.systemFontOfSize(13)
        
        dropView.addSubview(detailLabel)
        
        let centerDetailX: NSLayoutConstraint = NSLayoutConstraint(item: detailLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        
        
        // Initialize state
        updateDropView(state: DropViewState.Initial)
        
        
        detailLabelInitialYPosition = NSLayoutConstraint(item: detailLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.44, constant: 0)
        detailLabelSecondaryYPosition = NSLayoutConstraint(item: detailLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: dropView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.59, constant: 0)

        NSLayoutConstraint.activateConstraints([centerPathX, centerPathY])
        NSLayoutConstraint.activateConstraints([centerDetailX, detailLabelInitialYPosition])
        
        directoryObserver = SourceObserver(delegate: self)
    }
    
    
    func updateDropView(#state: DropViewState) {
        var image: NSImage?
        var path: String?
        var detail: String
        
        switch state {
        case .Initial:
            image = NSImage(named: "DropfileInitialState")
            path  = nil
            detail = NSLocalizedString("Drop a folder with slices here.", comment: "")
        
        case .Hovering:
            image = NSImage(named: "DropfileHoverState")
            path = nil
            detail = NSLocalizedString("Drop a folder with slices here.", comment: "")
        
        case .SuccessfulDrop:
            image = NSImage(named: "DropfileSuccessState")
            path = self.folderPath?.lastPathComponent
            detail = NSLocalizedString("Hit Create button to add your slices to the project.", comment: "")

        case .SuccessfulButEmptyDrop:
            image = NSImage(named: "DropfileInitialState")
            path = folderPath?.lastPathComponent
            detail = NSLocalizedString("Drop a folder that contains slice-able images.", comment: "")
        
        case .InvalidDrop:
            image = NSImage(named: "DropfileInitialState")
            path = nil
            detail = NSLocalizedString("Drop a folder that contains slice-able images.", comment: "")
        
        case .PathNoLongerExists:
            image = nil
            path = folderPath
            detail = NSLocalizedString("Seems like your folder has disappeared! Select it again.", comment: "")
        
        case .Done(let amount):
            image = NSImage(named: "DropfileDoneState")
            path = folderPath?.lastPathComponent
            detail = pluralize(amount, singular: "slice", plural: "slices") + " added to the project"
        }
        
        let trigger: Stage = {
            self.dropImageView.image = image;
            self.detailLabel.stringValue = detail
            
            if let path = path {
               self.pathLabel.stringValue = path
            }
        }
        
        let animation = retaculateAnimation(from: currentViewState, to: state)
        performTransition(animation, with: trigger)
        
        currentViewState = state
        
    }
    
    
    private func labelPosition(#state: DropViewState) -> DropViewLabelPosition {
        switch state {
        case .SuccessfulDrop, .SuccessfulButEmptyDrop, .PathNoLongerExists, .Done:
            return .ExpandedLabels
        case .Initial, .Hovering, .InvalidDrop:
            return .CollapsedLabel
        }
    }
    
    private func transitionStyle(from: DropViewLabelPosition, to: DropViewLabelPosition) -> DropLabelAnimation {
        switch (from, to) {
        case (.CollapsedLabel, .ExpandedLabels):
            return .Expand
        case (.ExpandedLabels, .CollapsedLabel):
            return .Collapse
        case (_, _):
            return .Inplace
        }
    }
    
    func retaculateAnimation(#from: DropViewState, to: DropViewState) -> DropLabelAnimation {
        let fromLabel = labelPosition(state: from)
        let toLabel = labelPosition(state: to)
        
        return transitionStyle(fromLabel, to: toLabel)
    }
    
    
    func performTransition(animation: DropLabelAnimation, with trigger: Stage) {
        switch animation {
        case .Expand:
            transitionToTwoLabels(trigger)
        case .Collapse:
            transitionToOneLabel(trigger)
        case .Inplace:
             trigger()
        }
    }


    ///
    /// Do a step-by-step documentation of each step and why its there.
    /// Seems to be a trial and error approach.
    ///
    
    func transitionToTwoLabels(trigger: Stage) {
        let u  = trigger

        let s: AnimationStage = { context in
            self.pathLabel.alphaValue = 0
        }
        
        let c: Stage = {
            self.detailLabelInitialYPosition.active = false
            self.detailLabelSecondaryYPosition.active = true
        }
        
        let d: AnimationStage = { context in
            self.pathLabel.animator().alphaValue = 1
        }
        
        animate(prepare: u, firstStage: s, preSecondStage: c, secondStage: d)
    }
    
    func transitionToOneLabel(trigger: Stage) {
        let u  = trigger
        
        let c: Stage = {
            self.detailLabelSecondaryYPosition.active = false
            self.detailLabelInitialYPosition.active = true
        }
        
        let d: AnimationStage = { context in
            context.duration = 0.3
            self.pathLabel.animator().alphaValue = 0
        }
        
        animate(prepare: u, firstStage: nil, preSecondStage: c, secondStage: d)
    }
    
    ///
    /// This makes no sense whatsoever. I wrote it in hope of writing it once and never having to return to it again.
    ///
    
    private func animate(#prepare: Stage, firstStage: AnimationStage?, preSecondStage: Stage?, secondStage: AnimationStage?, completion: Stage? = nil) {
        
        // Make sure all previous changes are commited.
        self.dropView.layoutSubtreeIfNeeded()
        
        prepare()
        
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> () in
            if let firstStage = firstStage { firstStage(context) }
            
            }, completionHandler: {
            
                if let preSecondStage = preSecondStage { preSecondStage() }
                NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
                    context.allowsImplicitAnimation = true
                    
                    if let secondStage = secondStage { secondStage(context) }
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
            updateDropView(state: DropViewState.Initial) // Bug. We should return the previous state. The previous state, however, needs to ignore .Hovering
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
