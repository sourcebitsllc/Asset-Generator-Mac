//
//  SourcePathValidator.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/30/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Foundation

class SourcePathValidator {
    
    class func validatePath(#path: String, options: AnyObject?) -> Bool {
        var task: NSTask = NSTask()
        var pipe = NSPipe()
        
        task.launchPath = "/usr/bin/find"
        task.arguments = [path, "-type","d","-name", "*.*","-print0"]
        task.standardOutput = pipe
        task.launch()
        
        var string: String = NSString(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding:NSUTF8StringEncoding)
        println(string)
        
        var array: [String]? = string.isEmpty ? nil : string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\0"))
        array = array?.map({ (string: String) -> String in
            return string.stringByReplacingOccurrencesOfString(path, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        })
        
        for x in array! {
            if contains(x, ".") {
                println("Cotains dot")
            } else {
                println("doesnt")
            }
        }
        println(array)
        return true
        // If string not empty, convert it into an array and get the first value.
//        self.xcassetPath = string.isEmpty ? nil : string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\n")).first
        
    }
}