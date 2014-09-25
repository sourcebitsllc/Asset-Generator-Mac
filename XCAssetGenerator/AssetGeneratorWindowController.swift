//
//  AssetGeneratorWindowController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/15/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

// TODO: I still dont like how much resposibility the Window controller is carrying. Maybe i can move all the destination Protocol logic to its own container while maintaining Toolbar in window logic somehow?
// FIXME: This whole dump of a class.

class AssetGeneratorWindowController: NSWindowController, NSToolbarDelegate, ScriptParametersDelegate {

    @IBOutlet var recentlyUsedProjectsDropdownList: ProgressPopUpButton!
    @IBOutlet var browseButton: NSButton!
    
    var generateButton: NSButton
    
    var assetGeneratorController: AssetGeneratorViewController!
    
    // var generate1xButton
    
    
    required init(coder: NSCoder!) {
        generateButton = NSButton()
        super.init(coder: coder)
    }
    
 
    override func windowDidLoad() {
        super.windowDidLoad()
        self.assetGeneratorController = self.contentViewController as AssetGeneratorViewController
        self.assetGeneratorController.setRecentListDropdown(self.recentlyUsedProjectsDropdownList)
        self.assetGeneratorController.parametersDelegate = self

        self.buttonSetup()
        self.window.contentView.addSubview(self.generateButton)
    }
    
    func buttonSetup() {
        self.generateButton.frame = NSRect(x: 343, y: 1, width: 96, height: 32)
        self.generateButton.title = "Generate"
        self.generateButton.bezelStyle = NSBezelStyle.RoundedBezelStyle
        self.generateButton.setButtonType(NSButtonType.MomentaryPushInButton)
        self.generateButton.bordered = true
        self.generateButton.transparent = false
        self.generateButton.autoresizesSubviews = true
        self.generateButton.target = self
        self.generateButton.action = Selector("generateButtonPressed")
        self.updateGenerateButton()
    }
    
    func generateButtonPressed() {
        println("Generate Pressed")
        self.assetGeneratorController.generateButtonPressed()
        self.updateGenerateButton()
    }
    
    // MARK:- Convenience Functions.
    
    func updateGenerateButton() -> Void {
        self.generateButton.enabled = self.assetGeneratorController.canExecuteScript()
    }
    
    
    // MARK:- IBAction outlets
    
    @IBAction func recentlyUsedProjectsDropdownListChanged(sender: ProgressPopUpButton!) {

        self.assetGeneratorController.recentlyUsedProjectsDropdownListChanged(sender)
        self.updateGenerateButton()
    }
    
    @IBAction func browseButtonPressed(sender: AnyObject!) {
        self.assetGeneratorController.browseButtonPressed()
        self.updateGenerateButton()
    }
    
    
    // MARK:- ScriptParameters Delegate
    
    func scriptParametersChanged(controller: AssetGeneratorViewController) {
        self.updateGenerateButton()
    }
    
    
}
