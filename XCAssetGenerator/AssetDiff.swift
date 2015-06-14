//
//  AssetDiff.swift
//  XCAssetGenerator
//
//  Created by Bader on 6/14/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa

struct AssetDiff {
    
    enum DiffOperation {
        // Assets found both in source and destination.
        case CommonAssets
        // Assets found in source but not destination.
        case NewAssets
        // Assets found in destination but not source.
        case MissingAssets
    }
    
    //    private static let f = NSFileManager()
    
    static func diffWithOperation(source: [Asset], catalog: AssetCatalog)(operation: DiffOperation) -> Int {
        let s = source.map { AssetDiff.Comparison(path: $0.fullPath, key: $0.fullPath.remove([$0.ancestor.removeTrailingSlash()])) }
        
        let c = PathQuery.availableImages(from: catalog.path).map { path in
            return AssetDiff.Comparison(path: path, key: path.remove([catalog.path]).removeAssetSetsComponent())
        }
        
        switch operation {
        case .NewAssets:
            return new(s, target: c)
        case .CommonAssets:
            return common(s, target: c)
        case .MissingAssets:
            return missing(s, target: c)
        }
        
    }
    
    // MARK - Private
    private struct Comparison {
        let path: Path
        let key: String
    }
    
    private static func common(source: [Comparison], target: [Comparison]) -> Int {
        let f = NSFileManager()
        var total = 0
        for c in target {
            total += source.filter { $0.key == c.key && f.contentsEqualAtPath($0.path, andPath: c.path) }.count
        }
        return total
    }
    
    private static func new(source: [Comparison], target: [Comparison]) -> Int {
        var new = 0
        let f = NSFileManager()
        // Inefficient. I'm too lazy to write an imparative loop right now. TODO: Swift 2.0, indexOf {}
        for s in source {
            new += target.filter { $0.key == s.key && f.contentsEqualAtPath($0.path, andPath: s.path) }.count == 0 ? 1 : 0
        }
        return new
    }
    
    private static func missing(source: [Comparison], target: [Comparison]) -> Int {
        var new = 0
        // Inefficient. I'm too lazy to write an imparative loop right now. TODO: Swift 2.0, indexOf {}
        for s in target {
            new += source.filter { $0.key == s.key }.count == 0 ? 1 : 0
        }
        return new
    }
}
