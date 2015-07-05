//
//  ProjectDropViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/11/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import ReactiveCocoa

class ProjectDropViewController: NSViewController {
    
    @IBOutlet var dropView: RoundedDropView!
    @IBOutlet var dropImageView: NSImageView!
    @IBOutlet var well: NSImageView!
    @IBOutlet var label: NSTextField!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    
    let viewModel: ProjectSelectionViewModel
    
    init?(viewModel: ProjectSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "ProjectDropView", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        dropView.delegate = self
        dropView.mouse = self

        dropImageView.unregisterDraggedTypes()
        well.unregisterDraggedTypes()

        viewModel.label.producer
            |> start(next: { label in
               self.label.stringValue = label
            })

        viewModel.currentSelectionValid.producer
            |> on(next: { valid in
                self.layoutUI(valid ? .Accepted : .None) })
            |> start()
        
    }
    
    private func layoutUI(state: DropState) {
        switch state {
        case .Hovering:
            dropView.animator().layer?.borderWidth = fat.border
            heightConstraint.constant = fat.width
            widthConstraint.constant = fat.width
            dropView.layer?.borderColor = NSColor.dropViewHoveringColor().CGColor
        case .Accepted:
            dropView.layer?.borderWidth = fat.border
            heightConstraint.constant = fat.width
            widthConstraint.constant = fat.width
            dropView.layer?.borderColor = NSColor.dropViewAcceptedColor().CGColor
            dropView.layer?.backgroundColor = NSColor.whiteColor().CGColor
            well.hidden = true
            dropImageView.image = self.viewModel.systemImageForCurrentPath()
        case .None:
            dropView.layer?.borderWidth = thin.border
            heightConstraint.constant = thin.width
            widthConstraint.constant = thin.width
            dropView.layer?.borderColor = NSColor(calibratedRed: 0.652 , green: 0.673, blue: 0.696, alpha: 1).CGColor
            dropView.layer?.backgroundColor = NSColor.clearColor().CGColor
            well.hidden = false
            dropImageView.image = nil
        case .Rejected:
            dropView.layer?.borderWidth = fat.border
            heightConstraint.constant = fat.width
            widthConstraint.constant = fat.width
            dropView.layer?.borderColor = NSColor.dropViewRejectedColor().CGColor
        }
    }
}

// MARK:- DropView drag delegate
extension ProjectDropViewController: DropViewDelegate {
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        viewModel.isCurrentSelectionValid() ? layoutUI(.Accepted) : layoutUI(.None)
    }
    
    func dropViewDidDragInvalidFileIntoView(dropView: DropView) {
        layoutUI(.Rejected)
        let anim = CABasicAnimation.shakeAnimation(magnitude: 10)
        view.layer?.addAnimation(anim, forKey: "x")
    }
    
    func dropViewDidDragValidFileIntoView(dropView: DropView) {
        layoutUI(.Hovering)
    }
    
    func dropViewDidDropFileToView(dropView: DropView, paths: [Path]) {
        viewModel.newPathSelected(paths[0])
    }
    
    func dropViewShouldAcceptDraggedPath(dropView: DropView, paths: [String]) -> Bool {
        return viewModel.shouldAcceptPath(paths)
    }
    
    func dropViewNumberOfAcceptableItems(dropView: DropView, items: [Path]) -> Int {
        return 1
    }
}

// MARK:- DropView mouse delegate
extension ProjectDropViewController: DropViewMouseDelegate {
    func dropViewDidRightClick(dropView: DropView, event: NSEvent) {
        let enabled = viewModel.isCurrentSelectionValid()

        let reveal = NSMenuItem(title: "Show in Finder", action:Selector("revealMenuPressed"), keyEquivalent: "")
        reveal.enabled = enabled
        
        let clear = NSMenuItem(title: "Clear Selection", action: Selector("clearMenuPressed"), keyEquivalent: "")
        clear.enabled = enabled
        
        let menu = NSMenu(title: "Asset Generator")
        menu.autoenablesItems = false
        menu.insertItem(reveal, atIndex: 0)
        menu.insertItem(clear, atIndex: 1)
        NSMenu.popUpContextMenu(menu, withEvent: event, forView: self.view)
    }
    
    func clearMenuPressed() {
        viewModel.clearSelection()
    }
    
    func revealMenuPressed() {
        if let item = viewModel.urlRepresentation() {
             NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([item])
        }
    }
}
