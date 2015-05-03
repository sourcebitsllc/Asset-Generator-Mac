//
//  Validator.swift
//  XCAssetGenerator
//
//  Created by Bader on 3/12/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

protocol Validator {}

extension BookmarkResolver: Validator {
    
    class func isBookmarkValid(bookmark: Bookmark?) -> Bool {
        if let b = bookmark, let path = resolvePathFromBookmark(b) {
            return PathValidator.directoryExists(path: path)
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
    
    class func isAssetValid(asset: AssetCatalog) -> Bool {
        return BookmarkResolver.isBookmarkValid(asset.bookmark)
    }
}


class PathValidator: Validator {
    
    class func directoryContainsInvalidCharacters(#path: Path, options: AnyObject?) -> Bool {
        return directoryWith(path, searchOption: NSDirectoryEnumerationOptions.SkipsHiddenFiles) { (url, isDirectory) -> Bool? in
            if isDirectory && (contains(url.path!, ".") || contains(url.path!, ":")) { return true }
            return nil
        } ?? false
    }
    
    class func directoryContainsXCAsset(#directory: Path) -> Bool {
        return directoryWith(directory, searchOption: NSDirectoryEnumerationOptions.SkipsHiddenFiles) { (url, isDirectory) -> Bool? in
            if isDirectory && url.path!.isAssetCatalog() { return true }
            return nil
        } ?? false
    }

    
    class func retreiveProject(url: NSURL) -> NSURL? {
        return directoryWith(url.path!, searchOption: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants) { (url, isDirectory) -> NSURL? in
            if isDirectory && url.path!.isXCProject() { return url }
            return nil
        }
    }
    

    class func directoryContainsImages(#path: Path) -> Bool {
        return directoryWith(path, searchOption: NSDirectoryEnumerationOptions.SkipsHiddenFiles) { (url, isDirectory) -> Bool? in
            let isImage = url.path!.hasSuffix(".png") || url.path!.hasSuffix(".jpg") || url.path!.hasSuffix(".jpeg")
            if !isDirectory && isImage { return true }
            else { return nil }
        } ?? false
    }
    

    private class func directoryWith<T>(path: Path, searchOption: NSDirectoryEnumerationOptions,  f: (NSURL, Bool) -> T?) -> T? {
        let url = NSURL(fileURLWithPath: path, isDirectory: true)
        
        let generator = NSFileManager.defaultManager().enumeratorAtURL(url!, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: searchOption, errorHandler: nil)
        
        while let element = generator?.nextObject() as? NSURL {
            
            var d: AnyObject? = nil
            element.getResourceValue(&d, forKey: NSURLIsDirectoryKey, error: nil)
            let isDirectory: Bool = (d as? Bool) ?? false
            
            if let asset = element.path {
                let t = f(element, isDirectory)
                if (t != nil) { return t }
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
    
    
}
