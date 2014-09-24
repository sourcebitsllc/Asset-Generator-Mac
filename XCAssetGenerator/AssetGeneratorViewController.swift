//
//  AssetGeneratorViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/12/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa


class AssetGeneratorViewController: NSViewController, FileDropControllerDelegate, AssetGeneratorDestinationProjectDelegate, ScriptProgessDelegate {

    @IBOutlet var generateButton: NSButton!
  
    var fileDropController: FileDropViewController! // Force unwrap since it doesnt make sense it this doesnt exist.
    let scriptManager: ScriptExecutor
    
    required init(coder: NSCoder!) {
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
        self.scriptManager.destinationDelegate = self.view.window?.windowController() as AssetGeneratorWindowController // TODO: HAX! how does this controller even know about the windowController being the destination delegate?!
        
        self.scriptManager.progressDelegate = self.view.window?.windowController() as AssetGeneratorWindowController
    }

    
    
    // MARK:- Convenience Functions.
    
    func updateGenerateButton() -> Void {
        println("updatebutton called")
        self.generateButton.enabled = self.scriptManager.canExecuteScript()
        println("\(self.generateButton.enabled)")
    }
    
    
    
    // MARK: - IBActions
    
    @IBAction func generateButtonPressed(sender: AnyObject!) {

        // We _CANNOT_ be in this function if canExecuteScript is not checked and passed.
        self.scriptManager.executeScript()
        self.updateGenerateButton()
//        self.scriptManager.executeScript(generate1x: false, extraArgs: nil)
    }
    
    
    
    // MARK: - Segues functions
    // Is this better?
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
    
    func scriptDidStartExecutingScipt(executor: ScriptExecutor) {
        println("Script Starting")
    }
    
    func scriptFinishedExecutingScript(executor: ScriptExecutor) {
        println("delegate called")

        self.updateGenerateButton()
    }
    
    func scriptExecutingScript(progress: Int?) {
        if let p = progress {
            println("p = \(p)")
//            self.progressBar.hidden = false
//            self.progressBar.doubleValue = Double(p)
        } else {
            println("Cannot handle progress")
        }
    }

    
    
    // MARK: - AssetGeneratorDestinationProject Delegate
    
    func destinationProjectDidChange(project: XCProject?) {
        println("Destination Project Changed")
        if let xcProject = project {
            if xcProject.hasValidAssetsPath() == false {
                println("Error : Selected Project does not have a valid xcassets folder")
            }
        }
   
        self.updateGenerateButton()
    }
   
}
