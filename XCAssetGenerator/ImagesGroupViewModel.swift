//
//  ImagesGroupViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa

enum ImageSelection: Printable, Serializable {
    case Images([Path])
    case Folder(Path)
    case None
    
    static func create(path: Path) -> ImageSelection {
        return isSupportedImage(path) ? .Images([path]) : PathValidator.directoryExists(path: path) ? .Folder(path) : .None
    }
    
    static func create(paths: [Path]) -> ImageSelection {
        if paths.count == 1 {
            return create(paths[0])
        }
        let acceptable = paths.filter(isSupportedImage)
        return acceptable.count > 0 ? .Images(acceptable) : .None
    }
    
    func asAssets() -> [Asset] {
        switch self {
        case .None:
            return []
        case .Images(let images):
            return images.map { Asset(fullPath: $0, ancestor: $0.stringByDeletingLastPathComponent) }
        case .Folder(let folder):
            return PathQuery.availableImages(from: folder).map { Asset(fullPath: $0, ancestor: folder) }
        }
    }
    
    var description: String {
        switch self {
        case .None:
            return "None:"
        case .Images(let path):
            return "Image: \(path)"
        case .Folder(let folder):
            return "Folder: \(folder)"
        }
    }
    
    typealias Serialized = [Bookmark]?
    
    var serialized: Serialized {
        switch self {
        case .None:
            return nil
        case .Images(let i):
            return i.map(BookmarkResolver.resolveBookmarkFromPath)
        case .Folder(let f):
            return [BookmarkResolver.resolveBookmarkFromPath(f)]
        }
    }
    
    static func deserialize(serial: Serialized) -> ImageSelection {
        if let s = serial {
            let paths = s.map(BookmarkResolver.resolvePathFromBookmark).filter { $0 != nil }.map{ $0! } as [Path]
            return create(paths)
        } else {
            return .None
        }
    }
    
}

// RAC3 TODO: Remove NSObject

class ImagesGroupViewModel {
    private let selection: MutableProperty<ImageSelection>
    let label: MutableProperty<String>
    let currentSelectionValid: MutableProperty<Bool>
    
    private let contentChanged: MutableProperty<Void>
    // let image
    // let colors
    
    var selectionSignal: SignalProducer<ImageSelection, NoError> {
        return selection.producer
    }
    var contentSignal: SignalProducer<Void, NoError> {
        return contentChanged.producer
    }
    
    let systemObserver: FileSystemSignal
    private let storage: PathStorage = PathStorage()
    
    init() {
        
        self.selection = MutableProperty(storage.load())
        self.label = MutableProperty<String>("Xcode Slices")
        self.currentSelectionValid = MutableProperty(false)
        self.contentChanged = MutableProperty<Void>()
        self.systemObserver = FileSystemSignal()

        currentSelectionValid <~ selection.producer |> map { _ in return self.isCurrentSelectionValid() }
        label <~ selection.producer |> map { _ in return self.labelForCurrentSelection() }
        
//        
//        path <~ systemObserver.renameSignal |> map { Optional($0) }
//        path <~ systemObserver.deleteSignal |> map { nil }
//        contentChanged <~ systemObserver.contentChangedSignal |> throttle(0.5, onScheduler: QueueScheduler(priority: 0, name: ""))
        
        
        selection.producer
            |> observeOn(QueueScheduler(priority: DISPATCH_QUEUE_PRIORITY_LOW, name: "StoreAndObserveQueue"))
            |> on(next: { s in
                self.storage.store(s)
//                self.observe(path)
            })
            |> start()
    }
    
    func labelForCurrentSelection() -> String {
        switch selection.value {
        case .None:
            return "Xcode Slices"
        case .Folder(let path):
            return path.lastPathComponent
        case .Images(let images):
            return images.count == 1 ? images[0].lastPathComponent : "Multiple Images"
        }
    }
    
    func shouldAcceptSelection(paths: [Path]) -> Bool {
        if paths.count == 1 {
            return paths.filter { isSupportedImage($0) || self.isValidPath($0) }.count > 0
        } else {
            return paths.filter {isSupportedImage($0)}.count > 0
        }
    }
    
    func acceptableItemsOfSelection(path: [Path]) -> Int {
        if path.count == 1 {
            return 1
        }
        return path.filter(isSupportedImage).count
    }
    
    func assetRepresentation() -> [Asset] {
        switch selection.value {
        case .None:
            return []
        case .Images(let images):
            return images.map { Asset(fullPath: $0, ancestor: $0.stringByDeletingLastPathComponent) }
        case .Folder(let folder):
            return PathQuery.availableImages(from: folder).map { Asset(fullPath: $0, ancestor: folder) }
        }
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
    
    func newPathSelected(paths: [Path]) {
//        let selection = ImageSelection.create(paths)
        // Which is more readable?
//        selection.put(.create(paths))
        paths |> ImageSelection.create |> selection.put
//        ImageSelection.create(paths) |> selection.put
//        self.selection.put(selection)
//        self.path.put(path + "/")
    }
    
    func isCurrentSelectionValid() -> Bool {
        switch selection.value {
        case .None:
            return false
        default:
            return true
        }
    }
    
    func systemImageForCurrentPath() -> NSImage {
        switch selection.value {
        case .Folder(let path):
            return NSImage.systemImage(path)
        case .Images(let paths):
            return NSImage.systemImageForGroup(paths)
        default:
            fatalError("wu")
        }
        
    }
    
    func clearSelection() {
        selection.put(.None)
    }
    
    func urlRepresentation() -> [NSURL] {
        switch selection.value {
        case .None:
            return []
        case .Images(let images):
            return images.map { NSURL(fileURLWithPath: $0)! }
        case .Folder(let folder):
            return [NSURL(fileURLWithPath: folder)!]
        }
    }
    
    struct PathStorage {
        func store(selection: ImageSelection) {
            if let serialized = selection.serialized {
                NSUserDefaults.standardUserDefaults().setObject(serialized, forKey: "ImagesFolderWuzHere")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("ImagesFolderWuzHere")
            }
        }
        
        func load() -> ImageSelection {
            let srlz = NSUserDefaults.standardUserDefaults().objectForKey("ImagesFolderWuzHere") as? [Bookmark]
            let selection = ImageSelection.deserialize(srlz)
            store(selection)
            return selection
            
            // Make sure the current selected project is valid and adjust the selection state accordingly.
            // Filter out invalid/corrupted projects
        }
    }
    
    
}
