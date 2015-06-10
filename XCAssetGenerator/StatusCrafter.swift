//
//  StatusViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

struct StatusCrafter {

    static func postGeneration(catalog: Path, amount: Int) -> String {
        let s = pluralize(amount, singular: "asset was", plural: "assets were")
        return "\(s) added to \(catalog)"
    }
    
    static func status(source: Path?, target: XCProject?) -> String {
        let status: String
        switch (source, target?.catalog?.path) {
            
        case (.Some(let folder), .Some(let catalog)):
            let assets = InputAnalyzer.newAssets(folder, catalog: catalog)
            let n = pluralize(assets, singular: "new asset", plural: "new assets")
            status =  "Hit Build to add \(n) to your project"
        
        case (_,_):
            status = "Drop a folder with slices you'd like to add to your Xcode project"
        
        case (.Some(let folder), .None):
            break
            // TODO
        case (.None, .Some(let catalog)):
            break
        }
        
        return status
    }
}


struct InputAnalyzer {
    static func newAssets(folder: Path, catalog: Path) -> Int {
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
}

// TODO: Find better abstraction. Maybe somehting long the lines of new, found, missing.
struct AssetDiff {
    
    /// Assets available in folder but not catalog.
    /// NOTE: Comparison done on filename basis.
    static func new(folder: Path, catalog: Path) -> [Path] {
        return operateWith(folder, catalog: catalog) { a,b in return a.subtract(b) }
    }
    
    /// Assets available in both folder and catalog.
    static func common(folder: Path, catalog: Path) -> [Path] {
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


