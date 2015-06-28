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
    
    let label: MutableProperty<String>
    let currentSelectionValid: MutableProperty<Bool>
    let projectObserver: FileSystemSignal
    let catalogObserver: FileSystemSignal
    let storage: ProjectStorage

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
        currentSelectionValid <~ project.producer |> map { $0 != nil }
        label = MutableProperty("Xcode Project")
        
        contentChanged = MutableProperty()
        
        projectObserver = FileSystemSignal()
        catalogObserver = FileSystemSignal()
        
        project <~ projectObserver.renameSignal |> map { XCProject(path: $0) }
        project <~ projectObserver.deleteSignal |> map { nil }
        
        project <~ catalogObserver.renameSignal |> map { catalog in
            if let project = self.project.value where project.ownsCatalog(catalog) {
                return XCProject(path: project.path)
            } else { return nil }
        }
        project <~ catalogObserver.deleteSignal |> map { nil }
        contentChanged <~ catalogObserver.contentChangedSignal
        
        project.producer
            |> observeOn(QueueScheduler(priority: DISPATCH_QUEUE_PRIORITY_LOW, name: "StoreAndObserveQueue"))
            |> on(next: { project in
                self.storage.storeRecentProject(project)
                self.observe(project)
            })
            |> start()
        
        
        label <~ project.producer |> map { $0?.title ?? "Xcode Project" }
    }
    
    private func observe(project: XCProject?) {
        if let project = project {
            projectObserver.observe(project.path)
            catalogObserver.observe(project.catalog!.path)
        } else {
            projectObserver.cancel()
            catalogObserver.cancel()
        }
    }
    
    func shouldAcceptPath(path: [Path]) -> Bool {
        return path.count == 1 && path[0].isXCProject() && PathValidator.directoryContainsXCAsset(directory: path[0].stringByDeletingLastPathComponent + ("/"))
    }
    
    private func isValidSelection(project: XCProject) -> Bool {
        return ProjectValidator.isProjectValid(project) && project.hasValidAssetsPath()
    }
    
    func isCurrentSelectionValid() -> Bool {
        if let project = project.value {
            return isValidSelection(project)
        } else {
            return false
        }
    }
    
    func systemImageForCurrentPath() -> NSImage? {
        return project.value != nil ? NSImage.systemImage(project.value!.path) : nil
    }
    
    private func forceSyncSelectionValidity() {
        currentSelectionValid.put(currentSelectionValid.value)
    }
    
    func newPathSelected(path: Path) {
//        let project = ProjectSelector.excavateProject(path)
//        switch project {
//            case .Success(let box):
//                self.project.put(box.value)
//            case .Failure(let box):
//                self.setupError(box.value.message).runModal()
//        }
        
        SignalProducer(result: ProjectSelector.excavateProject(path))
            |> startOn(QueueScheduler(priority: DISPATCH_QUEUE_PRIORITY_DEFAULT, name: "StoreAndObserveQueue"))
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> start(error: { error in
                setupError(error.message).runModal()
                self.forceSyncSelectionValidity()
            }, next: { project in
                self.project.put(project)
            })
    }
    
    
    func clearSelection() {
        project.put(nil)
    }
    
    func urlRepresentation() -> NSURL? {
        if let project = project.value {
            return NSURL(fileURLWithPath: project.path)
        }
        
        return nil
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
    private func storeRecentProject(project: XCProject?) {
        if let project = project {
            NSUserDefaults.standardUserDefaults().setObject(project.serialized, forKey: "ProjectsWuzzHurr")
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("ProjectsWuzzHurr")
        }
    }
    
    
    ///
    private func loadRecentProject() -> XCProject? {
        let projectDict = NSUserDefaults.standardUserDefaults().objectForKey("ProjectsWuzzHurr") as? [String: NSData]
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
