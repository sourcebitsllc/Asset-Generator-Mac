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
protocol AssetGeneratorDestinationProjectDelegate {
    func destinationProjectDidChange(project: XCProject?) // Can it be nil? (well maybe we'll add delete operator)
}


class AssetGeneratorWindowController: NSWindowController, NSToolbarDelegate, ScriptDestinationPathDelegate, ScriptProgessDelegate {

    @IBOutlet var recentlyUsedProjectsDropdownList: ProgressPopUpButton!
    @IBOutlet var browseButton: NSButton!
    
    let recentListManager: RecentlySelectedProjectManager
    var assetsToolbarDelegate: AssetGeneratorDestinationProjectDelegate?
   
    private var timer: NSTimer = NSTimer()
    private var panel: NSOpenPanel = NSOpenPanel()
    
    required init(coder: NSCoder!) {
        recentListManager = RecentlySelectedProjectManager()
        super.init(coder: coder)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.assetsToolbarDelegate = self.contentViewController as AssetGeneratorViewController
        
        self.dropdownListSetup()
        self.openPanelSetup()
    }
    
    
    
    // MARK:- Setup Helpers
    
    func dropdownListSetup() {
        self.recentlyUsedProjectsDropdownList.addItemsWithTitles(self.recentListManager.recentProjectsTitlesList())
        self.recentlyUsedProjectsDropdownList.preferredEdge = NSMaxYEdge
        self.recentlyUsedProjectsDropdownList.progressColor = NSColor(calibratedRed: 0.047, green: 0.261, blue: 0.993, alpha: 1)
    }
    
    func openPanelSetup() {
        self.panel.allowedFileTypes          = ["xcodeproj"]
        self.panel.canChooseDirectories      = false
        self.panel.allowsMultipleSelection   = false
    }
    
    
    
    // MARK:- Convenience Methods
    
    // TODO: Why do we remove all items? its the recentUsedProjectsManager to maintain order for its cache. So either trust its decisions or dont use it.
    func updateRecentUsedProjectsDropdownView() {
        self.recentlyUsedProjectsDropdownList.removeAllItems()
        self.recentlyUsedProjectsDropdownList.addItemsWithTitles(self.recentListManager.recentProjectsTitlesList())
        self.recentlyUsedProjectsDropdownList.selectItemAtIndex(0)
    
    }

    // TODO: the two function below have the same "funcionality". Think of parametric polymorphism to integrate them
    func updateRecentProjectsList(#index: Int){
        if self.recentListManager.projectAtIndex(index) != self.recentListManager.selectedProject()? {
            
            self.recentListManager.addProject(project: self.recentListManager.projectAtIndex(index)!)
            self.updateRecentUsedProjectsDropdownView()
            self.assetsToolbarDelegate?.destinationProjectDidChange(self.recentListManager.selectedProject())
        }
    }
    
    func addNewProject(#path: String) {
        self.recentListManager.addProject(path)
        self.updateRecentUsedProjectsDropdownView()
        self.assetsToolbarDelegate?.destinationProjectDidChange(self.recentListManager.selectedProject())
    }
    
    func moveProgressSmoothly() {
        self.recentlyUsedProjectsDropdownList.setProgress(progress: self.recentlyUsedProjectsDropdownList.progress + 0.05)
    }
    
    
    
    // MARK:- IBAction outlets
    
    @IBAction func recentlyUsedProjectsDropdownListChanged(sender: NSPopUpButton!) {
//        var proj1: XCProject = self.recentListManager.projectAtIndex(sender.indexOfSelectedItem)!
//        var proj2: XCProject = self.recentListManager.projectAtIndex(sender.indexOfSelectedItem)!
//        println("Equal? \(proj1 == proj2)")
//        println("Contains? \(contains([proj1], proj2))")
//        println("Find? \(find([proj1], proj2))")
        self.updateRecentProjectsList(index: sender.indexOfSelectedItem)
    }
    
    @IBAction func browseButtonPressed(sender: AnyObject!) {
        panel.beginWithCompletionHandler() { (handler: Int) -> Void in
            if handler == NSFileHandlingPanelOKButton {
                self.addNewProject(path: self.panel.URL.path!)
            }
        }
    }

    
    
    // MARK:- ScriptDestinationPath Delegate
    
    func destinationPath() -> String? {
        return self.recentListManager.selectedProject()?.assetDirectoryPath()
    }
    
    func hasValidDestinationProject() -> Bool {
        return self.recentListManager.isSelectedProjectValid() && self.recentListManager.selectedProject()!.hasValidAssetsPath()
    }
    
    
   
    // MARK:- Script Progress Delegate
    
    func scriptDidStartExecutingScipt(executor: ScriptExecutor) {
        self.timer = NSTimer(timeInterval: 0.1, target: self, selector: Selector("moveProgressSmoothly") , userInfo: nil, repeats: true)
        
        NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSDefaultRunLoopMode)
        self.timer.fire()
    }
    
    func scriptExecutingScript(progress: Int?) {
        if let p = progress {
            self.recentlyUsedProjectsDropdownList.setProgress(progress: CGFloat(p))
        }
    }
    
    func scriptFinishedExecutingScript(executor: ScriptExecutor) {
        self.recentlyUsedProjectsDropdownList.setProgress(progress: 0)
        self.timer.invalidate()
    }
    
}
