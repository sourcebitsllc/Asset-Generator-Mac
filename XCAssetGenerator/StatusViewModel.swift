//
//  StatusViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct StatusViewModel {
    let status: MutableProperty<String>
    var a: Int = 0
    init(images: MutableProperty<Path?>, project: MutableProperty<XCProject?>, generation: Signal<Int, NoError>) {
        self.status = MutableProperty("Drop a folder with slices you'd like to add to your Xcode project")

        self.status <~ combineLatest(images.producer, project.producer)
            |> map { path, project in
                return self.statusForState(path, target: project?.assetPath)
            }
        
//        self.status <~ generation |> map { total in
//            return self.statusForPostGeneration(project.value!.assetTitle, amount: total)
//        }
    }
    
    static func postGeneration(catalog: Path, amount: Int) -> String {
        let s = pluralize(amount, singular: "asset was", plural: "assets were")
        return "\(s) added to \(catalog)"
    }
    
    private func statusForState(source: Path?, target: Path?) -> String {
        let status: String
        switch (source, target) {
            
        case (.Some(let folder), .Some(let catalog)):
            let assets = detectNewAssets(folder, catalog: catalog)
            let n = pluralize(assets, singular: "new asset", plural: "new assets")
            status =  "Hit Build to add \(n) to your project"
        case (_,_):
             status = "Drop a folder with slices you'd like to add to your Xcode project"
        case (.Some(let folder), .None):
            break
            // TODO
        case (.None, .Some(let catalog)):
            break
            // TODO
        }
        
        return status
    }
    
    static func status(source: Path?, target: XCProject?) -> String {
        let status: String
        switch (source, target?.assetPath) {
            
        case (.Some(let folder), .Some(let catalog)):
            let assets = detectNewAssets(folder, catalog: catalog)
            let n = pluralize(assets, singular: "new asset", plural: "new assets")
            status =  "Hit Build to add \(n) to your project"
        case (_,_):
            status = "Drop a folder with slices you'd like to add to your Xcode project"
        case (.Some(let folder), .None):
            break
            // TODO
        case (.None, .Some(let catalog)):
            break
            // TODO
        }
        
        return status
    }
}

func detectNewAssets(folder: Path, #catalog: Path) -> Int {
    let t = NSDate()
    let diff = AssetDiff.new(folder, catalog: catalog).count
    let common = AssetDiff.common(folder, catalog: catalog)
    
    let catalogImages = PathQuery.availableImages(from: catalog)
    let commonNames: [(Path, Path)] = catalogImages.flatMap { path in
        let n = path.remove([catalog]).removeAssetSetsComponent()
        return contains(common, n) ? [(folder.removeTrailingSlash() + n, path)] : []
    }
    
    let f = NSFileManager()
    let matches = commonNames.filter { t in
        return f.contentsEqualAtPath(t.0, andPath: t.1)
    }
    return diff + (common.count - matches.count)
}

func pluralize(amount: Int, #singular: String, #plural: String) -> String {
    switch amount {
    case 1:
        return "1 \(singular)"
    case let a:
        return "\(a) \(plural)"
    }
}

// TODO: Find better abstraction. Maybe somehting long the lines of new, found, missing.
struct AssetDiff {
    
    /// Assets available in folder but not catalog.
    /// NOTE: Comparison done on filename basis. (diff?)
    static func new(folder: Path, catalog: Path) -> [Path] {
        return operateWith(folder, catalog: catalog) { a,b in return a.subtract(b) }
    }
    
    /// Assets available in both folder and catalog.
    static func common(folder: Path, catalog: Path) -> [Path] {
        let common = operateWith(folder, catalog: catalog) { a,b in return a.intersect(b) }
        let folderNames = common.map { folder + $0 }
        
        //        let ut = names.map { return (folder + $0, catalog +
        return operateWith(folder, catalog: catalog) { a,b in return a.intersect(b) }
    }
    
    /// Assets available in catalog but not folder.
    static func missing(folder: Path, catalog: Path) -> [Path] {
        return operateWith(folder, catalog: catalog) { a,b in return b.subtract(a) }
    }
    
    static private func operateWith(folder: Path, catalog: Path, f: (Set<Path>,Set<Path>) -> Set<Path>) -> [Path] {
        let source = PathQuery.availableImages(from: folder).map { $0.remove([folder.removeTrailingSlash()]) }
        let target = PathQuery.availableImages(from: catalog).map { $0.remove([catalog]).removeAssetSetsComponent() }
        let setA = Set(source)
        let setB = Set(target)
        let result = f(setA, setB)
        return Array(result)
    }
}

//
//func assetGenerationFinished(generated: Int) {
//    
//    progressController.resetProgress {
//        self.updateGenerateButton()
//        //            self.updateState()
//        //            self.fileDropController.displayDoneState(generated)
//        self.generateButton.title = "Build Again"
//        self.generateButton.sizeToFit()
//        let s = self.pluralize(generated, singular: "asset was", plural: "assets were")
//        let catalog = self.target!.lastPathComponent
//        self.statusLabel.stringValue = "\(s) added to \(catalog)"
//    }
//}
//
//private func pluralize(amount: Int, singular: String, plural: String) -> String {
//    switch amount {
//    case 1:
//        return "1 \(singular)"
//    case let a:
//        return "\(a) \(plural)"
//    }
//}
/*
class StatusViewModel {
    // This will bind to the status label
    var statusLabel
    var statusEnum
    
    // Als need to take into accunt AssetGeneration. Once generation is finished, transition into last label.
    init(image, project) {
        statusLabel = combineLatest(image, project) { if else if else get new assets if else }
    }
    
    
}
*/
