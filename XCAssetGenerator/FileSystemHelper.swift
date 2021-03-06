//
//  FileSystemHelper.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/3/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

struct FileSystem {
    
    static func copy(#file: Path, toLocation location: Path) -> Bool {
        if NSFileManager.defaultManager().fileExistsAtPath(location) {
            // TODO: Swift 2.0
            if equal(file, location) {
                return false
            }
            
            NSFileManager.defaultManager().removeItemAtPath(location, error: nil)
        }
        let success = NSFileManager.defaultManager().copyItemAtPath(file, toPath: location, error: nil)
        return success
    }
    
    
    static func deleteDirectory(path: Path) -> Bool {
        if PathValidator.directoryExists(path: path) {
            let status = NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
            return status
        }
        
        return false
    }
    
    static func createDirectoryIfMissing(path: Path) -> Bool {
        if !PathValidator.directoryExists(path: path) {
            let status = NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
            return status
        }
        return false
    }
    
    static func equal(first: Path, _ second: Path) -> Bool {
        return NSFileManager.defaultManager().contentsEqualAtPath(first, andPath: second)
    }

}
