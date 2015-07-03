//
//  ProjectDropViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/11/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import Cocoa
import ReactiveCocoa

// TODO: Find better way to incorporate VCs and VMs. Current workaround is making all properties mutable and unwrapped. Ew.

class ProjectDropViewController: NSViewController, DropViewDelegate {
    
    @IBOutlet var dropView: RoundedDropView!
    @IBOutlet var dropImageView: NSImageView!
    @IBOutlet var well: NSImageView!
    @IBOutlet var label: NSTextField!
    
    let viewModel: ProjectSelectionViewModel
    
    let borderWidth: CGFloat = 3
    
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
        dropView.layer?.borderWidth = borderWidth

        dropImageView.unregisterDraggedTypes() // otherwise, the subview will intercept the dropView calls.
        well.unregisterDraggedTypes()

        viewModel.label.producer
            |> start(next: { label in
               self.label.stringValue = label
            })

        viewModel.currentSelectionValid.producer
            |> on(next: { valid in
                self.layoutUI(valid) })
            |> start()
        
    }
    
    private func layoutUI(set: Bool) {
        dropView.layer?.borderColor = (set) ? NSColor.dropViewAcceptedColor().CGColor : NSColor(calibratedRed: 0.652 , green: 0.673, blue: 0.696, alpha: 1).CGColor
        dropView.layer?.backgroundColor = (set) ? NSColor.whiteColor().CGColor : NSColor.clearColor().CGColor
        well.hidden = set
        dropImageView.image = set ? self.viewModel.systemImageForCurrentPath() : nil
        dropImageView.alphaValue = set ? 1 : 0.5
    }
    
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        if viewModel.isCurrentSelectionValid() {
            dropView.layer?.borderColor = NSColor.dropViewAcceptedColor().CGColor
        } else {
            dropView.layer?.borderColor = NSColor(calibratedRed: 0.652 , green: 0.673, blue: 0.696, alpha: 1).CGColor
        }
    }
    
    func dropViewDidDragInvalidFileIntoView(dropView: DropView) {
        dropView.layer?.borderColor = NSColor.dropViewRejectedColor().CGColor
    }
    
    func dropViewDidDragValidFileIntoView(dropView: DropView) {
        dropView.layer?.borderColor = NSColor.dropViewHoveringColor().CGColor
    }
    
    func dropViewDidDropFileToView(dropView: DropView, paths: [Path]) {
        viewModel.newPathSelected(paths[0])
    }

    func dropViewShouldAcceptDraggedPath(dropView: DropView, paths: [String]) -> Bool {
        let valid = viewModel.shouldAcceptPath(paths)
        
        if !valid {
            let anim = CABasicAnimation.shakeAnimation(magnitude: 10)
            view.layer?.addAnimation(anim, forKey: "x")
        }
        return valid
    }
    
    func dropViewNumberOfAcceptableItems(dropView: DropView, items: [Path]) -> Int {
        return 1
    }
}

// MARK:- Right-click Menu setup
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
