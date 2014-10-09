//
//  SourcePathValidator.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/30/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Foundation

// The purpose of this class is to check if ∃ a directory which contains a dot in its name.
// However, it does not fix the issue. Just a way to indicate that a problem exists, then
// have the "fix" be applied directly from the main script (ScriptExecutor)
class PathValidator {

    // The renaming should be done directly from the main bash script (ScriptExecutor)
    class func directoryContainsInvalidCharacters(#path: String, options: AnyObject?) -> Bool {
        var task: NSTask = NSTask()
        var pipe = NSPipe()
        
        task.launchPath = "/usr/bin/find"
        task.arguments = [path, "-type","d","-name", "*.*","-print0"]
        task.standardOutput = pipe
        task.launch()
        
        var string: String = NSString(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding:NSUTF8StringEncoding)
        
        // No directories inside path = no directory which contains a dot = valid = return true
        if string.isEmpty {
            return false
        }
        
        // Store found directories into array and get the relative directory path of each entry. (to ensure the erroneous dot originates inside one of our folders - not from the absolute path.
        // e.g. /Users/Bade.r/$PATH  is fine, /Users/Bader/$PATH/Fol.der is not
        var array: [String] = string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\0"))
        array = array.map({ (string: String) -> String in
            return string.stringByReplacingOccurrencesOfString(path, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        })
        
        // If we find a directory name which contains a dot, invalid paht found = return false
        for directoryName: String in array {
            if contains(directoryName, ".") {
                return true
            }
        }
        // else, return true.
        return false
    }
    
    class func directoryExists(#path: String) -> Bool {
        var isDirectory: ObjCBool = ObjCBool(0)
        NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory)
        
        return isDirectory.boolValue
    }
    
}