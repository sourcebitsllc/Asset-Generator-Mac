//
//  PathQuery.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/5/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

func isSupportedImage(path: Path) -> Bool {
    return path.hasSuffix(".png") || path.hasSuffix(".jpg") || path.hasSuffix(".jpeg")
}

struct PathQuery {

    static func availableImages(from path: Path) -> [Path] {
        return queryWith(path, searchOption: NSDirectoryEnumerationOptions.SkipsHiddenFiles) {
            return isSupportedImage($0)
        }
    }
    
    static func availableAssetSets(from path: Path) -> [Path] {
        return queryWith(path, searchOption: NSDirectoryEnumerationOptions.SkipsPackageDescendants) {
            return $0.isAssetSet()
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