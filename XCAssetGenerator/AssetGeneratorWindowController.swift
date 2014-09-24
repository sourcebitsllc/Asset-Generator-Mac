//
//  AssetGeneratorWindowController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/15/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

// TODO: I still dont like how much resposibility the Window controller is carrying. Maybe i can move all the destination Protocol logic to its own container while maintaining Toolbar in window logic somehow?
protocol AssetGeneratorDestinationProjectDelegate {
    func destinationProjectDidChange(project: XCProject?) // Can it be nil? (well maybe we'll add delete operator)
}


class AssetGeneratorWindowController: NSWindowController, NSToolbarDelegate, ScriptDestinationPathDelegate, ScriptProgessDelegate {

    @IBOutlet var recentlyUsedProjectsDropdownList: ProgressPopUpButton!
    @IBOutlet var browseButton: NSButton!
    
    let recentListManager: RecentlySelectedProjectManager
    var assetsToolbarDelegate: AssetGeneratorDestinationProjectDelegate?
    private var timer: NSTimer
    private  var panel: NSOpenPanel = NSOpenPanel()
    
    required init(coder: NSCoder!) {
        recentListManager = RecentlySelectedProjectManager()
        timer = NSTimer()
        super.init(coder: coder)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.assetsToolbarDelegate = self.contentViewController as AssetGeneratorViewController
        
        self.dropdownListSetup()
        self.openPanelSetup()
    }
    
    func dropdownListSetup() {
        self.recentlyUsedProjectsDropdownList.addItemsWithTitles(self.recentListManager.recentProjectsTitlesList())
        self.recentlyUsedProjectsDropdownList.preferredEdge = NSMaxYEdge
        self.recentlyUsedProjectsDropdownList.progressColor = NSColor(calibratedRed: 0.047, green: 0.261, blue: 0.993, alpha: 1)
        
        //self.recentlyUsedProjectsDropdownList.selectedItem.attributedTitle = NSAttributedString(string: self.recentlyUsedProjectsDropdownList.selectedItem.title, attributes:[NSForegroundColorAttributeName: NSColor.blackColor()])
      
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

    
    func updateRecentProjectsList(project path: String){
        if path != self.recentListManager.selectedProject()?.path {
            
            self.recentListManager.addProject(path)
            self.updateRecentUsedProjectsDropdownView()
            // Notify delegate
            self.assetsToolbarDelegate?.destinationProjectDidChange(self.recentListManager.selectedProject())
        }
    }
    
    
    // MARK:- IBAction outlets
    
    @IBAction func recentlyUsedProjectsDropdownListChanged(sender: NSPopUpButton!) {
        println("recent pressed")
//      self.recentListManager.addProject(sender.title)
//      self.updateRecentUsedProjectsDropdownView()
        self.updateRecentProjectsList(project: sender.titleOfSelectedItem)
    }
    
    @IBAction func browseButtonPressed(sender: AnyObject!) {
        println("browse pressed")
        
        panel.beginWithCompletionHandler() { (handler: Int) -> Void in
            if handler == NSFileHandlingPanelOKButton {
                self.updateRecentProjectsList(project: self.panel.URL.path!)
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
    
    func moveProgressSmoothly() {
        self.recentlyUsedProjectsDropdownList.setProgress(progress: self.recentlyUsedProjectsDropdownList.progress + 0.05)
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
        println("Finished Executing")
        self.timer.invalidate()
    }
    
}
