//
//  SelectedProjectViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct SelectedProjectViewModel {
    private let project: MutableProperty<XCProject?>
    private let contentChanged: MutableProperty<Void>
    
    let label: MutableProperty<String>
    let currentSelectionValid: MutableProperty<Bool>
    // let image
    // let colors
    var projectSignal: SignalProducer<XCProject?, NoError> {
        return project.producer
    }
    
    var contentSignal: SignalProducer<Void, NoError> {
        return contentChanged.producer
    }
    
    var currentCatalog: /*AssetCatalog*/ Path? {
        return project.value?.assetTitle
    }
    
    let projectObserver: FileSystemSignal
    let catalogObserver: FileSystemSignal
    let storage: ProjectStorage
    
    // Constants
    let ImageSize = NSSize(width: 100, height: 100)
    
    init() {
        storage = ProjectStorage()
        project = MutableProperty(storage.loadRecentProject())
        label = MutableProperty("Xcode Project")
        currentSelectionValid = MutableProperty(false)
        contentChanged = MutableProperty()
        
        projectObserver = FileSystemSignal()
        catalogObserver = FileSystemSignal()
        
        currentSelectionValid <~ project.producer |> map { $0 != nil }
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
            catalogObserver.observe(project.assetPath!)
        } else {
            println("Producer cancel")
            projectObserver.cancel()
            catalogObserver.cancel()
        }
    }
    
    func shouldAcceptPath(path: Path) -> Bool {
        return path.isXCProject()
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
    
    func systemImageForCurrentPath() -> NSImage {
        return NSImage.systemImage(project.value!.path, size: ImageSize)
    }
    
    func newPathSelected(path: Path) {
        let project = ProjectSelector.circumsizeProject(path)
        switch project {
            case .Success(let box):
                self.project.put(box.value)
            case .Failure(let box):
                setupError(box.value.message).runModal()
        }
//        project.put(XCProject(path: path))
//        storage.storeRecentProject(project.value)
        // Store the project
        // Observe the new project. (stop observing old also)
        // Store the new project
        // /////////////////////////////////
//        if selectedProject != nil {
//            directoryObserver.stopObservingProject(selectedProject!)
//        }
//        setupValidDrop(filePath)
//        selectedProject = XCProject(path: filePath)
//        delegate?.projectDropControllerDidSetProject(self, project: selectedProject)
//        storeRecentProjects()
//        
//        directoryObserver.observeProject(selectedProject!)
    }
    
    private func setupError(message: String) -> NSAlert {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButtonWithTitle("OK")
        alert.alertStyle = NSAlertStyle.CriticalAlertStyle
        return alert
    }
}

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
        let projectDicts = NSUserDefaults.standardUserDefaults().objectForKey("ProjectsWuzzHurr") as? [String: NSData]
        var project: XCProject? = nil
        func validProject(dict: [String: NSData]) -> Bool {
            let validPath =  BookmarkResolver.isBookmarkValid(dict[PathKey])
            let validAsset = BookmarkResolver.isBookmarkValid(dict[AssetPathsKey])
            return validPath && validAsset
        }
        if let dict = projectDicts {
            project = dict |> XCProject.projectFromDictionary
        }
        
        storeRecentProject(project)
        // Make sure the current selected project is valid and adjust the selection state accordingly.
        // Filter out invalid/corrupted projects
        return project
//        storeRecentProjects()
    }
}
//
//extension SelectedProjectViewModel: FileSystemObserverDelegate {
//    func FileSystemDirectoryDeleted(path: String!) {
//        //        updateDropView(state: DropViewState.PathNoLongerExists)
//        directoryObserver.stopObservingPath(path)
//        selectedProject = nil
//        dropView.layer?.borderColor = dropView.layer?.backgroundColor
//        delegate?.projectDropControllerDidSetProject(self, project: nil)
//        storeRecentProjects()
//    }
//    
//    
//    func FileSystemDirectory(oldPath: String!, renamedTo newPath: String!) {
//        directoryObserver.updatePathForObserver(oldPath: oldPath, newPath: newPath)
//        //        folder = newPath
//        //        updateDropView(state: DropViewState.SuccessfulDrop)
//        if oldPath.isXCProject() {
//            selectedProject = XCProject(path: newPath)
//        } else if oldPath.isAssetCatalog() {
//            selectedProject = XCProject(path: selectedProject!.path)
//        }
//        delegate?.projectDropControllerDidSetProject(self, project: selectedProject)
//        storeRecentProjects()
//    }
//    
//    func FileSystemDirectoryError(error: NSError!) {
//        // TODO:
//    }
//    
//    func FileSystemDirectoryContentChanged(root: String!) {
//        delegate?.projectDropControllerAssetCatalogContentChanged(self)
//    }
//}

/*

class ProjectDropVM {
    //
    var project: XCProject MODEL
    var label
    var dropImage: MAYBE?
    var dropColors: MAYBE NOT?

    + Load and Store operations

    + FileSystem observer operations.

    func shouldAcceptDraggedPath(Path) -> Bool

    func newProjectDropped(path) -> Void

    + Maybe expose method to specify the presentation state for given path. Like
    ENUM DROPSTATE
    i could have the controller observe this.
    or i can have a method which returns the DROPSTATE which allows the controller to setup it sshot
    func StageForPath(path) -> DROPSTATE {
    if path == nil {	return NOTYET }
    else return SET
    }
    The whole idea being: Help Controller determine dropViewDidDragFileOut without exposing the model.
}

*/