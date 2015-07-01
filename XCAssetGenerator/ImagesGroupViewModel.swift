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
    private let contentChanged: MutableProperty<Void>
    private let storage: PathStorage = PathStorage()

    let label: MutableProperty<String>
    let currentSelectionValid: MutableProperty<Bool>
    let observer: FileSystemImagesObserver

    var selectionSignal: SignalProducer<[Asset]?, NoError> {
        return selection.producer
            |> map { $0.asAssets() }
    }
    
    var contentSignal: SignalProducer<Void, NoError> {
        return contentChanged.producer
    }
    
    init() {
        
        self.selection = MutableProperty(storage.load())
        self.label = MutableProperty<String>("Xcode Slices")
        self.currentSelectionValid = MutableProperty(false)
        self.contentChanged = MutableProperty<Void>()
        self.observer = FileSystemImagesObserver()
        
        currentSelectionValid <~ selection.producer |> map { _ in return self.isCurrentSelectionValid() }
        label <~ selection.producer |> map { _ in return self.labelForCurrentSelection() }
        
        selection <~ observer.selectionSignal
        contentChanged <~ observer.contentChangedSignal
        
        selection.producer
            |> throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
            |> on(next: { s in
                self.storage.store(s)
                self.observer.observe(s)
            })
            |> start()
    }
    
    func labelForCurrentSelection() -> String {
        return selection.value.analysis(
            ifNone: { "Image assets" },
            ifImages: { $0.count == 1 ? $0[0].lastPathComponent : "Multiple Images" },
            ifFolder: { $0.lastPathComponent })
    }
    
    func shouldAcceptSelection(paths: [Path]) -> Bool {
        if paths.count == 1 {
            return paths.filter { isSupportedImage($0) || self.isValidPath($0) }.count > 0
        } else {
            return paths.filter(isSupportedImage).count > 0
        }
    }
    
    func acceptableItemsOfSelection(path: [Path]) -> Int {
        if path.count == 1 {
            return 1
        }
        return path.filter(isSupportedImage).count
    }
    
    func assetRepresentation() -> [Asset]? {
        return selection.value.asAssets()
    }

    private func isValidPath(path: Path) -> Bool {
        return PathValidator.directoryExists(path: path) && !path.isXCProject()
    }
    
    func newPathSelected(paths: [Path]) {
        // Which is more readable?
        // selection.put(.create(paths))
        paths |> ImageSelection.create |> selection.put
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
    
}

struct PathStorage {
    private let SelectionKey = "com.sourcebits.AssetGenerator.ImagesStorageKey"
    func store(selection: ImageSelection) {
        if let serialized = selection.serialized {
            NSUserDefaults.standardUserDefaults().setObject(serialized, forKey: SelectionKey)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(SelectionKey)
        }
    }
    
    func load() -> ImageSelection {
        let srlz = NSUserDefaults.standardUserDefaults().objectForKey(SelectionKey) as? [Bookmark]
        let selection = ImageSelection.deserialize(srlz)
        store(selection)
        return selection
        
        // Make sure the current selected project is valid and adjust the selection state accordingly.
        // Filter out invalid/corrupted projects
    }
}
