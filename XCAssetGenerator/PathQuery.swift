//
//  PathQuery.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/5/15.
//  Copyright (c) 2015 Pranav Shah. All rights reserved.
//

import Foundation

struct PathQuery {
    ///
    /// TODO: Documentation
    ///
    static func availableImages(from path: Path) -> [Path] {
        return queryWith(path, searchOption: NSDirectoryEnumerationOptions.SkipsHiddenFiles) { element -> Path? in
            let isImage = element.path!.hasSuffix(".png") || element.path!.hasSuffix(".jpg") || element.path!.hasSuffix(".jpeg")
            return (isImage) ? element.path! : nil
        }
    }
    
    static func availableAssetSets(from path: Path) -> [Path] {
        return queryWith(path, searchOption: NSDirectoryEnumerationOptions.SkipsPackageDescendants) { element -> Path? in
            let isAssetFolder = element.path!.hasSuffix(".imageset") || element.path!.hasSuffix(".appiconset") || element.path!.hasSuffix(".launchimage")
            return (isAssetFolder) ? element.path! : nil
        }
    }
    
    static func availableAssetFolders(from path: Path) -> [Path] {
        return queryWith(path, searchOption: NSDirectoryEnumerationOptions.SkipsPackageDescendants) { element -> Path? in
            let isAssetFolder = element.path!.isAssetsFolder()
            return (isAssetFolder) ? element.path! : nil
        }
    }
    
    private static func queryWith<T>(path: Path,  searchOption: NSDirectoryEnumerationOptions, query: (NSURL -> T?)) -> [T] {
        let url = NSURL(fileURLWithPath: path, isDirectory: true)
        let generator = NSFileManager.defaultManager().enumeratorAtURL(url!, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: searchOption , errorHandler: nil)
        var matches = [T]()
        
        while let element = generator?.nextObject() as? NSURL {
            let result = query(element)
            if let result = result {
                matches.append(result)
            }
        }
        return matches
    }
    
}