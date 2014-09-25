//
//  ProjectController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/25/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa


// MARK:- The Toolbars Embeded Progress Indicator Extenstion
extension ProjectToolbarController {
    
    var toolbarProgress: CGFloat  {
        get {
            return self.recentlyUsedProjectsDropdownList.progress
        }
    }
    
    func setToolbarProgress(#progress: CGFloat) {
        self.recentlyUsedProjectsDropdownList.setProgress(progress: progress)
    }
    
    func setToolbarProgressColor(#color: NSColor) {
        self.recentlyUsedProjectsDropdownList.setProgressColor(color)
    }
}

class ProjectToolbarController: NSObject, ScriptDestinationPathDelegate {

    var recentlyUsedProjectsDropdownList: ProgressPopUpButton!
    
    private let recentListManager: RecentlySelectedProjectManager
    private var panel: NSOpenPanel = NSOpenPanel()
    
    // MARK:- Setup Helpers
    
    init(recentList: ProgressPopUpButton) {
        recentListManager = RecentlySelectedProjectManager()
        recentlyUsedProjectsDropdownList = recentList
        super.init()
        self.dropdownListSetup()
        self.openPanelSetup()
    }
    
    private func dropdownListSetup() {
        self.recentlyUsedProjectsDropdownList.addItemsWithTitles(self.recentListManager.recentProjectsTitlesList())
        self.recentlyUsedProjectsDropdownList.preferredEdge = NSMaxYEdge
        self.recentlyUsedProjectsDropdownList.progressColor = NSColor(calibratedRed: 0.047, green: 0.261, blue: 0.993, alpha: 1)
    }
    
    private func openPanelSetup() {
        self.panel.allowedFileTypes          = ["xcodeproj"]
        self.panel.canChooseDirectories      = false
        self.panel.allowsMultipleSelection   = false
    }
    
    
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
        self.recentlyUsedProjectsDropdownList.removeAllItems()
        self.recentlyUsedProjectsDropdownList.addItemsWithTitles(self.recentListManager.recentProjectsTitlesList())
        self.recentlyUsedProjectsDropdownList.selectItemAtIndex(0)
        
    }
    
    // TODO: the two function below have the same "funcionality". Think of parametric polymorphism to integrate them
    private func updateRecentProjectsList(#index: Int){
        if self.recentListManager.projectAtIndex(index) != self.recentListManager.selectedProject()? {
            
            self.recentListManager.addProject(project: self.recentListManager.projectAtIndex(index)!)
            self.updateRecentUsedProjectsDropdownView()
//            self.assetsToolbarDelegate?.destinationProjectDidChange(self.recentListManager.selectedProject())
        }
    }
    
    private func addNewProject(#path: String) {
        self.recentListManager.addProject(path)
        self.updateRecentUsedProjectsDropdownView()
//        self.assetsToolbarDelegate?.destinationProjectDidChange(self.recentListManager.selectedProject())
    }
    
    
    
    // MARK:- ScriptDestinationPath Delegate
    
    func destinationPath() -> String? {
        return self.recentListManager.selectedProject()?.assetDirectoryPath()
    }
    
    func hasValidDestinationProject() -> Bool {
        return self.recentListManager.isSelectedProjectValid() && self.recentListManager.selectedProject()!.hasValidAssetsPath()
    }
    
}
