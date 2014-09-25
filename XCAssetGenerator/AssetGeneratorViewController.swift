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

class AssetGeneratorViewController: NSViewController, FileDropControllerDelegate, ScriptProgessDelegate {

    @IBOutlet var generateButton: NSButton!
  
    var parametersDelegate: ScriptParametersDelegate?
    
    var fileDropController: FileDropViewController!
    var projectToolbarController: ProjectToolbarController!
    var scriptController: ScriptController
    
    private var timer: NSTimer = NSTimer()
    
    required init(coder: NSCoder!) {
        scriptController = ScriptController()
        super.init(coder: coder)
    }
    
    // We have to set this as soon as possible. Hacky as heck but MVC isnt helping right now.
    func setRecentListDropdown(list: ProgressPopUpButton) {
        self.projectToolbarController = ProjectToolbarController(recentList: list)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       // TODO: Find better way to connect containerController to local var. sigh.
//      self.fileDropController = self.childViewControllers.first! as FileDropViewController
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.scriptController.sourceDelegate        = self.fileDropController
        self.scriptController.destinationDelegate   = self.projectToolbarController
        self.scriptController.progressDelegate      = self
    }
    
    func recentlyUsedProjectsDropdownListChanged(sender: ProgressPopUpButton) {
        self.projectToolbarController.recentProjectsListChanged(sender)
    }
    
    func browseButtonPressed() {
        self.projectToolbarController.browseButtonPressed()
    }
    
    func generateButtonPressed() {
        self.scriptController.executeScript()
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
    
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController) {
        self.parametersDelegate?.scriptParametersChanged(self)
        
    }
    
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController) {
        self.parametersDelegate?.scriptParametersChanged(self)
    }
    
    
    
    // MARK:- Script Progress Delegate
    
    func scriptDidStartExecutingScipt(executor: ScriptExecutor) {
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
    }
    
    func moveProgressSmoothly() {
        self.projectToolbarController.setToolbarProgress(progress: self.projectToolbarController.toolbarProgress + 0.05)
    }


   
}
