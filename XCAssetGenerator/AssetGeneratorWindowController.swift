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
        assetGeneratorController = contentViewController as AssetGeneratorViewController
        assetGeneratorController.setRecentListDropdown(recentlyUsedProjectsDropdownList)
        assetGeneratorController.parametersDelegate = self
        
        buttonSetup()
        handleKeyboardHotkeys()
    }
    
    func buttonSetup() {
        // Generate button setup
        generateButton.font                = browseButton.font // lolwut. Brogramming (tm)
        generateButton.title               = NSLocalizedString("Generate", comment: "")
        generateButton.state               = 1
        generateButton.target              = self
        generateButton.action              = Selector("generateButtonPressed")
        generateButton.bordered            = true
        generateButton.continuous          = false
        generateButton.bezelStyle          = NSBezelStyle.RoundedBezelStyle
        generateButton.transparent         = false
        generateButton.autoresizesSubviews = true
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        
        generateButton.setButtonType(NSButtonType.MomentaryLightButton)
        updateGenerateButton()
        window!.contentView.addSubview(generateButton)
        
        let contraintH = NSLayoutConstraint.constraintsWithVisualFormat("H:[generateButton(buttonWidth)]-offsetLeft-|", options: nil, metrics: ["offsetLeft": 10,"buttonWidth": 90], views: ["generateButton": generateButton])
        let contraintV = NSLayoutConstraint.constraintsWithVisualFormat("V:[generateButton]-offsetBottom-|", options: nil, metrics: ["offsetBottom": 8], views: ["generateButton": generateButton])
        
        window?.contentView.addConstraints(contraintH)
        window?.contentView.addConstraints(contraintV)
        
        // Generate1x Radio button Setup
        generate1xButton.title                 = "Generate Missing Assets"
        generate1xButton.state                 = 0
        generate1xButton.hidden                = true // Hide the button for 1.0 release.
        generate1xButton.target                = self
        generate1xButton.bordered              = false
        generate1xButton.bezelStyle            = NSBezelStyle.RoundRectBezelStyle
        generate1xButton.transparent           = false
        generate1xButton.focusRingType         = NSFocusRingType.None
        generate1xButton.autoresizesSubviews   = true
        generate1xButton.translatesAutoresizingMaskIntoConstraints = false
        generate1xButton.setButtonType(NSButtonType.SwitchButton)
        
        window!.contentView.addSubview(generate1xButton)
        
        let Hcontraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-offsetLeft-[generate1xButton(buttonWidth)]", options: nil, metrics: ["offsetLeft": 20,"buttonWidth": 180], views: ["generate1xButton": generate1xButton])
        let Vcontraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[generate1xButton]-offsetBottom-|", options: nil, metrics: ["offsetBottom": 8,"buttonHeight": 30], views: ["generate1xButton": generate1xButton])
        
        window?.contentView.addConstraints(Hcontraint)
        window?.contentView.addConstraints(Vcontraint)
        
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
        generateButton.enabled = assetGeneratorController.canExecuteScript()
    }
    
    
    // MARK:- IBAction outlets
    
    @IBAction func recentlyUsedProjectsDropdownListChanged(sender: ProgressPopUpButton!) {
        assetGeneratorController.recentlyUsedProjectsDropdownListChanged(sender)
    }
    
    // MARK - NSButton Callback Functions
    @IBAction func browseButtonPressed(sender: AnyObject!) {
        assetGeneratorController.browseButtonPressed()
    }
    
    func generateButtonPressed() {
        let generateMissingAssets: Bool = Bool(generate1xButton.state)
        
        assetGeneratorController.generateButtonPressed(generateAssets: generateMissingAssets, args: nil)
        updateGenerateButton()
    }
}


// MARK:- ScriptParameters Delegate
extension AssetGeneratorWindowController: ScriptParametersDelegate {
    func scriptParametersChanged(controller: AssetGeneratorViewController) {
        updateGenerateButton()
    }
}