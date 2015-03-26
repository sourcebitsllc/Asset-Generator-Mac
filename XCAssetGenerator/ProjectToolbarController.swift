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

// MARK:- ScriptDestinationPath Delegate
extension ProjectToolbarController: ScriptDestinationPathDelegate {
    func destinationPath() -> String? {
        return self.recentListMaintainer.selectedProject?.assetPath
    }

    func hasValidDestinationProject() -> Bool {
        return self.recentListMaintainer.isSelectedProjectValid() //&& self.recentListMaintainer.selectedProject()!.hasValidAssetsPath()
    }
}

class ProjectToolbarController: NSObject  {

    var recentProjectsDropdownListView: ProgressPopUpButton!
    var delegate : ProjectToolbarDelegate?
    
    private var directoryObserver: ProjectObserver!
    private let recentListMaintainer: RecentlySelectedProjectMaintainer
    private var panel: NSOpenPanel = NSOpenPanel()
    
    let SelectedItemIndex: Int = 0
    
    // MARK:- Setup Helpers
    
    init(recentList: ProgressPopUpButton) {
        recentListMaintainer = RecentlySelectedProjectMaintainer()
        recentProjectsDropdownListView = recentList
        
        super.init()
        
        self.setupProjectObserver()
        self.dropdownListSetup()
        self.openPanelSetup()
        
    }
    
    private func setupProjectObserver() {
        self.directoryObserver = ProjectObserver(delegate: self)
    }
    
    private func openPanelSetup() {
        self.panel.canChooseFiles            = true
        self.panel.allowedFileTypes          = ["xcodeproj"]
        self.panel.canChooseDirectories      = true
        self.panel.allowsMultipleSelection   = false
    }
    
    
    private func setupError(message: String) -> NSAlert {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButtonWithTitle("OK")
        alert.alertStyle = NSAlertStyle.CriticalAlertStyle
        return alert
    }
    

    // MARK:- Public toolbar controller hooks.
    
    func browseButtonPressed() {
        panel.beginWithCompletionHandler() { (handler: Int) -> Void in
            if handler == NSFileHandlingPanelOKButton {
                /* 
                    1 - Check if path is project
                    2 - If project, proceed normally.
                    3 - If not, Search for internals to find project. (deep search or just one level? or even the current window only.)
                    4 - If project found, proceeed normally.
                    5 - Else, nothing found. Display error.
                */
                
                let url = self.panel.URL!
                let path = url.path!
                
                
                if path.isXCProject() {
                    let directory = self.panel.URL!.path!.stringByDeletingLastPathComponent + ("/")
                    let hasAsset = PathValidator.directoryContainsXCAsset(directory: directory)
                    
                    if hasAsset {
                        self.addNewProject(url: self.panel.URL!)
                    } else {
                      // Throw No valid assets error
                        let name = path.lastPathComponent
                        self.setupError(ProjectSelectionError.AssetNoFound(name).message).runModal()
                    }
                
                } else {
                    let projectURL = PathValidator.retreiveProject(url)
                    
                    
                    if let pURL = projectURL {
                        let directory = pURL.path!.stringByDeletingLastPathComponent + ("/")
                        let hasAsset = PathValidator.directoryContainsXCAsset(directory: directory)
                        
                        if hasAsset {
                            self.addNewProject(url: pURL)
                        } else {
                            // Throw no valid assets error
                            let name = pURL.lastPathComponent!
                            self.setupError(ProjectSelectionError.AssetNoFound(name).message).runModal()
                        }
                        
                    } else {
                        self.setupError(ProjectSelectionError.NoProjectFound.message).runModal()
                    }
                
                }
            }
        }
    }
    
   
    func recentProjectsListChanged(sender: NSPopUpButton) {
        // If we select a new project, proceed.
        if sender.indexOfSelectedItem != SelectedItemIndex {
            self.updateRecentProjectsList(index: sender.indexOfSelectedItem)
        }
    }
    
}

// MARK:- Dropdown list Management.
extension ProjectToolbarController {
    
    
    private func updateRecentProjectsList(#index: Int){
        let idx = (self.recentListMaintainer.selectedProject != nil) ? index : index - 1 // This will never be called on index = 0
        self.recentListMaintainer.addProject(project: self.recentListMaintainer.projectAtIndex(idx)!)
        self.updateDropdownListTitles()
        self.delegate?.projectToolbarDidChangeProject(self.recentListMaintainer.selectedProject)
    }
    
    
    private func enableDropdownList() {
        self.recentProjectsDropdownListView.enabled     = true
        self.recentProjectsDropdownListView.alignment   = NSTextAlignment.LeftTextAlignment
        self.recentProjectsDropdownListView.alphaValue  = 1.0
    }
    
