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

// TODO: Find better way to incorporate VCs and VMs

class ProjectDropViewController: NSViewController, DropViewDelegate {
    
    @IBOutlet var dropView: RoundedDropView!
    var dropImageView: NSImageView!
    var well: NSImageView!
    var label: NSTextField!
    var viewModel: SelectedProjectViewModel!
    
    let borderWidth: CGFloat = 3
    
    static func instantiate(viewModel: SelectedProjectViewModel) -> ProjectDropViewController {
        let controller = NSStoryboard(name: "Main", bundle: nil)!.instantiateControllerWithIdentifier("ProjectDroppa") as! ProjectDropViewController
        controller.viewModel = viewModel
        controller.setup()
        return controller
    }
    
    func setup() {
        self.view.wantsLayer = true

        // Intialize RoundedDropView
        dropView.translatesAutoresizingMaskIntoConstraints = false
        dropView.delegate = self
        dropView.layer?.borderWidth = borderWidth
        
        let fillDropView = NSLayoutConstraint.centeringConstraints(dropView, into: view, size: NSSize(width: 125+borderWidth, height: 125 + borderWidth))
        NSLayoutConstraint.activateConstraints(fillDropView)

        // Initialize ImageView representing the drop item.
        dropImageView = NSImageView()
        dropImageView.translatesAutoresizingMaskIntoConstraints = false
        dropImageView.unregisterDraggedTypes() // otherwise, the subview will intercept the dropView calls.
        view.addSubview(dropImageView)
        
        let centerImage = NSLayoutConstraint.centeringConstraints(dropImageView, into: view)
        NSLayoutConstraint.activateConstraints(centerImage)
        
        // Initialize well
        well = NSImageView()
        well.image = NSImage(named: "uiWell")
        well.translatesAutoresizingMaskIntoConstraints = false
        well.unregisterDraggedTypes()
        view.addSubview(well)
        let centerWell = NSLayoutConstraint.centeringConstraints(well, into: view)
        NSLayoutConstraint.activateConstraints(centerWell)
        
        label = NSTextField()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.editable = false
        label.backgroundColor = NSColor.controlColor()
        label.bordered = false
        label.alignment = .CenterTextAlignment
        label.font = NSFont.systemFontOfSize(13)
        view.addSubview(label)
        let labelX  = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let labelY = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.6, constant: 0)
        
        NSLayoutConstraint.activateConstraints([labelX, labelY])
        
        viewModel.label.producer
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> start(next: { label in
                self.label.stringValue = label
            })
        
        viewModel.currentSelectionValid.producer
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> on(next: { valid in
                self.layoutUI(valid) })
            |> start()
    }
    
    private func layoutUI(set: Bool) {
        dropView.layer?.borderColor = (set) ? NSColor.dropViewAcceptedColor().CGColor : NSColor(calibratedRed: 0.576 , green: 0.713, blue: 0.940, alpha: 1).CGColor
        dropView.layer?.backgroundColor = (set) ? NSColor.whiteColor().CGColor : NSColor.clearColor().CGColor
        well.hidden = set
        dropImageView.image = set ? self.viewModel.systemImageForCurrentPath() : nil
        dropImageView.alphaValue = set ? 1 : 0.5
    
    }
    
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        if viewModel.isCurrentSelectionValid() {
            dropView.layer?.borderColor = NSColor.dropViewAcceptedColor().CGColor
        } else {
            dropView.layer?.borderColor = dropView.layer?.backgroundColor
        }
    }
    
    func dropViewDidDragInvalidFileIntoView(dropView: DropView) {
        dropView.layer?.borderColor = NSColor.dropViewRejectedColor().CGColor
    }
    
    func dropViewDidDragValidFileIntoView(dropView: DropView) {
        dropView.layer?.borderColor = NSColor.dropViewHoveringColor().CGColor
    }
    
    func dropViewDidDropFileToView(dropView: DropView, filePath: String) {
        viewModel.newPathSelected(filePath)
    }
    
    func dropViewShouldAcceptDraggedPath(dropView: DropView, paths: [String]) -> Bool {
        return viewModel.shouldAcceptPath(paths[0])
    }
}
