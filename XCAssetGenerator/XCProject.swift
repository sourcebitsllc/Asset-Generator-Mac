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
let invalidAssetTitleDisplay = ""
// TODO: If we wanted to add support for multiple xcassets, it simple goes here.


// MARK:- Equatable Conformance

func == (lhs: XCProject, rhs: XCProject) -> Bool {
    return lhs.path == rhs.path && lhs.xcassets?.first? == rhs.xcassets?.first?
}
// MARK: Convenience Funcion
func == (lhs: XCProject?, rhs: XCProject?) -> Bool {
    switch (lhs, rhs) {
        case (.Some(let a), .Some(let b)) : return a == b
        case (nil, nil): return true
        case (_,_): return false
    }
}

// MARK:- Printable Protocol
extension XCProject: Printable {
    
    var description: String {
        get {
            return "path: \(path) -> assets: \(self.xcassets?.first?)"
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
        return [pathKey: self.path, assetPathKey: self.xcassets?.first?.path ?? ""]
    }
    
    func userDefaultsDictionaryRepresentation() -> [NSString: NSString] {
        return self.dictionaryRepresentation()
    }
    
    static func projectFromDictionary(dictionary: [String: String]) -> XCProject {
        let path = dictionary[pathKey]!
//        let asset: String? = dictionary[assetPathKey]!.isEmpty ? nil : dictionary[assetPathKey]!
        
        if dictionary[assetPathKey]!.isEmpty {
            return XCProject(path: path)
        } else {
            let asset = dictionary[assetPathKey]!
            return XCProject(path: path, xcassetPath: asset)
        }
    }
    
}

// MARK:-
struct XCProject: Equatable {
    
    var path: String
    private var xcassets: [XCAsset]?
    
    
    // MARK:- Initializers
    
    internal init(path: String) {
        self.path = path
        self.xcassets = retrieveAssets(directory: self.XCProjectDirectoryPath())
    }
    
    internal init(path: String, xcassetPath: String?) {
        self.path = path
        
        if let assetpath = xcassetPath {
            self.xcassets = [XCAsset(path: assetpath)]
        }
    }
    
    internal init(path: String, xcassets: [XCAsset]?) {
        self.path = path
        
        if let assets = xcassets {
            self.xcassets = assets
        } else {
            self.xcassets = nil
        }
    }
    
    
    
    // MARK:- Convenience functions and helpers.
    // MARK: XCAsset accessors.
    func assetDirectoryTitle() -> String {
        return self.xcassets?.first?.title ?? invalidAssetTitleDisplay
    }
    
    func assetDirectoryPath() -> String? {
        return self.xcassets?.first?.path
    }
    
    func hasValidAssetsPath() -> Bool {
        return (self.xcassets?.first != nil) ? true : false
    }
    

    
    mutating private func retrieveAssets(#directory: String) -> [XCAsset]? {
        var task: NSTask = NSTask()
        var pipe = NSPipe()
        
        task.launchPath = "/usr/bin/find"
        task.arguments = [directory, "-name", "*.xcassets"]
        task.standardOutput = pipe
        
        task.launch()
        
        var string: String = NSString(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
        
        let assetPath: String? = string.isEmpty ? nil : string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\n")).first
        // If string not empty, convert it into an array and get the first value.
        if let path = assetPath {
            return [XCAsset(path: path)]
        } else {
            return nil
        }
        
    }
    
    private func XCProjectDirectoryPath() -> String {
        return self.path.stringByDeletingLastPathComponent + ("/") // .extend
    }
    
}
