//
//  ImagesGroupViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa

//enum SelectionStatus {
//    case Valid
//    case Invalid
//    case Processing
//}

// RAC3 TODO: Remove NSObject

class ImagesGroupViewModel {
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
    let ImageSize = NSSize(width: 80, height: 80)
    
    init() {
        
        self.path = MutableProperty<Path?>(storage.load())
        self.label = MutableProperty<String>("Xcode Slices")
        self.currentPathValid = MutableProperty(false)
        self.contentChanged = MutableProperty<Void>()
        self.systemObserver = FileSystemSignal()

        currentPathValid <~ path.producer |> map { $0 != nil }
        label <~ path.producer |> map { $0?.lastPathComponent ?? "Xcode Slices" }
        
        
        path <~ systemObserver.renameSignal |> map { Optional($0) }
        path <~ systemObserver.deleteSignal |> map { nil }
        contentChanged <~ systemObserver.contentChangedSignal |> throttle(0.5, onScheduler: QueueScheduler(priority: 0, name: ""))
        
        
        path.producer
            |> observeOn(QueueScheduler(priority: DISPATCH_QUEUE_PRIORITY_LOW, name: "StoreAndObserveQueue"))
            |> on(next: { path in
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
            systemObserver.cancel()
        }
    }
    
    func newPathSelected(path: Path) {
        self.path.put(path + "/")
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
