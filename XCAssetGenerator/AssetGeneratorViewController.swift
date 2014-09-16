//
//  AssetGeneratorViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/12/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

import Cocoa


class AssetGeneratorViewController: NSViewController, FileDropControllerDelegate, AssetGeneratorDestinationProjectDelegate, ScriptProgessDelegate {

    @IBOutlet var generateButton: NSButton!
  
    var fileDropController: FileDropViewController! // Force unwrap since it doesnt make sense it this doesnt exist.
    let recentListManager: RecentlySelectedProjectManager
    let scriptManager: ScriptExecutor
    
    required init(coder: NSCoder!) {
        recentListManager = RecentlySelectedProjectManager()
        scriptManager = ScriptExecutor()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       // TODO: Find better way to connect containerController to local var. sigh.
//      self.fileDropController = self.childViewControllers.first! as FileDropViewController
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.updateGenerateButton()
        self.scriptManager.destinationDelegate = self.view.window?.windowController() as AssetGeneratorWindowController // TODO: HAX!
        
        self.scriptManager.progressDelegate = self
    }

    // MARK:- Convenience Functions.
    func updateGenerateButton() -> Void {
        self.generateButton.enabled = self.scriptManager.canExecuteScript()
    }

    // MARK: - IBActions
    @IBAction func generateButtonPressed(sender: AnyObject!) {

        // We _CANNOT_ be in this function if canExecuteScript is not checked and passed.
        self.scriptManager.executeScript()
        self.updateGenerateButton()
//        self.scriptManager.executeScript(generate1x: false, extraArgs: nil)
    }
    
    // Is this better?
    // MARK: - Segues functions
    override func prepareForSegue(segue: NSStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "embeddedContainer" {
            self.fileDropController = segue.destinationController as FileDropViewController
            self.fileDropController.delegate = self
            
            // fileDrop is the source, so set it as delegate
            self.scriptManager.sourceDelegate = self.fileDropController
        }
    }
    
    // MARK: - FileDropController Delegate
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController) {
        self.updateGenerateButton()
        
    }
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController) {
        self.updateGenerateButton()
    }
    
    // MARK:- ScriptProgress delegate
    func scriptFinishedExecutingScript(executor: ScriptExecutor) {
        self.updateGenerateButton()
    }

    // MARK: - AssetGeneratorDestinationProject Delegate
    func destinationProjectDidChange(path: String?) {
        println("Destination Project Changed")
        self.updateGenerateButton()
    }
   
}
