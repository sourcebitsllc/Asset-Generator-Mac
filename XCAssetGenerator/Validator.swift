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
    
    class func isAssetValid(asset: AssetFolder) -> Bool {
        return BookmarkResolver.isBookmarkValid(asset.bookmark)
    }
}


class PathValidator: Validator {
    
    /* 
        NOTE: The renaming should be done directly from the main bash script (ScriptExecutor)
    */
    
    class func directoryContainsInvalidCharacters(#path: Path, options: AnyObject?) -> Bool {
        return directoryWith(path, searchOption: NSDirectoryEnumerationOptions.SkipsHiddenFiles) { (url, isDirectory) -> Bool? in
            if isDirectory && (contains(url.path!, ".") || contains(url.path!, ":")) { return true }
            return nil
        } ?? false
    }
    
    class func directoryContainsXCAsset(#directory: Path) -> Bool {
        return directoryWith(directory, searchOption: NSDirectoryEnumerationOptions.SkipsHiddenFiles) { (url, isDirectory) -> Bool? in
            if isDirectory && url.path!.isXCAsset() { return true }
            return nil
        } ?? false
    }
    
    class func images(path: Path) -> [Path] {
        let url = NSURL(fileURLWithPath: path, isDirectory: true)
        
        let generator = NSFileManager.defaultManager().enumeratorAtURL(url!, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles , errorHandler: nil)
        
        var foundImages = [Path]()
        while let element = generator?.nextObject() as? NSURL {
            let isImage = element.path!.hasSuffix(".png") || element.path!.hasSuffix(".jpg") || element.path!.hasSuffix(".jpeg")

            if isImage { foundImages.append(element.path!) }
        }
        
        return foundImages
    }
    
    
    class func xcassetFolders(path: Path) -> [Path] {
        let url = NSURL(fileURLWithPath: path, isDirectory: true)
        
        let generator = NSFileManager.defaultManager().enumeratorAtURL(url!, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions.SkipsPackageDescendants , errorHandler: nil)
        
        var foundFolders = [Path]()
        while let element = generator?.nextObject() as? NSURL {
            let isAssetFolder = element.path!.hasSuffix(".imageset") || element.path!.hasSuffix(".appiconset") || element.path!.hasSuffix(".launchimage")
            
            if isAssetFolder { foundFolders.append(element.path!) }
        }
        
        return foundFolders
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
    
    /*
        @param:
            f: (NSURL) -> T?  ;; If result of applying closure is nil, we will not return it but will skip instead and proceed with the generator loop.
                                Additionally, accessing the path component of the NSURL is always safe. (Kinda unintuitive API right now though)
                                We use the optional return type to be able to skip non-satisfying results and still be able to proceed with loop.
        @return type
            We use an optional return type to encompass all our return needs.
    */
    private class func directoryWith<T>(path: Path, searchOption: NSDirectoryEnumerationOptions,  f: (NSURL, Bool) -> T?) -> T? {
        let url = NSURL(fileURLWithPath: path, isDirectory: true)
        
        let generator = NSFileManager.defaultManager().enumeratorAtURL(url!, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: searchOption, errorHandler: nil)
        
        while let element = generator?.nextObject() as? NSURL {
            
            var d: AnyObject? = nil
            element.getResourceValue(&d, forKey: NSURLIsDirectoryKey, error: nil)
            let isDirectory: Bool = (d as Bool?) ?? false
            
            if let asset = element.path? {
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
