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

class AssetGeneratorViewController: NSViewController, FileDropControllerDelegate, ScriptProgessDelegate, ProjectToolbarDelegate {
  
    var parametersDelegate: ScriptParametersDelegate?
    
    var scriptController: ScriptController
    var fileDropController: FileDropViewController!
    var projectToolbarController: ProjectToolbarController!
    
    private var timer: NSTimer = NSTimer()
    
    required init(coder: NSCoder!) {
        scriptController = ScriptController()
        super.init(coder: coder)
    }
    
    // We have to set this as soon as possible. Hacky as heck but MVC isnt helping right now.
    func setRecentListDropdown(list: ProgressPopUpButton) {
        self.projectToolbarController = ProjectToolbarController(recentList: list)
        self.projectToolbarController.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       // TODO: Find better way to connect containerController to local var. sigh.
//      self.fileDropController = self.childViewControllers.first! as FileDropViewController
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("hello"), name: "NSApplicationDidBecomeActiveNotification", object: nil)
    }
    
    func controllerDidBecomeActive() {
        println("Active")
        self.fileDropController.validateIfSourcePathStillExists()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.scriptController.sourceDelegate        = self.fileDropController
        self.scriptController.progressDelegate      = self
        self.scriptController.destinationDelegate   = self.projectToolbarController
    }
    
    func recentlyUsedProjectsDropdownListChanged(sender: ProgressPopUpButton) {
        self.projectToolbarController.recentProjectsListChanged(sender)
    }
    
    func browseButtonPressed() {
        self.projectToolbarController.browseButtonPressed()
    }
    
    func generateButtonPressed(options: [ScriptOptions]?) {
        self.scriptController.executeScript(options)
    }
    
    func canExecuteScript() -> Bool {
        return self.scriptController.canExecuteScript()
    }
    
    
    // MARK: - Segues functions
    // Is this better?
    override func prepareForSegue(segue: NSStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "embeddedContainer" {
            self.fileDropController = segue.destinationController as FileDropViewController
            self.fileDropController.delegate = self
//            self.scriptController.sourceDelegate = self.fileDropController
        }
    }
    
    
    
    // MARK: - FileDropController Delegate
    
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController) {
        self.parametersDelegate?.scriptParametersChanged(self)
    }
    
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController, path: String) {
        if PathValidator.directoryContainsInvalidCharacters(path: path, options: nil) {
            println("WARNING: THE SOURCE PATH CONTAINS DODO. I REPEAT, THE SOURCE PATH CONTAINS A DODO")
            println("REASON: FOUND A SUBDIRECTORY WHICH CONTAINS A DOT..... DOT..DOT..")
        }
        self.parametersDelegate?.scriptParametersChanged(self)
    }
    
    
    
    // MARK:- ProjectToolbar Delegate
    func projectToolbarDidChangeProject(project: XCProject?) {
        if let p = project {
            self.parametersDelegate?.scriptParametersChanged(self)
            if !p.hasValidAssetsPath() {
                println("ERROR: THE DESTINATION PATH CONTAINS A DODO")
                println("REASON: SELECTED PROJECT DOES NOT CONTAIN A VALID XCASSETS PATH")
            }
        }
    }
    
    
    
    // MARK:- Script Progress Delegate
    
    func scriptDidStartExecutingScipt(executor: ScriptExecutor) {
        // This is just a tmeporary h4x. Fix progress bar and remove it.
        self.timer = NSTimer(timeInterval: 0.1, target: self, selector: Selector("moveProgressSmoothly") , userInfo: nil, repeats: true)
        
        NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSDefaultRunLoopMode)
        self.timer.fire()
    }
    
    func scriptExecutingScript(progress: Int?) {
        if let p = progress {
            self.projectToolbarController.setToolbarProgress(progress: CGFloat(p))
        }
    }
    
    func scriptFinishedExecutingScript(executor: ScriptExecutor) {
        self.projectToolbarController.setToolbarProgress(progress: 0)
        self.timer.invalidate()
        
        self.parametersDelegate?.scriptParametersChanged(self)
    }
    
    // MARK: H4X. Fix.
    func moveProgressSmoothly() {
        self.projectToolbarController.setToolbarProgress(progress: self.projectToolbarController.toolbarProgress + 0.05)
    }
   
}
