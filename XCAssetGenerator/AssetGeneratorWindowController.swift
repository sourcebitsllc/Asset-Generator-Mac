//
//  AssetGeneratorWindowController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/15/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa

class AssetGeneratorWindowController: NSWindowController  {

    @IBOutlet var recentlyUsedProjectsDropdownList: ProgressPopUpButton!
    @IBOutlet var browseButton: NSButton!
    
    let generateButton: NSButton
    
    var scriptController: AssetGenerationController
    var fileDropController: FileDropViewController!
    var projectToolbarController: ProjectToolbarController!
    
    required init?(coder: NSCoder) {
        scriptController = AssetGenerationController()
        generateButton = NSButton()
        super.init(coder: coder)
    }
    
 
    override func windowDidLoad() {
        super.windowDidLoad()

        fileDropController = contentViewController as! FileDropViewController
        fileDropController.delegate = self
        
        projectToolbarController = ProjectToolbarController(recentList: recentlyUsedProjectsDropdownList)
        projectToolbarController.delegate = self
        
        scriptController.sourceDelegate = fileDropController
        scriptController.destinationDelegate = projectToolbarController
        scriptController.progressDelegate = self
        
        buttonSetup()
    }
    
    func buttonSetup() {
        // Generate button setup
        generateButton.font = browseButton.font // Brogramming (tm)
        generateButton.title = NSLocalizedString("Generate", comment: "")
        generateButton.state = 1
        generateButton.target = self
        generateButton.action = Selector("generateButtonPressed")
        generateButton.bordered = true
        generateButton.continuous = false
        generateButton.bezelStyle = NSBezelStyle.RoundedBezelStyle
        generateButton.transparent = false
        generateButton.autoresizesSubviews = true
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        
        generateButton.setButtonType(NSButtonType.MomentaryLightButton)
        updateGenerateButton()
        window!.contentView.addSubview(generateButton)
        
        let constraintH = NSLayoutConstraint.constraintsWithVisualFormat("H:[generateButton(buttonWidth)]-offsetLeft-|", options: nil, metrics: ["offsetLeft": 10,"buttonWidth": 90], views: ["generateButton": generateButton])
        let constraintV = NSLayoutConstraint.constraintsWithVisualFormat("V:[generateButton]-offsetBottom-|", options: nil, metrics: ["offsetBottom": 8], views: ["generateButton": generateButton])
        
        window?.contentView.addConstraints(constraintH)
        window?.contentView.addConstraints(constraintV)
    }
    
    func updateGenerateButton() {
        generateButton.enabled = scriptController.canExecuteScript()
    }
    
    
    // MARK:- IBAction outlets
    
    @IBAction func recentlyUsedProjectsDropdownListChanged(sender: ProgressPopUpButton!) {
        projectToolbarController.recentProjectsListChanged(sender)
    }
    
    // MARK - NSButton Callback Functions
    @IBAction func browseButtonPressed(sender: AnyObject!) {
        projectToolbarController.browseButtonPressed()
    }
    
    func generateButtonPressed() {
        // TODO: Options -> Pushed to 2.0
        var options : [AssetGenerationOptions]? = [AssetGenerationOptions]()
        scriptController.executeScript(options)
    }
}

extension AssetGeneratorWindowController: ProjectToolbarDelegate {
    func projectToolbarDidChangeProject(project: XCProject?) {
        if let project = project where !project.hasValidAssetsPath()  {
            // TODO:
        }
        updateGenerateButton()
    }
}

extension AssetGeneratorWindowController: FileDropControllerDelegate {
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController, removedPath: String) {
        updateGenerateButton()
    }
    
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController, path: Path, previousPath: String?) {
        if PathValidator.directoryContainsInvalidCharacters(path: path, options: nil) {
            // TODO:
        }
        updateGenerateButton()
    }
}

extension AssetGeneratorWindowController: AssetGeneratorProgessDelegate {
    func assetGenerationStarted() {
        updateGenerateButton()
    }
    
    func assetGenerationFinished() {
        projectToolbarController.setToolbarProgress(progress: 0)
        updateGenerateButton()
    }
    
    func assetGenerationOngoing(progress: Int) {
        projectToolbarController.setToolbarProgress(progress: CGFloat(progress))
    }
}
