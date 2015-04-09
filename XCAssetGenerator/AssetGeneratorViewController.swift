//
//  AssetGeneratorViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/12/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

protocol ScriptParametersDelegate {
    func scriptParametersChanged(controller: AssetGeneratorViewController)
}

class AssetGeneratorViewController: NSViewController {
  
    var parametersDelegate: ScriptParametersDelegate?
    
    var scriptController: AssetGenerationController
    var fileDropController: FileDropViewController!
    var projectToolbarController: ProjectToolbarController!
    
    private var timer: NSTimer = NSTimer()
    
    required init?(coder: NSCoder) {
        scriptController = AssetGenerationController()
        super.init(coder: coder)
    }
    
    
    // We have to set this as soon as possible. Hacky as heck but MVC isnt helping right now.
    func setRecentListDropdown(list: ProgressPopUpButton) {
        projectToolbarController = ProjectToolbarController(recentList: list)
        projectToolbarController.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Find better way to connect containerController to local var. sigh.
        // self.fileDropController = self.childViewControllers.first! as FileDropViewController
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        scriptController.sourceDelegate = fileDropController
        scriptController.progressDelegate = self
        scriptController.destinationDelegate = projectToolbarController
    }
    
    func recentlyUsedProjectsDropdownListChanged(sender: ProgressPopUpButton) {
        projectToolbarController.recentProjectsListChanged(sender)
    }
    
    func browseButtonPressed() {
        projectToolbarController.browseButtonPressed()
    }
    
    func generateButtonPressed(#generateAssets: Bool, args: [AnyObject]?) {
        var options : [ScriptOptions]? = [ScriptOptions]()
        
        if generateAssets {
            options?.insert(ScriptOptions.GenerateMissingAssets, atIndex: 0)
        }
        scriptController.executeScript(options)
    }
    
    func canExecuteScript() -> Bool {
        return scriptController.canExecuteScript()
    }

    // MARK: - Segues functions
    // Is this better?
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "embeddedContainer" {
            fileDropController = segue.destinationController as! FileDropViewController
            fileDropController.delegate = self
            // self.scriptController.sourceDelegate = self.fileDropController
        }
    }
    
}


// MARK:- ProjectToolbar Delegate
extension AssetGeneratorViewController: ProjectToolbarDelegate {
    
    func projectToolbarDidChangeProject(project: XCProject?) {
        if let p = project {
            if !p.hasValidAssetsPath() {
                println("ERROR: THE DESTINATION PATH CONTAINS A DODO")
                println("REASON: SELECTED PROJECT DOES NOT CONTAIN A VALID XCASSETS PATH")
            }
        }
        
        parametersDelegate?.scriptParametersChanged(self)
    }
}


// MARK: - FileDropController Delegate
extension AssetGeneratorViewController: FileDropControllerDelegate {
    
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController, removedPath: String) {
        parametersDelegate?.scriptParametersChanged(self)
    }
    
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController, path: Path, previousPath: String?) {

        if PathValidator.directoryContainsInvalidCharacters(path: path, options: nil) {
            println("WARNING: THE SOURCE PATH CONTAINS DODO. I REPEAT, THE SOURCE PATH CONTAINS A DODO")
            println("REASON: FOUND A SUBDIRECTORY WHICH CONTAINS A DOT..... DOT..DOT..")
            println(path)
        }
        
        parametersDelegate?.scriptParametersChanged(self)
    }
}


// MARK:- Script Progress Delegate
extension AssetGeneratorViewController: AssetGeneratorProgessDelegate {
    func scriptDidStartExecutingScipt() {
        projectToolbarController.setToolbarProgress(progress: 2)
        parametersDelegate?.scriptParametersChanged(self)
    }
    
    func scriptExecutingScript(progress: Int?) {
        if let p = progress {
            projectToolbarController.setToolbarProgress(progress: CGFloat(p))
        }
    }
    
    func scriptFinishedExecutingScript() {
        projectToolbarController.setToolbarProgress(progress: 0)
        parametersDelegate?.scriptParametersChanged(self)
    }

}



