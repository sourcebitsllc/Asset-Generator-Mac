//
//  ImagesGroupViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa

class ImagesGroupViewModel {
    private let selection: MutableProperty<ImageSelection>
    let label: MutableProperty<String>
    let currentSelectionValid: MutableProperty<Bool>
    
    private let contentChanged: MutableProperty<Void>
    
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
        return selection.value.analysis(
            ifNone: { "Slices Folder" },
            ifImages: { $0.count == 1 ? $0[0].lastPathComponent : "Multiple Images" },
            ifFolder: { $0.lastPathComponent })
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
    
    func assetRepresentation() -> [Asset]? {
        return selection.value.analysis(
            ifNone: { nil },
            ifImages: { $0.map { Asset(fullPath: $0, ancestor: $0.stringByDeletingLastPathComponent) } },
            ifFolder: { folder in PathQuery.availableImages(from: folder).map { Asset(fullPath: $0, ancestor: folder)}})
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
        // Which is more readable?
        // selection.put(.create(paths))
        paths |> ImageSelection.create |> selection.put
//        self.path.put(path + "/")
    }
    
    func isCurrentSelectionValid() -> Bool {
        return selection.value.analysis(
            ifNone: { _ in false },
            ifImages: { _ in true },
            ifFolder: { _ in true })
    }
    
    func systemImageForCurrentPath() -> NSImage? {
        return selection.value.analysis(
            ifNone: { nil },
            ifImages: { NSImage.systemImageForGroup($0) },
            ifFolder: { NSImage.systemImage($0) })
    }
    
    func clearSelection() {
        selection.put(.None)
    }
    
    func urlRepresentation() -> [NSURL] {
        return selection.value.analysis(
            ifNone: { [] },
            ifImages: { $0.map { NSURL(fileURLWithPath: $0)! }},
            ifFolder: { [NSURL(fileURLWithPath: $0)!] })
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
