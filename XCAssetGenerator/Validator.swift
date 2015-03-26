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
        return BookmarkResolver.isBookmarkValid(project.assetBookmark)
    }
    
    class func isAssetValid(asset: XCAsset) -> Bool {
        return BookmarkResolver.isBookmarkValid(asset.bookmark)
    }
}


class PathValidator: Validator {
    
    /* 
        NOTE: The renaming should be done directly from the main bash script (ScriptExecutor)
    */
    class func directoryContainsInvalidCharacters(#path: Path, options: AnyObject?) -> Bool {

        let url = NSURL(fileURLWithPath: path, isDirectory: true)
        
        let generator = NSFileManager.defaultManager().enumeratorAtURL(url!, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, errorHandler: nil)
        
        while let element = generator?.nextObject() as? NSURL {
            var isDirectory: AnyObject? = nil
            element.getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey, error: nil)
            let isD: Bool = (isDirectory as Bool?) ?? false
            
            if isD {
                if let directory = element.path? {
                    if contains(directory, ".") || contains(directory, ":") { return true }
                }
            }
        }
        
        return false
        
    }
    
    class func retreiveProject(url: NSURL) -> NSURL? {
        
        let generator = NSFileManager.defaultManager().enumeratorAtURL(url, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, errorHandler: nil)
        
        while let element = generator?.nextObject() as? NSURL {
            
            var isDirectory: AnyObject? = nil
            element.getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey, error: nil)
            let isD: Bool = (isDirectory as Bool?) ?? false
            
            if isD {
                if let path = element.path? {
                    if path.isXCProject() { return element }
                }
            }
        }
        return nil
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
    
    class func directoryContainsXCAsset(#directory: Path) -> Bool {
        let url = NSURL(fileURLWithPath: directory, isDirectory: true)
        
        let generator = NSFileManager.defaultManager().enumeratorAtURL(url!, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, errorHandler: nil)
        
        while let element = generator?.nextObject() as? NSURL {
            var isDirectory: AnyObject? = nil
            element.getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey, error: nil)
            let isD: Bool = (isDirectory as Bool?) ?? false
            
            if isD {
                if let asset = element.path? {
                    if asset.isXCAsset() {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    
}
