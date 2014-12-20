//
//  AssetGeneratorWindowController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/15/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

// TODO: the script option passing seems hacky and rushed. Revisit it later.

class AssetGeneratorWindowController: NSWindowController  {

    @IBOutlet var recentlyUsedProjectsDropdownList: ProgressPopUpButton! // Shame.
    @IBOutlet var browseButton: NSButton!
    
    var generateButton: NSButton
    
    var assetGeneratorController: AssetGeneratorViewController!
    
    var generate1xButton: NSButton
    
    
    required init?(coder: NSCoder) {
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
        self.handleKeyboardHotkeys()
    }
    
    func buttonSetup() {
        // Generate button setup
        self.generateButton.font                = self.browseButton.font // lolwut. Brogramming (tm)
        self.generateButton.title               = "Generate"
        self.generateButton.state               = 1
        self.generateButton.target              = self
        self.generateButton.action              = Selector("generateButtonPressed")
        self.generateButton.bordered            = true
        self.generateButton.continuous          = false
        self.generateButton.bezelStyle          = NSBezelStyle.RoundedBezelStyle
        self.generateButton.transparent         = false
        self.generateButton.autoresizesSubviews = true
        self.generateButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.generateButton.setButtonType(NSButtonType.MomentaryLightButton)
        self.updateGenerateButton()
        self.window!.contentView.addSubview(self.generateButton)
        
        let contraintH = NSLayoutConstraint.constraintsWithVisualFormat("H:[generateButton(buttonWidth)]-offsetLeft-|", options: nil, metrics: ["offsetLeft": 10,"buttonWidth": 90], views: ["generateButton": generateButton])
        let contraintV = NSLayoutConstraint.constraintsWithVisualFormat("V:[generateButton]-offsetBottom-|", options: nil, metrics: ["offsetBottom": 8], views: ["generateButton": generateButton])
        
        self.window?.contentView.addConstraints(contraintH)
        self.window?.contentView.addConstraints(contraintV)
        
        // Generate1x Radio button Setup
        self.generate1xButton.title                 = "Generate Missing Assets"
        self.generate1xButton.state                 = 0
        self.generate1xButton.hidden                = true // Hide the button for 1.0 release.
        self.generate1xButton.target                = self
        self.generate1xButton.bordered              = false
        self.generate1xButton.bezelStyle            = NSBezelStyle.RoundRectBezelStyle
        self.generate1xButton.transparent           = false
        self.generate1xButton.focusRingType         = NSFocusRingType.None
        self.generate1xButton.autoresizesSubviews   = true
        self.generate1xButton.translatesAutoresizingMaskIntoConstraints = false
        self.generate1xButton.setButtonType(NSButtonType.SwitchButton)
        
        self.window!.contentView.addSubview(self.generate1xButton)
        
        let Hcontraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-offsetLeft-[generate1xButton(buttonWidth)]", options: nil, metrics: ["offsetLeft": 20,"buttonWidth": 180], views: ["generate1xButton": generate1xButton])
        let Vcontraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[generate1xButton]-offsetBottom-|", options: nil, metrics: ["offsetBottom": 8,"buttonHeight": 30], views: ["generate1xButton": generate1xButton])
        
        self.window?.contentView.addConstraints(Hcontraint)
        self.window?.contentView.addConstraints(Vcontraint)
        
    }
    
    func handleKeyboardHotkeys() -> Void {
        NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask) { (event :NSEvent!) -> NSEvent! in
            // o = 31, g = 5, 37
            let flags = event.modifierFlags & NSEventModifierFlags.DeviceIndependentModifierFlagsMask
            
            if (flags == NSEventModifierFlags.CommandKeyMask) {
                switch (event.keyCode) {
                case 31: // O
                    self.browseButtonPressed(nil)
                    return nil
                
                case 5: // G
                    if self.generateButton.enabled {
                        self.generateButtonPressed()
                        return nil
                    }
                
                case 37: // L
                    println("[+] CMD + L pressed")
//                    var logWindow = NSWindow(contentRect: self.window!.frame, styleMask: 9, backing: NSBackingStoreType.Buffered, defer: false)
                    // logWindow.makeKeyAndOrderFront(self)
                
                default:
                    break
                }
            }
            return event
        }
    }
    
    func updateGenerateButton() -> Void {
        self.generateButton.enabled = self.assetGeneratorController.canExecuteScript()
    }
    
    
    // MARK:- IBAction outlets
    
    @IBAction func recentlyUsedProjectsDropdownListChanged(sender: ProgressPopUpButton!) {
        self.assetGeneratorController.recentlyUsedProjectsDropdownListChanged(sender)
    }
    
    // MARK - NSButton Callback Functions
    @IBAction func browseButtonPressed(sender: AnyObject!) {
        self.assetGeneratorController.browseButtonPressed()
    }
    
    func generateButtonPressed() {
        let generateMissingAssets: Bool = Bool(generate1xButton.state)
        
        self.assetGeneratorController.generateButtonPressed(generateAssets: generateMissingAssets, args: nil)
        self.updateGenerateButton()
    }
}


// MARK:- ScriptParameters Delegate
extension AssetGeneratorWindowController: ScriptParametersDelegate {
    func scriptParametersChanged(controller: AssetGeneratorViewController) {
        self.updateGenerateButton()
    }
}