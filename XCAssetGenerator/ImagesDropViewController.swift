//
//  ImagesDropViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/11/15.
//  Copyright (c) 2015 Pranav Shah. All rights reserved.
//

import Foundation
import Cocoa
import ReactiveCocoa

/// TODO:
/// Replace the DropView delegate with somehting signal based.
/// Have the backgorund color changes be observer based. Observe Path and change directly
/// Maybe even have the backgorund color observe the drag and dorp state and change accordingly.

class ImagesDropViewController: NSViewController, DropViewDelegate {
 
    @IBOutlet var dropView: RoundedDropView!
    var dropImageView: NSImageView!
    var well: NSImageView!
    var label: NSTextField!
    var viewModel: ImagesGroupViewModel!
    
    static func instantiate(viewModel: ImagesGroupViewModel) -> ImagesDropViewController  {
        let controller = NSStoryboard(name: "Main", bundle: nil)?.instantiateControllerWithIdentifier("ImagesDroppa") as! ImagesDropViewController
        controller.viewModel = viewModel
        controller.setup()
        return controller
    }
    
    func setup() {
        view.wantsLayer = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Intialize RoundedDropView
        dropView.translatesAutoresizingMaskIntoConstraints = false
        dropView.delegate = self
        dropView.layer?.borderWidth = 3
        dropView.layer?.backgroundColor = NSColor.redColor().CGColor
        let fillDropView = NSLayoutConstraint.centeringConstraints(dropView, into: view, size: NSSize(width: 150, height: 150))
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
        label.stringValue = "Should not be this value"
        view.addSubview(label)
        let labelX  = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let labelY = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.6, constant: 0)
        
        NSLayoutConstraint.activateConstraints([labelX, labelY])
        
       
        
//        layoutUI(viewModel.currentPathValid())
        viewModel.currentPathValid.producer
            |> observeOn(QueueScheduler.mainQueueScheduler)
//            |> skip(1)
            |> start(next: { valid in
                println("IMAGESVC viewModel.Path chaned, updating UI")
                self.layoutUI(valid)
            })
        
        viewModel.label.producer
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> start(next: { label in
                self.label.stringValue = label
                println("ImagesDropViewController.label.stringValue = \(label)")
            })
//        self.dropView.layer?.backgroundColor = NSColor.greenColor().CGColor
        
//        if viewModel.currentPathValid() {
//            setupValidDrop()
//        } else {
//            dropView.layer?.borderColor = dropView.layer?.backgroundColor
//        }
    }
    
    func layoutUI(set: Bool) {
        dropView.layer?.borderColor = (set) ? NSColor.validDropColor().CGColor : NSColor(calibratedRed: 0.576 , green: 0.713, blue: 0.940, alpha: 1).CGColor
        dropView.layer?.backgroundColor = (set) ? NSColor.whiteColor().CGColor : NSColor.clearColor().CGColor
        well.hidden = set
        dropImageView.image = set ? self.viewModel.systemImageForCurrentPath() : nil
    }
    
    private func setupValidDrop() {
        layoutUI(true)
    }
    
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        if viewModel.isCurrentPathValid() {
            dropView.layer?.borderColor = NSColor.greenColor().CGColor
        } else {
            dropView.layer?.borderColor = dropView.layer?.backgroundColor
        }
    }
    
    func dropViewDidDragInvalidFileIntoView(dropView: DropView) {
        dropView.layer?.borderColor = NSColor.invalidDropColor().CGColor
    }
    
    func dropViewDidDragValidFileIntoView(dropView: DropView) {
        dropView.layer?.borderColor = NSColor.hoveringDropColor().CGColor
    }
    
    func dropViewDidDropFileToView(dropView: DropView, filePath: String) {
        viewModel.newPathSelected(filePath)
    }
    
    func dropViewShouldAcceptDraggedPath(dropView: DropView, paths: [String]) -> Bool {
        println(paths)
        return viewModel.shouldAcceptPath(paths[0])
    }
    
}

extension NSColor {
    static func validDropColor() -> NSColor {
        return NSColor(calibratedRed: 0.233, green: 0.819 , blue: 0.251, alpha: 1)
    }
    
    static func hoveringDropColor() -> NSColor {
        return NSColor(calibratedRed: 0.185, green: 0.390 , blue: 0.820, alpha: 1)
    }
    
    static func invalidDropColor() -> NSColor {
        return NSColor(calibratedRed: 0.986, green: 0 , blue: 0.093, alpha: 1)
    }
}
