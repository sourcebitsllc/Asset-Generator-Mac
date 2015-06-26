//
//  AssetGeneratorWindowController.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/11/15.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa
import ReactiveCocoa

class AssetGeneratorWindowController: NSWindowController {

    var statusLabel: NSTextField!
    @IBOutlet var generateButton: NSButton!
    
    var viewModel: AssetWindowViewModel!
    
    // MARK: ViewControllers. Btw, i dont need to reference them but they kinda make for a nice little documentation snippet.
    var progressController: ProgressViewController!
    var imagesViewController: ImagesDropViewController!
    var projectViewController: ProjectDropViewController!
    
    /// MARK: Initializers
    
    static func instantiate(viewModel: AssetWindowViewModel) -> AssetGeneratorWindowController {
        let controller = NSStoryboard(name: "Main", bundle: nil)!.instantiateControllerWithIdentifier("MainWindowController") as! AssetGeneratorWindowController
        controller.viewModel = viewModel
        controller.setup()
        return controller
    }
    
    /// MARK:- Setup Methods.
    
    func setup() {
        super.windowDidLoad()

        layoutVibrancy()
        layoutTopbarElements()
        layoutSeperator()
        
        // Bottom bar and status label.
        layoutBottomElements()
        
        createImagesArea()
        createProjectArea()
        
        // RAC Binding.
        viewModel.canGenerate.producer
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> start(next: { enabled in
                self.generateButton.enabled = enabled
        })
        
        viewModel.statusLabel.producer
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> start(next: { label in
                self.statusLabel.stringValue = label
        })
                
        viewModel.generateTitle.producer
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> start(next: { title in
                self.generateButton.title = title
        })

    }

    @IBAction func generateButtonPressed(sneder: AnyObject!) {
        // TODO: Options -> Pushed to 2.0
        viewModel.generateAssets()
    }
    
    /// MARK:- UI Setup Helpers.
    
    private func createImagesArea() {
        let imagesViewModel = viewModel.viewModelForImagesGroup()
        imagesViewController = ImagesDropViewController.instantiate(imagesViewModel)
        imagesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        contentViewController?.view.addSubview(imagesViewController.view)
        //
        let centerFileX = NSLayoutConstraint(item: imagesViewController.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: contentViewController?.view, attribute: NSLayoutAttribute.CenterX, multiplier: 0.5, constant: 0)
        let centerFileY = NSLayoutConstraint(item: imagesViewController.view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: contentViewController?.view, attribute: NSLayoutAttribute.CenterY, multiplier: 0.8, constant: 0)
        let widthFile = NSLayoutConstraint(item: imagesViewController.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: contentViewController?.view, attribute: NSLayoutAttribute.Width, multiplier: 0.5, constant: 0)
        let heightFile = NSLayoutConstraint(item: imagesViewController.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: contentViewController?.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([centerFileX, centerFileY, widthFile, heightFile])
    }
    
    private func createProjectArea() {
        let projectViewModel = viewModel.viewModelForSelectedProject()
        projectViewController = ProjectDropViewController.instantiate(projectViewModel)
//        projectViewController = ProjectDropViewController(viewModel: projectViewModel)
        projectViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentViewController?.view.addSubview(projectViewController.view)
        
        let centerProjX = NSLayoutConstraint(item: projectViewController.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: contentViewController?.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.5, constant: 0)
        let centerProjY = NSLayoutConstraint(item: projectViewController.view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: contentViewController?.view, attribute: NSLayoutAttribute.CenterY, multiplier: 0.8, constant: 0)
        let widthProj = NSLayoutConstraint(item: projectViewController.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: contentViewController?.view, attribute: NSLayoutAttribute.Width, multiplier: 0.5, constant: 0)
        let heightProj = NSLayoutConstraint(item: projectViewController.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: contentViewController?.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([centerProjX, centerProjY, widthProj, heightProj])
    }
    
    private func layoutTopbarElements() {
        window!.titleVisibility = NSWindowTitleVisibility.Hidden
        
        // Progress bar.
        let progressViewModel = viewModel.viewModelForProgressIndication()
        progressController = ProgressViewController(viewModel: progressViewModel, width: window!.frame.width)
        self.window?.standardWindowButton(NSWindowButton.CloseButton)?.superview?.addSubview(progressController.view)
        
        // Faux Title.
        let title = setupLabel("Asset Generator")
        title.translatesAutoresizingMaskIntoConstraints = false
        self.window?.standardWindowButton(NSWindowButton.CloseButton)?.superview?.addSubview(title) // I... sigh.
        let titleConstraints = NSLayoutConstraint.centeringConstraints(title, into: title.superview)
        NSLayoutConstraint.activateConstraints(titleConstraints)
    }
    
    private func layoutBottomElements() {
        // Bottom translucent bar.
        let bar = NSImage(named: "uiBottomBar")
        let bottomBar = NSImageView()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.image = bar
        contentViewController?.view.addSubview(bottomBar)
        
        // Status label.
        statusLabel = setupLabel("Drop a folder with slices you'd like to add to your Xcode project")
        statusLabel.textColor = NSColor(calibratedWhite: 0.4, alpha: 1)
        bottomBar.addSubview(statusLabel)
        
        let posStatusX  = NSLayoutConstraint(item: statusLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: statusLabel.superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let posStatusY = NSLayoutConstraint(item: statusLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: statusLabel.superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1.1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([posStatusX, posStatusY])
    }
    
    /// MARK: Visual layout.
    
    private func layoutVibrancy() {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = NSVisualEffectMaterial.Titlebar
        visualEffectView.blendingMode = NSVisualEffectBlendingMode.BehindWindow
        visualEffectView.state = NSVisualEffectState.Active
        visualEffectView.wantsLayer = true
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        contentViewController?.view.addSubview(visualEffectView)
        let vibrancyConstraints = NSLayoutConstraint.fittingConstraints(visualEffectView, into: contentViewController?.view)
        NSLayoutConstraint.activateConstraints(vibrancyConstraints)
    }
    
    private func layoutSeperator() {
        let seperatorView = NSImageView()
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        seperatorView.image = NSImage(named: "iconArrow")
        contentViewController?.view.addSubview(seperatorView)
        
        let centerSeperatorX: NSLayoutConstraint = NSLayoutConstraint(item: seperatorView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: seperatorView.superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        
        let centerSeperatorY: NSLayoutConstraint = NSLayoutConstraint(item: seperatorView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: seperatorView.superview, attribute: NSLayoutAttribute.CenterY, multiplier: 0.8, constant: 0)
        
        NSLayoutConstraint.activateConstraints([centerSeperatorX, centerSeperatorY])
    
    }
    
    // MARK:- Helpers
    private func setupLabel(string: String) -> NSTextField {
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.editable = false
        field.backgroundColor = NSColor.controlColor()
        field.bordered = false
        field.alignment = .CenterTextAlignment
        field.font = NSFont.systemFontOfSize(13)
        field.stringValue = string
        return field
    }
}

