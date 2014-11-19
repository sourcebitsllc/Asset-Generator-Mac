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
        let destinationClosure: ProjectObserver.ProjectObserverClosure = self.observerClosure()
        self.directoryObserver = ProjectObserver(projectObserver: destinationClosure)
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
extension ProjectToolbarController {
    func observerClosure() -> FileSystemObserverBlock {
        return { (operation: FileSystemOperation, oldPath: String!, newPath: String!) -> Void in
            switch operation {
                
            case .DirectoryRenamed:
                
                // Stop observing the old path, and observe the new path using the same callback.
                self.directoryObserver.updatePathForObserver(oldPath: oldPath, newPath: newPath)
                self.updateDropdownListTitles()
                
            case .DirectoryBazookad:
                if (newPath == nil) {
                    self.directoryObserver.stopObservingPath(oldPath)
                    // Something was forcefully deleted. (either using rm or equiv)
                    // Turns out, its hard to detect which project this is since the Bookmark data is now corrupted
                    // and any calls to path will crash (which makes sense since its our job to ensure all assets ARE
                    // clean, we need to go through the projects to detemine the stale bookmarks. Thanks Apple.
                    
                    self.recentListMaintainer.cullStaleProjectsAndAssets()
                    self.updateDropdownListTitles()
                    self.delegate?.projectToolbarDidChangeProject(nil)
                }
                
            case .DirectoryDeleted:
                
                self.directoryObserver.stopObservingPath(oldPath)
                
                if oldPath.isXCProject() {
                    
                    if (self.recentListMaintainer.selectedProject()?.path == newPath) {
                        // The current selected project was deleted. Handle it.
                        self.recentListMaintainer.removeProject(project: self.recentListMaintainer.selectedProject()!)
                        
                    } else {
                        // One of the recents (but not the selected) was deleted.
                        let proj = self.recentListMaintainer.recentProjectWithPath(newPath)! // This cannot be nil.
                        self.recentListMaintainer.removeProject(project: proj)
                    }
                    
                } else if oldPath.isXCAsset() {
                    
                    // Find the project whose asset path matches this.
                    var project: XCProject? = self.recentListMaintainer.recentProjectWithAsset(newPath)
                    if let p = project {
                        
                        // Find the affected project and update it.
                        var newProject = XCProject(data: PathBookmarkResolver.resolveBookmarkFromPath(p.path))
                        let indexOfProject = self.recentListMaintainer.indexOfProject(p)! // If project exists -> this cannot be nil.
                        
                        if (self.recentListMaintainer.selectedProject()? == p) {
                            // TODO: selected project has changed.
                        }
                        self.recentListMaintainer.removeProject(project: p)
                        self.recentListMaintainer.addProject(project: newProject, index: indexOfProject)
                        
                    } else {
                        // We end up here if the accompanying project for the asset path could not be located.
                        // This case can occur when the whole project is deleted which sends 2 "FileSystem.Deleted" calls -- 1 for the project and 1 for the asset.
                        // Ending up here means the project won the race condition and got deleted first before we get a chance to delete ourselves, which is not nice but nothing nefarious will happen.
                        // TODO: FIND NEFARIOUS THINGS THAT COULD HAPPEN.
                        println("This assets project was probably deleted just now.")
                    }
                }
                
                self.updateDropdownListTitles()
                self.delegate?.projectToolbarDidChangeProject(nil)
                
            case .DirectoryInitializationFailedAsPathDoesNotExist:
                println("Initialization failed cause the path we want to observe does not exist")
                
            case .DirectoryUnknownOperationForUnresolvedPath:
                println("We couldnt open the filde to process the change operation")
                
            default:
                println("Default")
            }
            
        }
        
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
