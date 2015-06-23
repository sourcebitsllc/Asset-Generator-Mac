//
//  ImagesDropViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/11/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa
import ReactiveCocoa

// TODO: Find better way to incorporate VCs and VMs. Current workaround is making all properties mutable and unwrapped. Ew.

class ImagesDropViewController: NSViewController, DropViewDelegate {
 
    @IBOutlet var dropView: RoundedDropView!
    var dropImageView: NSImageView!
    var well: NSImageView!
    var label: NSTextField!
    var viewModel: ImagesGroupViewModel!
    
    static func instantiate(viewModel: ImagesGroupViewModel) -> ImagesDropViewController  {
        let controller = NSStoryboard(name: "Main", bundle: nil)?.instantiateControllerWithIdentifier("ImagesDroppa") as! ImagesDropViewController
        controller.viewModel = viewModel
        return controller
    }
    
    override func viewDidLoad() {
        view.wantsLayer = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Intialize RoundedDropView
        dropView.translatesAutoresizingMaskIntoConstraints = false
        dropView.delegate = self
        dropView.layer?.borderWidth = 3
        dropView.layer?.backgroundColor = NSColor.redColor().CGColor
        let fillDropView = NSLayoutConstraint.centeringConstraints(dropView, into: view, size: NSSize(width: 128, height: 128))
        NSLayoutConstraint.activateConstraints(fillDropView)
        
        // Initialize well
        well = NSImageView()
        well.image = NSImage(named: "uiWell")
        well.translatesAutoresizingMaskIntoConstraints = false
        well.unregisterDraggedTypes()
        view.addSubview(well)
        let centerWell = NSLayoutConstraint.centeringConstraints(well, into: view)
        NSLayoutConstraint.activateConstraints(centerWell)
        
        // Initialize ImageView representing the drop item.
        dropImageView = NSImageView()
        dropImageView.translatesAutoresizingMaskIntoConstraints = false
        dropImageView.unregisterDraggedTypes() // otherwise, the subview will intercept the dropView calls.
        view.addSubview(dropImageView)
        
        let centerImage = NSLayoutConstraint.centeringConstraints(dropImageView, into: view)
        NSLayoutConstraint.activateConstraints(centerImage)
        
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
        
        viewModel.currentSelectionValid.producer
            |> on(next: { valid in
                self.layoutUI(valid) })
            |> start()
        
        viewModel.label.producer
            |> on(next: { label in
                self.label.stringValue = label })
            |> start()
    }
    
    func layoutUI(set: Bool) {
        dropView.layer?.borderColor = (set) ? NSColor.dropViewAcceptedColor().CGColor : NSColor(calibratedRed: 0.576 , green: 0.713, blue: 0.940, alpha: 1).CGColor
        dropView.layer?.backgroundColor = (set) ? NSColor.whiteColor().CGColor : NSColor.clearColor().CGColor
        well.hidden = set
        dropImageView.image = set ? self.viewModel.systemImageForCurrentPath() : nil
    }
    
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        if viewModel.isCurrentSelectionValid() {
            dropView.layer?.borderColor = NSColor.dropViewAcceptedColor().CGColor
        } else {
            dropView.layer?.borderColor = NSColor(calibratedRed: 0.576 , green: 0.713, blue: 0.940, alpha: 1).CGColor
        }
    }
    
    func dropViewDidDragInvalidFileIntoView(dropView: DropView) {
        dropView.layer?.borderColor = NSColor.dropViewRejectedColor().CGColor
    }
    
    func dropViewDidDragValidFileIntoView(dropView: DropView) {
        dropView.layer?.borderColor = NSColor.dropViewHoveringColor().CGColor
    }
    
    func dropViewDidDropFileToView(dropView: DropView, paths: [Path]) {
        viewModel.newPathSelected(paths)
    }
    
    func dropViewShouldAcceptDraggedPath(dropView: DropView, paths: [Path]) -> Bool {
        let valid = viewModel.shouldAcceptSelection(paths)
        if !valid {
            let anim = CABasicAnimation(keyPath: "position.x")
            anim.duration = 0.05
            anim.repeatCount = 3
            anim.autoreverses = true
            anim.fromValue = view.frame.origin.x + 10
            anim.toValue = view.frame.origin.x - 10
            view.layer?.addAnimation(anim, forKey: "x")
        }
        return valid
    }
    
    func dropViewNumberOfAcceptableItems(dropView: DropView, items: [Path]) -> Int {
        return viewModel.acceptableItemsOfSelection(items)
    }
}