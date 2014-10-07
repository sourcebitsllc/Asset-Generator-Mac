//
//  XCAsset.swift
//  XCAssetGenerator
//
//  Created by Bader on 10/6/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Foundation

struct XCAsset {
// TODO:
    var path: String?
    
    init(directory: String) {
        path = retrieveAssets(directory: directory)
    }
    
    init (path aPath: String) {
        path = aPath
    }
    
    mutating private func retrieveAssets(#directory: String) -> String? {
        var task: NSTask = NSTask()
        var pipe = NSPipe()
        
        task.launchPath = "/usr/bin/find"
        task.arguments = [directory, "-name", "*.xcassets"]
        task.standardOutput = pipe
        
        task.launch()
        
        var string: String = NSString(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
        
        let assetPath: String? = string.isEmpty ? nil : string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\n")).first
        // If string not empty, convert it into an array and get the first value.
        
        return assetPath
    }
    

}