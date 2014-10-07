//
//  ProjectController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/25/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

protocol ProjectToolbarDelegate {
    func projectToolbarDidChangeProject(project: XCProject?)
}

// MARK:- The Toolbars Embeded Progress Indicator Extenstion
extension ProjectToolbarController {
    
    var toolbarProgress: CGFloat  {
        get {
            return self.recentProjectsDropdownListView.progress
        }
    }
    
    func setToolbarProgress(#progress: CGFloat) {
        self.recentProjectsDropdownListView.setProgress(progress: progress)
    }
    
    func setToolbarProgressColor(#color: NSColor) {
        self.recentProjectsDropdownListView.setProgressColor(color)
    }
}

class ProjectToolbarController: NSObject, ScriptDestinationPathDelegate {

    var recentProjectsDropdownListView: ProgressPopUpButton!
    var delegate : ProjectToolbarDelegate?
    
    private let recentListManager: RecentlySelectedProjectManager
    private var panel: NSOpenPanel = NSOpenPanel()
    
    
    // MARK:- Setup Helpers
    
    init(recentList: ProgressPopUpButton) {
        recentListManager = RecentlySelectedProjectManager()
        recentProjectsDropdownListView = recentList
        super.init()
        self.dropdownListSetup()
        self.openPanelSetup()
    }
    
    private func dropdownListSetup() {
        self.recentProjectsDropdownListView.preferredEdge = NSMaxYEdge
        self.recentProjectsDropdownListView.progressColor = NSColor(calibratedRed: 0.047, green: 0.261, blue: 0.993, alpha: 1)
        if (self.recentListManager.recentProjectsCount() > 0) {
            self.enableDropdownList()
            self.recentProjectsDropdownListView.addItemsWithTitles(self.recentListManager.recentProjectsTitlesList())
        } else {
            self.disableDropdownList()
        }
    }
    
    
    private func disableDropdownList() {
        self.recentProjectsDropdownListView.removeAllItems()
        self.recentProjectsDropdownListView.addItemWithTitle("Recent Projects")
        
        self.recentProjectsDropdownListView.enabled     = false
        self.recentProjectsDropdownListView.alignment   = NSTextAlignment.CenterTextAlignment
        self.recentProjectsDropdownListView.alphaValue  = 0.5 // lul.
    }
    

    
    // MARK:- Public toolbar controller hooks.
    func recentProjectsListChanged(sender: NSPopUpButton) {
        self.updateRecentProjectsList(index: sender.indexOfSelectedItem)
    }
    
    func browseButtonPressed() {
        panel.beginWithCompletionHandler() { (handler: Int) -> Void in
            if handler == NSFileHandlingPanelOKButton {
                
                self.addNewProject(path: self.panel.URL.path!)
            }
        }
    }
    
    
    
    // MARK:- Convenience Methods
    
    // TODO: Why do we remove all items? its the recentUsedProjectsManager to maintain order for its cache. So either trust its decisions or dont use it.
    private func updateRecentUsedProjectsDropdownView() {
        self.recentProjectsDropdownListView.removeAllItems()
        self.recentProjectsDropdownListView.addItemsWithTitles(self.recentListManager.recentProjectsTitlesList())
        self.recentProjectsDropdownListView.selectItemAtIndex(0)
        
    }
    
    // TODO: the two function below have the same "funcionality". Think of parametric polymorphism to integrate them
    private func updateRecentProjectsList(#index: Int){
        if self.recentListManager.projectAtIndex(index) != self.recentListManager.selectedProject()? {
            
            self.recentListManager.addProject(project: self.recentListManager.projectAtIndex(index)!)
            self.updateRecentUsedProjectsDropdownView()
            self.delegate?.projectToolbarDidChangeProject(self.recentListManager.selectedProject())
        }
    }
    
    private func addNewProject(#path: String) {
        self.recentListManager.addProject(path: path)
        self.updateRecentUsedProjectsDropdownView()
        
        if !self.recentProjectsDropdownListView.enabled {
            self.enableDropdownList() // We dont need to really call it after each addition. just the first one.
        }
        
        self.delegate?.projectToolbarDidChangeProject(self.recentListManager.selectedProject())
    }
    
    private func enableDropdownList() {
        self.recentProjectsDropdownListView.enabled     = true
        self.recentProjectsDropdownListView.alignment   = NSTextAlignment.LeftTextAlignment
        self.recentProjectsDropdownListView.alphaValue  = 1.0
    }
    
    private func openPanelSetup() {
        self.panel.canChooseFiles            = true
        self.panel.allowedFileTypes          = ["xcodeproj"]
        self.panel.canChooseDirectories      = false
        self.panel.allowsMultipleSelection   = false
    }
    
 
    
    // MARK:- ScriptDestinationPath Delegate
    
    func destinationPath() -> String? {
        return self.recentListManager.selectedProject()?.assetDirectoryPath()
    }
    
    func hasValidDestinationProject() -> Bool {
        println(self.recentListManager.isSelectedProjectValid())
        println(self.recentListManager.selectedProject()?)
        println(self.recentListManager.selectedProject()!.hasValidAssetsPath())
        return self.recentListManager.isSelectedProjectValid() && self.recentListManager.selectedProject()!.hasValidAssetsPath()
    }
    
}
