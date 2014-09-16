//
//  AssetGeneratorWindowController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/15/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

import Cocoa

protocol AssetGeneratorDestinationProjectDelegate {
    func destinationProjectDidChange(path: String?) // Can it be nil? (well maybe we'll add delete operator)
}

class AssetGeneratorWindowController: NSWindowController, NSToolbarDelegate, ScriptDestinationPathDelegate {

    @IBOutlet var recentlyUsedProjectsDropdownList: NSPopUpButton!
    @IBOutlet var browseButton: NSButton!
    
    let recentListManager: RecentlySelectedProjectManager
    var assetsToolbarDelegate: AssetGeneratorDestinationProjectDelegate?
    
    
    required init(coder: NSCoder!) {
        recentListManager = RecentlySelectedProjectManager()
        super.init(coder: coder)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let viewController = self.contentViewController as AssetGeneratorViewController
        self.assetsToolbarDelegate = viewController
        viewController.destinationDelegate = self
        
        self.dropdownListSetup()
    }
    
    func dropdownListSetup() {
        self.recentlyUsedProjectsDropdownList.addItemsWithTitles(self.recentListManager.recentProjectsList())
        self.recentlyUsedProjectsDropdownList.preferredEdge = NSMaxYEdge
    }
    
    // TODO: Why do we remove all items? its the recentUsedProjectsManager to maintain order for its cache. So either trust its decisions or dont use it.
    // MARK:- Convenience Methods
    func updateRecentUsedProjectsDropdownView() {
        self.recentlyUsedProjectsDropdownList.removeAllItems()
        self.recentlyUsedProjectsDropdownList.addItemsWithTitles(self.recentListManager.recentProjectsList())
        self.recentlyUsedProjectsDropdownList.selectItemAtIndex(0)
    }
    
    func updateRecentProjectsList(project path: String){
        if path != self.recentListManager.selectedProject() {
            
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
        var panel: NSOpenPanel = NSOpenPanel()
        
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["xcassets"]
        
        panel.beginWithCompletionHandler() { (handler: Int) -> Void in
            if handler == NSFileHandlingPanelOKButton {
                let path = panel.URL.path
                NSLog("the URL: \(path)")
                //                self.recentListManager.addProject(panel.URL.path!)
                //                self.updateRecentUsedProjectsDropdownView()
                self.updateRecentProjectsList(project: path!)
            }
        }
    }
    
    // MARK:- ScriptDestinationPath Delegate
    func destinationPath() -> String? {
        return self.recentListManager.selectedProject()
    }
    
    func hasValidDestinationProject() -> Bool {
        return self.recentListManager.isSelectedProjectValid()
    }
    

}
