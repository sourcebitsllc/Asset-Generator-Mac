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
        NSLog("Checking if directory contains invalid characters")
        
        var task: NSTask = NSTask()
        var pipe = NSPipe()
        
        task.launchPath = "/usr/bin/find"
        task.arguments = [path, "-type","d","-name", "*.*","-print0"]
        task.standardOutput = pipe
        task.launch()
        
        NSLog("Done checking if directory contains invalid characters")
        
        var string: String = NSString(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding:NSUTF8StringEncoding)!
        
        // No directories inside path = no directory which contains a dot = valid = return true
        if string.isEmpty {
            return false
        }
        
        // Store found directories into array and get the relative directory path of each entry. (to ensure the erroneous dot originates inside one of our folders - not from the absolute path.
        // e.g. /Users/Bade.r/$PATH  is fine, /Users/Bader/$PATH/Fol.der is not
        var array: [String] = string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\0"))
        array = array.map { string -> String in
            return string.stringByReplacingOccurrencesOfString(path, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        }
        
        // If we find a directory name which contains a dot, invalid paht found = return false
        for directoryName: String in array {
            if contains(directoryName, ".") || contains(directoryName, ":") {
                return true
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
