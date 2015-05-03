//
//  PathQuery.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/5/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

struct PathQuery {

    static func availableImages(from path: Path) -> [Path] {
        return queryWith(path, searchOption: NSDirectoryEnumerationOptions.SkipsHiddenFiles) {
            return $0.hasSuffix(".png") || $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg")
        }
    }
    
    static func availableAssetSets(from path: Path) -> [Path] {
        return queryWith(path, searchOption: NSDirectoryEnumerationOptions.SkipsPackageDescendants) {
            return $0.hasSuffix(".imageset") || $0.hasSuffix(".appiconset") || $0.hasSuffix(".launchimage")
        }
    }

    static func availableAssetCatalogs(from path: Path) -> [Path] {
        return queryWith(path, searchOption: NSDirectoryEnumerationOptions.SkipsPackageDescendants) {
            return $0.isAssetCatalog()
        }
    }

    private static func queryWith(path: Path,  searchOption: NSDirectoryEnumerationOptions, query: Path -> Bool) -> [Path] {
        let url = NSURL(fileURLWithPath: path, isDirectory: true)
        let generator = NSFileManager.defaultManager().enumeratorAtURL(url!, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: searchOption , errorHandler: nil)
        
        let list = generator?.allObjects as? [NSURL]
        let result = list?.map{$0.path!}.filter(query)
        return result ?? []
    }
    
}