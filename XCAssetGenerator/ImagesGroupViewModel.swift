//
//  ImagesGroupViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa

enum SelectionStatus {
    case Valid
    case Invalid
    case Processing
}

// RAC3 TODO: Remove NSObject

class ImagesGroupViewModel: NSObject {
    private let path: MutableProperty<Path?>
    let label: MutableProperty<String>
    let currentPathValid: MutableProperty<Bool>
    
    private let contentChanged: MutableProperty<Void>
    // let image
    // let colors
    
    var pathSignal: SignalProducer<Path?, NoError> {
        return path.producer
    }
    var contentSignal: SignalProducer<Void, NoError> {
        return contentChanged.producer
    }
    
    let systemObserver: FileSystemSignal
    private let storage: PathStorage = PathStorage()
    
    // Constants
    let ImageSize = NSSize(width: 100, height: 100)
    
    override init() {
        
        self.path = MutableProperty<Path?>(storage.load())
        self.label = MutableProperty<String>("Xcode Slices")
        self.currentPathValid = MutableProperty(false)
        self.contentChanged = MutableProperty<Void>()
        self.systemObserver = FileSystemSignal()
        super.init()

        currentPathValid <~ path.producer |> map { $0 != nil }
        label <~ path.producer |> map { $0?.lastPathComponent ?? "Xcode Slices" }
        
        
        path <~ systemObserver.renameSignal |> map { Optional($0) }
        path <~ systemObserver.deleteSignal |> map { nil }
        contentChanged <~
            systemObserver.contentChangedSignal
            |> throttle(0.5, onScheduler: QueueScheduler(priority: 0, name: ""))
        
        
        path.producer
//            |> throttle(0, onScheduler: QueueScheduler(priority: DISPATCH_QUEUE_PRIORITY_LOW, name: "ImagesStore"))
            |> observeOn(QueueScheduler(priority: DISPATCH_QUEUE_PRIORITY_LOW, name: "StoreAndObserveQueue"))
            |> on(next: { path in
                println("IMAGESVMS path changed: storing -> observing")
                self.storage.store(path)
                self.observe(path)
            })
            |> start()
    }
    
    func shouldAcceptPath(path: Path) -> Bool {
        return isValidPath(path)
    }
    
    private func isValidPath(path: Path) -> Bool {
        return PathValidator.directoryExists(path: path) && !path.isXCProject()
    }
    private func observe(path: Path?) {
        if let path = path {
            systemObserver.observe(path)
        } else {
            println("Producer cancel")
            systemObserver.cancel()
        }
    }
    
    func newPathSelected(path: Path) {
        self.path.put(path + "/")
//        systemObserver.observe(self.path.value!)
//        folder = filePath + "/"
//        setupValidDrop(folder!)
//        directoryObserver.observeSource(folder!)
//        delegate?.imagesDropControllerDidSetFolder(self, path: folder)
//        storeRecentProjects()
//        storage.store(self.path.value)
    }
    
    func isCurrentPathValid() -> Bool {
        if let path = path.value {
            return isValidPath(path)
        } else {
            return false
        }
    }
    
    func systemImageForCurrentPath() -> NSImage {
        return NSImage.systemImage(path.value!, size: ImageSize)
    }
    
//    func currentColor() -> NSColor {
//        
//    }
//    
//    private func colorForPath(path: Path?) -> NSColor {
//        if let path = path {
//            if isValidPath(path) {
//                return NSColor.validDropColor()
//            } else {
//                return NSColor.invalidDropColor()
//            }
//        }
//    }
    
    func test_put() {
        let v = path.value
        path.put(v)
    }
    
    struct PathStorage {
        func store(path: Path?) {
            if let path = path {
                NSUserDefaults.standardUserDefaults().setObject(path, forKey: "ImagesFolderWuzHere")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("ImagesFolderWuzHere")
            }

        }
        
        func load() -> Path? {
            let value = NSUserDefaults.standardUserDefaults().objectForKey("ImagesFolderWuzHere") as? Path
            store(value)
            return value
            
            // Make sure the current selected project is valid and adjust the selection state accordingly.
            // Filter out invalid/corrupted projects
        }
    }
    
    
}


//
//extension ImagesGroupViewModel: FileSystemObserverDelegate {
//    func FileSystemDirectoryDeleted(path: String!) {
//        // RAC3 TODO:
//        directoryObserver.stopObservingPath(path)
//        folder = nil
//        dropView.layer?.borderColor = dropView.layer?.backgroundColor
//        delegate?.imagesDropControllerDidSetFolder(self, path: folder)
//        storeRecentProjects()
//
//    }
//    
//    func FileSystemDirectoryError(error: NSError!) {
//        // RAC3 TODO:
//    }
//    
//    func FileSystemDirectory(oldPath: String!, renamedTo newPath: String!) {
//        // RAC3 TODO:
//        directoryObserver.updatePathForObserver(oldPath: oldPath, newPath: newPath)
//        folder = newPath + "/"
//        delegate?.imagesDropControllerDidSetFolder(self, path: folder)
//        storeRecentProjects()
//    }
//    
//    func FileSystemDirectoryContentChanged(root: String!) {
//        // RAC3 TODO:
//        delegate?.imagesDropControllerFolderContentChanged(self)
//        if let folder = folder {
//            setupValidDrop(folder)
//        }
//    }
//}

/*

    class imagesDropVM {
        // VC will bind to path. Even the parent VM will want to observe the path
        var path: Path MODEL
        // I dont think its necessary to observe the label. Actually it is if we want to hide the model and not have the VC worry about it.
        var label
        var dropImage
        var dropColors : MAYBE NOT?

        let StorageManager.
        + Handle Loading and Storing result.

        func shouldAcceptDrop(path) -> Bool {
        }

        func newPathDropped(path) -> Void {

        }

        + Handle FileSystemObserver changes.
        + Can i observe NSFileWrapper? that would be something!

        func SystemImageForPath(path) -> NSImage {
        }

        + Maybe expose method to specify the presentation state for given path. Like
        ENUM DROPSTATE
        i could have the controller observe this.
        or i can have a method which returns the DROPSTATE which allows the controller to setup it sshot
        func StageForPath(path) -> DROPSTATE {
        if path == nil {	return NOTYET }
        else return SET
        // The whole idea being: Help Controller determine dropViewDidDragFileOut without exposing the model.
    }

    }
*/