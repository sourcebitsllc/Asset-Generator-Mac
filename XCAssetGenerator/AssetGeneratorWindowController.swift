//
//  AssetGeneratorWindowController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/15/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa


class AssetGeneratorWindowController: NSWindowController, NSToolbarDelegate, ScriptParametersDelegate {

    @IBOutlet var recentlyUsedProjectsDropdownList: ProgressPopUpButton!
    @IBOutlet var browseButton: NSButton!
    
    var generateButton: NSButton
    
    var assetGeneratorController: AssetGeneratorViewController!
    
    var generate1xButton: NSButton
    
    
    required init(coder: NSCoder!) {
        generateButton = NSButton()
        generate1xButton = NSButton()
        super.init(coder: coder)
    }
    
 
    override func windowDidLoad() {
        super.windowDidLoad()
        self.assetGeneratorController = self.contentViewController as AssetGeneratorViewController
        self.assetGeneratorController.setRecentListDropdown(self.recentlyUsedProjectsDropdownList)
        self.assetGeneratorController.parametersDelegate = self

        self.buttonSetup()
    }
    
    //
    func buttonSetup() {
        self.generateButton.title = "Generate"
        self.generateButton.font = self.browseButton.font // lolwut. Brogramming (tm)
        self.generateButton.bezelStyle = NSBezelStyle.RoundedBezelStyle
        self.generateButton.setButtonType(NSButtonType.MomentaryLightButton)
        self.generateButton.bordered = true
        self.generateButton.transparent = false
        self.generateButton.autoresizesSubviews = true
        self.generateButton.state = true
        self.generateButton.continuous = false
        self.generateButton.target = self
        self.generateButton.action = Selector("generateButtonPressed")
        self.generateButton.translatesAutoresizingMaskIntoConstraints = false
        self.updateGenerateButton()
        self.window.contentView.addSubview(self.generateButton)
        
        let contraintH = NSLayoutConstraint.constraintsWithVisualFormat("H:[generateButton(buttonWidth)]-offsetLeft-|", options: nil, metrics: ["offsetLeft": 20,"buttonWidth": 90], views: ["generateButton": generateButton])
        let contraintV = NSLayoutConstraint.constraintsWithVisualFormat("V:[generateButton]-offsetBottom-|", options: nil, metrics: ["offsetBottom": 8], views: ["generateButton": generateButton])
        
        self.window.contentView.addConstraints(contraintH)
        self.window.contentView.addConstraints(contraintV)
        
        self.generate1xButton.title = "1x/3x Label"
        self.generate1xButton.bezelStyle = NSBezelStyle.RoundRectBezelStyle
        self.generate1xButton.setButtonType(NSButtonType.SwitchButton)
        self.generate1xButton.bordered = false
        self.generate1xButton.focusRingType = NSFocusRingType.None
        self.generate1xButton.transparent = false
        self.generate1xButton.autoresizesSubviews = true
        self.generate1xButton.target = self
        self.generate1xButton.action = Selector("generate1xButtonPressed")
        self.generate1xButton.translatesAutoresizingMaskIntoConstraints = false

        self.window.contentView.addSubview(self.generate1xButton)
        let Hcontraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-offsetLeft-[generate1xButton(buttonWidth)]", options: nil, metrics: ["offsetLeft": 20,"buttonWidth": 90], views: ["generate1xButton": generate1xButton])
        let Vcontraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[generate1xButton(buttonHeight)]-offsetBottom-|", options: nil, metrics: ["offsetBottom": 2,"buttonHeight": 30], views: ["generate1xButton": generate1xButton])
        
        self.window.contentView.addConstraints(Hcontraint)
        self.window.contentView.addConstraints(Vcontraint)
    }
    
    func generateButtonPressed() {
        println("Generate Pressed")
        self.assetGeneratorController.generateButtonPressed()
        self.updateGenerateButton()
    }
    
    func generate1xButtonPressed() {
        println("Check button state changed: \(self.generate1xButton.state)")
    }
    
    
    // MARK:- Convenience Functions.
    
    func updateGenerateButton() -> Void {
        self.generateButton.enabled = self.assetGeneratorController.canExecuteScript()
    }
    
    
    // MARK:- IBAction outlets
    
    @IBAction func recentlyUsedProjectsDropdownListChanged(sender: ProgressPopUpButton!) {
        self.assetGeneratorController.recentlyUsedProjectsDropdownListChanged(sender)
//        self.updateGenerateButton()
    }
    
    @IBAction func browseButtonPressed(sender: AnyObject!) {
        self.assetGeneratorController.browseButtonPressed()
//        self.updateGenerateButton()
    }
    
    
    // MARK:- ScriptParameters Delegate
    
    func scriptParametersChanged(controller: AssetGeneratorViewController) {
        self.updateGenerateButton()
    }
    
    
}
