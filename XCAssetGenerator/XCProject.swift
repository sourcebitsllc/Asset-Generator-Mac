//
//  XCProject.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/19/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved. 
//

import Foundation

let pathKey = "XCAssetGeneratorXcodeProjectPath"
let assetPathKey = "XCAssetGeneratorXcodeAssetsPath"


// MARK:- Equatable Conformance

func == (lhs: XCProject, rhs: XCProject) -> Bool {
    return lhs.path == rhs.path && lhs.xcassetPath == rhs.xcassetPath
}
//        var proj1: XCProject = self.recentListManager.projectAtIndex(sender.indexOfSelectedItem)!
//        var proj2: XCProject = self.recentListManager.projectAtIndex(sender.indexOfSelectedItem)!
//        println("Equal? \(proj1 == proj2)")  // Return true
//        println("Contains? \(contains([proj1], proj2))") // Returns true
//        println("Find? \(find([proj1], proj2))") // return Optional(0)

extension XCProject: Printable {
    
    var description: String {
        get {
            return "[\(self)] -- path: \(self.path), asset path: \(self.xcassetPath)"
        }
    }
    
    var title: String {
        get {
            return self.path.lastPathComponent
        }
    }
}


// MARK:- NSUserDefaults compliance extension.
// Converts the current project into a propertylist Dictionary and initiates project from dictionary content

extension XCProject {
    
    func dictionaryRepresentation() -> [String: String] {
        return [pathKey: self.path, assetPathKey: self.xcassetPath ?? ""]
    }
    
    func userDefaultsDictionaryRepresentation() -> [NSString: NSString] {
        return self.dictionaryRepresentation()
    }
    
    static func projectFromDictionary(dictionary: [String: String]) -> XCProject {
        let path = dictionary[pathKey]!
        let asset: String? = dictionary[assetPathKey]!.isEmpty ? nil : dictionary[assetPathKey]!
        return XCProject(path: path, xcassetPath: asset)
    }
    
}

// MARK:-
struct XCProject: Equatable {
    
    var path: String
    private var xcassetPath: String?
    
    
    // MARK:- Initializers
    
    internal init(path: String) {
        self.path = path
        self.xcassetPathFinder()
    }
    
    internal init(path: String, xcassetPath: String?) {
        self.path = path
        
        if let assetpath = xcassetPath {
            self.xcassetPath = xcassetPath
        } else {
            self.xcassetPathFinder()
        }
    }
    
    
    
    // MARK:- Convenience functions and helpers.
    
    func assetDirectoryPath() -> String? {
        return xcassetPath
    }
    
    func hasValidAssetsPath() -> Bool {
        return (self.xcassetPath? != nil) ? true : false
    }
    
    mutating private func xcassetPathFinder() {
        var task: NSTask = NSTask()
        var pipe = NSPipe()
        
        task.launchPath = "/usr/bin/find"
        task.arguments = [self.XCProjectDirectoryPath(), "-name", "*.xcassets"]
        task.standardOutput = pipe
        
        task.launch()
        
        var string: String = NSString(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
        
        // If string not empty, convert it into an array and get the first value.
        self.xcassetPath = string.isEmpty ? nil : string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\n")).first
        
        println("\(self.xcassetPath)")
    }
    
    private func XCProjectDirectoryPath() -> String {
        return self.path.stringByDeletingLastPathComponent + ("/") // .extend
    }
    
}
