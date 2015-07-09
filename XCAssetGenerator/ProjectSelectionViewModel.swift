//
//  ProjectSelectionViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa

class ProjectSelectionViewModel {
    private let project: MutableProperty<XCProject?>
    private let contentChanged: MutableProperty<Void>
    private let storage: ProjectStorage
    private let observer: FileSystemProjectObserver
    
    let label: MutableProperty<String>
    let currentSelectionValid: MutableProperty<Bool>

    var selectionSignal: SignalProducer<AssetCatalog?, NoError> {
        return project.producer |> map { $0?.catalog }
    }
    
    var contentSignal: SignalProducer<Void, NoError> {
        return contentChanged.producer
    }
    
    var currentCatalog: AssetCatalog? {
        return project.value?.catalog
    }
    
    init() {
        storage = ProjectStorage()
        project = MutableProperty(storage.loadRecentProject())
        currentSelectionValid = MutableProperty(false)
        label = MutableProperty("Xcode Project")
        
        contentChanged = MutableProperty()
        observer = FileSystemProjectObserver()
        

        currentSelectionValid <~ project.producer |> map { $0 != nil }
        
        project <~ observer.projectSignal
        project <~ observer.catalogSignal |> map { catalog in
            if let project = self.project.value where project.ownsCatalog(catalog) {
                return XCProject(path: project.path)
            } else { return nil }
        }
 
        contentChanged <~ observer.catalogContentSignal
        
        project.producer
            |> throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
            |> on(next: { project in
                self.storage.storeRecentProject(project)
                self.observer.observe(project)
            })
            |> start()
        
        
        label <~ project.producer |> map { $0?.title ?? "Xcode Project" }
    }
    
    
    func shouldAcceptPath(path: [Path]) -> Bool {
        return path.count == 1 && path[0].isXCProject() && PathValidator.directoryContainsXCAsset(directory: path[0].stringByDeletingLastPathComponent + ("/"))
    }
    
    private func isValidSelection(project: XCProject) -> Bool {
        return ProjectValidator.isProjectValid(project) && project.hasValidAssetsPath()
    }
    
    func isCurrentSelectionValid() -> Bool {
        return project.value.map(isValidSelection) ?? false
    }
    
    func systemImageForCurrentPath() -> NSImage? {
        return project.value.flatMap { NSImage.systemImage($0.path) }
    }
    
    private func forceSyncSelectionValidity() {
        currentSelectionValid.put(currentSelectionValid.value)
    }
    
    func newPathSelected(path: Path) {
        SignalProducer(result: ProjectSelector.excavateProject(path))
            |> startOn(QueueScheduler(priority: DISPATCH_QUEUE_PRIORITY_DEFAULT, name: "StoreAndObserveQueue"))
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> start(error: { error in
                self.forceSyncSelectionValidity()
            }, next: { project in
                self.project.put(project)
            })
    }
    
    
    func clearSelection() {
        project.put(nil)
    }
    
    func urlRepresentation() -> NSURL? {
        return project.value.flatMap { NSURL(fileURLWithPath: $0.path) }
    }
}


// TODO: Find new home for this.
func setupError(message: String) -> NSAlert {
    let alert = NSAlert()
    alert.messageText = message
    alert.addButtonWithTitle("OK")
    alert.alertStyle = NSAlertStyle.CriticalAlertStyle
    return alert
}

//// Refactor. TODO:
struct ProjectStorage {
    private let ProjectKey = "RecentlySelectedProject"
    
    private func storeRecentProject(project: XCProject?) {
        if let project = project {
            NSUserDefaults.standardUserDefaults().setObject(project.serialized, forKey: ProjectKey)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(ProjectKey)
        }
    }
    
    
    ///
    private func loadRecentProject() -> XCProject? {
        let projectDict = NSUserDefaults.standardUserDefaults().objectForKey(ProjectKey) as? [String: NSData]
        var project: XCProject? = nil
        func validProject(dict: [String: NSData]) -> Bool {
            let validPath =  BookmarkResolver.isBookmarkValid(dict[PathKey])
            let validAsset = BookmarkResolver.isBookmarkValid(dict[AssetPathsKey])
            return validPath && validAsset
        }
        if let dict = projectDict where validProject(dict) {
            project = dict |> XCProject.projectFromDictionary
        }
                
        storeRecentProject(project)
        // Make sure the current selected project is valid and adjust the selection state accordingly.
        // Filter out invalid/corrupted projects
        return project
    }
}
