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
        return self.recentListMaintainer.selectedProject()?.assetDirectoryPath()
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

    // MARK:- Public toolbar controller hooks.
    func recentProjectsListChanged(sender: NSPopUpButton) {
        // If we select a new project, proceed.
        if sender.indexOfSelectedItem != SelectedItemIndex {
            self.updateRecentProjectsList(index: sender.indexOfSelectedItem)
        }
    }
    
    
    func browseButtonPressed() {
        println("**** Pritning Stuff")
        println("Project: \(self.recentListMaintainer.selectedProject())")
        panel.beginWithCompletionHandler() { (handler: Int) -> Void in
            if handler == NSFileHandlingPanelOKButton {
                
                self.addNewProject(url: self.panel.URL!)
            }
        }
    }
    

    private func openPanelSetup() {
        self.panel.canChooseFiles            = true
        self.panel.allowedFileTypes          = ["xcodeproj"]
        self.panel.canChooseDirectories      = false
        self.panel.allowsMultipleSelection   = false
    }
   
    
}

// MARK:- Dropdown list Management.
extension ProjectToolbarController {
    
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
        self.recentProjectsDropdownListView.progressColor = NSColor(calibratedRed: 0.047, green: 0.261, blue: 0.993, alpha: 1)
        
        if (self.recentListMaintainer.recentProjectsCount() <= 0) {
            self.disableDropdownList()
        
        } else {
            // If we have recent projects, set it up and observe them.
            self.enableDropdownList()
            self.recentProjectsDropdownListView.addItemsWithTitles(self.recentListMaintainer.recentProjectsTitlesList()!)
            
            for proj in self.recentListMaintainer.projects()! {
                self.directoryObserver.observeProject(proj)
            }
            
        }
        self.delegate?.projectToolbarDidChangeProject(self.recentListMaintainer.selectedProject())

    }
    
    private func addNewProject(#url: NSURL) {
        self.recentListMaintainer.addProject(url: url)
        self.updateDropdownListTitles()
        
        if !self.recentProjectsDropdownListView.enabled {
            self.enableDropdownList() // We dont need to really call it after each addition. just the first one.
        }
        self.directoryObserver.observeProject(self.recentListMaintainer.selectedProject()!)
        self.delegate?.projectToolbarDidChangeProject(self.recentListMaintainer.selectedProject())
    }
    
    
    private func updateRecentProjectsList(#index: Int){
        self.recentListMaintainer.addProject(project: self.recentListMaintainer.projectAtIndex(index)!)
        self.updateDropdownListTitles()
        self.delegate?.projectToolbarDidChangeProject(self.recentListMaintainer.selectedProject())
    }
    
    
    // TODO: Why do we remove all items? its the recentUsedProjectsManager concern to maintain order for its cache. So either trust its decisions or dont use it.
    private func updateDropdownListTitles() -> Void {
        self.recentProjectsDropdownListView.removeAllItems()
        if self.recentListMaintainer.recentProjectsCount() > 0 {
            let titles = self.recentListMaintainer.recentProjectsTitlesList()!
            self.recentProjectsDropdownListView.addItemsWithTitles(titles)
            self.recentProjectsDropdownListView.selectItemAtIndex(0)
        } else {
            self.disableDropdownList()
        }
    }
    
}

// MARK: Directory Observer Compliance
extension ProjectToolbarController: FileSystemObserverDelegate {
    
    func FileSystemDirectory(oldPath: String!, renamedTo newPath: String!) {
        self.directoryObserver.updatePathForObserver(oldPath: oldPath, newPath: newPath)
        self.updateDropdownListTitles()
    }

    func FileSystemDirectoryDeleted(path: String!) {
        
        if path.isXCProject() {
            let corruptedProjects = self.recentListMaintainer.recentProjects { project in
                return !ProjectValidator.isProjectValid(project)
            }
            println(corruptedProjects)
            if let projects = corruptedProjects {
                for project in projects {
                    self.recentListMaintainer.removeProject(project: project)
                }
            }
            
        
        } else if path.isXCAsset() {
            
            let corruptedProjects = self.recentListMaintainer.recentProjects { project in
                return !ProjectValidator.isAssetValid(project)
            }
            
            if let projects = corruptedProjects {
                for project in projects {
                    var newProject = XCProject(bookmark: BookmarkResolver.resolveBookmarkFromPath(project.path))
                    let indexOfProject = self.recentListMaintainer.indexOfProject(project)
                    
                    self.recentListMaintainer.removeProject(project: project)
                    
                    if let idx = indexOfProject {
                        self.recentListMaintainer.addProject(project: newProject, index: idx)
                    }
                    if (self.recentListMaintainer.selectedProject()? == project) {
                        // TODO: selected project has changed.
                    }
                    
                }
            }
        }
        

        self.updateDropdownListTitles()
        self.delegate?.projectToolbarDidChangeProject(nil)
    }
    
    func FileSystemDirectoryError(error: NSError!) {
        // TODO:
    }
    
    
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
