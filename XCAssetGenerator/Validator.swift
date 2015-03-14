//
//  Validator.swift
//  XCAssetGenerator
//
//  Created by Bader on 3/12/15.
//  Copyright (c) 2015 Pranav Shah. All rights reserved.
//

import Foundation

protocol Validator {}

extension BookmarkResolver: Validator {
    
    class func isBookmarkValid(bookmark: Bookmark?) -> Bool {
        if let b = bookmark {
            let path: Path? = self.resolvePathFromBookmark(b)
            return (path != nil) ? PathValidator.directoryExists(path: path!) : false
        } else {
            return false
        }
    }
}


class ProjectValidator: Validator {
    class func isProjectValid(project: XCProject) -> Bool {
        return BookmarkResolver.isBookmarkValid(project.bookmark)
    }
    
    class func isAssetValid(project: XCProject) -> Bool {
        return BookmarkResolver.isBookmarkValid(project.assetDirectoryBookmark())
    }
    
    class func isAssetValid(asset: XCAsset) -> Bool {
        return BookmarkResolver.isBookmarkValid(asset.bookmark)
    }
}


// The purpose of this class is to check if ∃ a directory which contains a dot in its name.
// However, it does not fix the issue. Just a way to indicate that a problem exists, then
// have the "fix" be applied directly from the main script (ScriptExecutor)
class PathValidator: Validator {
    
    // The renaming should be done directly from the main bash script (ScriptExecutor)
    class func directoryContainsInvalidCharacters(#path: Path, options: AnyObject?) -> Bool {

        let url = NSURL(fileURLWithPath: path, isDirectory: true)
        
        let generator = NSFileManager.defaultManager().enumeratorAtURL(url!, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, errorHandler: nil)
        
        while let element = generator?.nextObject() as? NSURL {
            var isDirectory: AnyObject? = nil
            element.getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey, error: nil)
            let isD: Bool = (isDirectory as Bool?) ?? false
            
            if isD {
                if let directory = element.path? {
                    if contains(directory, ".") || contains(directory, ":") {
                        return true
                    }
                }
            }
        }
        
        return false
        
    }
    
    class func directoryExists(#path: Path) -> Bool {
        var isDirectory: ObjCBool = ObjCBool(false)
        if path.rangeOfString("/.Trash") == nil && !path.isEmpty {
            NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory)
        }
        return isDirectory.boolValue
    }
    
    class func directoryContainsImages(#path: Path) -> Bool {
        let generator = NSFileManager.defaultManager().enumeratorAtPath(path)
        while let element = generator?.nextObject() as? String {
            if element.hasSuffix(".png") || element.hasSuffix(".jpg") {
                return true
            }
        }
        return false
    }
    
}