    private func disableDropdownList() {
        self.recentProjectsDropdownListView.removeAllItems()
        self.recentProjectsDropdownListView.addItemWithTitle("Recent Projects")
        
        self.recentProjectsDropdownListView.enabled     = false
        self.recentProjectsDropdownListView.alignment   = NSTextAlignment.CenterTextAlignment
        self.recentProjectsDropdownListView.alphaValue  = 0.5 // lul.
    }
    
    private func dropdownListSetup() {
        self.recentProjectsDropdownListView.preferredEdge = NSMaxYEdge
        self.recentProjectsDropdownListView.setProgressColor(color: NSColor(calibratedRed: 0.047, green: 0.261, blue: 0.993, alpha: 1))
        
        if (self.recentListMaintainer.recentProjectsCount() <= 0) {
            self.disableDropdownList()
        
        } else {
            // If we have recent projects, set it up and observe them.
            self.enableDropdownList()
            self.recentProjectsDropdownListView.addItemsWithTitles(self.recentListMaintainer.recentProjectsTitlesList()!)
            
            for proj in self.recentListMaintainer.projects()! {
                self.directoryObserver.observeProject(proj)
            }
            
            if (self.recentListMaintainer.selectedProject == nil) {
                self.insertPlaceholderProject()
            }
            
        }
        self.delegate?.projectToolbarDidChangeProject(self.recentListMaintainer.selectedProject)

    }
    
    private func addNewProject(#url: NSURL) {
        self.recentListMaintainer.addProject(url: url)
        self.updateDropdownListTitles()
        
        if !self.recentProjectsDropdownListView.enabled {
            self.enableDropdownList() // We dont need to really call it after each addition. just the first one.
        }
        self.directoryObserver.observeProject(self.recentListMaintainer.selectedProject!)
        self.delegate?.projectToolbarDidChangeProject(self.recentListMaintainer.selectedProject)
    }
    
    
    // TODO: Why do we remove all items? its the recentUsedProjectsManager concern to maintain order for its cache. So either trust its decisions or dont use it.
    private func updateDropdownListTitles() -> Void {
        self.recentProjectsDropdownListView.removeAllItems()
        if self.recentListMaintainer.recentProjectsCount() > 0 {
            let titles = self.recentListMaintainer.recentProjectsTitlesList()!
            self.recentProjectsDropdownListView.addItemsWithTitles(titles)
            self.recentProjectsDropdownListView.selectItemAtIndex(SelectedItemIndex)
        } else {
            self.disableDropdownList()
        }
    }
    
    private func insertPlaceholderProject() {
        self.recentProjectsDropdownListView.insertItemWithTitle("               -- Select A Project -- " /* lol */, atIndex: SelectedItemIndex)
        self.recentProjectsDropdownListView.selectItemAtIndex(SelectedItemIndex)
    }
    
}


// MARK: Directory Observer Compliance
extension ProjectToolbarController: FileSystemObserverDelegate {
    
    func FileSystemDirectory(oldPath: String!, renamedTo newPath: String!) {
        
        let project = self.recentListMaintainer.recentProjects { (project) -> Bool in
            return oldPath.isXCProject() ? project.path == oldPath : oldPath.isXCAsset() ? project.assetPath == oldPath : false
        }?.first
        
        if let proj = project {
            let index = self.recentListMaintainer.indexOfProject(proj)
                
            if let idx = index {
                self.recentListMaintainer.removeProject(project: proj)
                self.recentListMaintainer.addProject(project: XCProject(bookmark: proj.bookmark), index: idx)
                
            }
        }
        
        self.directoryObserver.updatePathForObserver(oldPath: oldPath, newPath: newPath)
        self.updateDropdownListTitles()
    }

    
    func FileSystemDirectoryDeleted(path: String!) {
        
        let project = self.recentListMaintainer.recentProjects { (project) -> Bool in
            return (path.isXCProject()) ? project.path == path : (path.isXCAsset()) ? project.assetPath == path : false
        }?.first
        
        let wasSelected = project == self.recentListMaintainer.selectedProject
        
        if let proj = project {
            self.recentListMaintainer.removeProject(project: proj)
        }
        
        self.updateDropdownListTitles()
       
        
        if wasSelected {
            self.insertPlaceholderProject()
            self.recentListMaintainer.resetSelectedProject()
        }
        
        
         self.delegate?.projectToolbarDidChangeProject(nil)
    }
    
    func FileSystemDirectoryError(error: NSError!) {
        // TODO:
    }
    
    
}

// MARK:- The Toolbars Embeded Progress Indicator Extenstion
extension ProjectToolbarController {
    
    func setToolbarProgress(#progress: CGFloat) {
        if progress > 0 {
            self.recentProjectsDropdownListView.setProgress(progress: progress)
        } else {
            self.recentProjectsDropdownListView.resetProgress()
        }
    }
    
    func setToolbarProgressColor(#color: NSColor) {
        self.recentProjectsDropdownListView.setProgressColor(color: color)
    }
}
