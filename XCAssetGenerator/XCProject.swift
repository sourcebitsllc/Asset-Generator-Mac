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
        case (.None,.None): return true
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
    
    func dictionaryRepresentation() -> [String: NSData] {
        if let assets = xcassets {
            var assetsAsDataArray: [NSData] = assets.map({ (asset: XCAsset) -> NSData in
                return asset.data
            })
            var assetsData = NSKeyedArchiver.archivedDataWithRootObject(assetsAsDataArray)
            return [pathKey: self.pathBookmark, assetPathKey: assetsData]
        } else {
            return [pathKey: self.pathBookmark, assetPathKey: NSData() ]
        }
        
    }
    
    func userDefaultsDictionaryRepresentation() -> [NSString: NSData] {
        return self.dictionaryRepresentation()
    }
    
    static func projectFromDictionary(dictionary: [String: NSData]) -> XCProject {
        let path = dictionary[pathKey]!
//        let asset: String? = dictionary[assetPathKey]!.isEmpty ? nil : dictionary[assetPathKey]!
        
        if let assetsData: NSData = dictionary[assetPathKey] {
            
            // the data can be initialized but empty -> should be equivelant to nil data.
            // If asset data is not empty, process it. else, ignore it.
            let emptyDataTester = NSData()
            
            if assetsData.isEqualToData(emptyDataTester) == false {
                let assetsAsData = NSKeyedUnarchiver.unarchiveObjectWithData(assetsData) as [NSData]
                let XCAssets = assetsAsData.map({ (data: NSData) -> XCAsset in
                    return XCAsset(data: data)
                })
                return XCProject(data: path, xcassets: XCAssets)
            
            } else {
                return XCProject(data: path)
            }
        
        } else {
            return XCProject(data: path)
        }
    }
    
}



// MARK:-
struct XCProject: Equatable {
    
    var path: String {
        get {
            var url = NSURL(byResolvingBookmarkData: self.pathBookmark, options: NSURLBookmarkResolutionOptions.WithoutMounting, relativeToURL: nil, bookmarkDataIsStale: nil, error: nil)
            
            return url!.path! // This cannot be nil. If it is, catastrophe.
//            if let p = url {
//                return p.path!
//            } else {
//                return ""
//            }
        }
    }
    var pathBookmark : Bookmark
    private var xcassets: [XCAsset]?
    
    
    // MARK:- Initializers
    
//    internal init(path: String) {
//        self.path = path
//        self.xcassets = retrieveAssets(directory: self.XCProjectDirectoryPath())
//    }
    
    internal init(data: NSData) {
        self.pathBookmark = data
        self.xcassets = retrieveAssets(directory: self.XCProjectDirectoryPath())
    }
    
//    internal init(path: String, xcassetPath: String?) {
//        self.path = path
//        
//        if let assetpath = xcassetPath {
//            self.xcassets = [XCAsset(path: assetpath)]
//        }
//    }
    
//    internal init(path: String, xcassets: [XCAsset]?) {
//        self.path = path
//        
//        if let assets = xcassets {
//            self.xcassets = assets
//        } else {
//            self.xcassets = nil
//        }
//    }
    internal init(data: NSData, xcassetData: [NSData]?) {
        self.pathBookmark = data
        
        if let assetsData = xcassetData {
            var validBookmarks: [PathBookmarkResolver.PathBookmark] = PathBookmarkResolver.resolveValidPathsFromBookmarks(assetsData)
            
            var assets: [XCAsset]? = nil
            
            // If no valid bookmarks available, just skip them and set assets to nil.
            if validBookmarks.count > 0 {
                assets = validBookmarks.map({ (aPathBookmark: PathBookmarkResolver.PathBookmark ) -> XCAsset in
                    return XCAsset(data: aPathBookmark.bookmark, path: aPathBookmark.path)
                })
            }
            self.xcassets = assets
            
        } else {
            self.xcassets = nil
        }
    }
    
    internal init(data: NSData, xcassets: [XCAsset]?) {
        self.pathBookmark = data
        
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
    
    func assetDirectoryBookmark() -> Bookmark? {
        return self.xcassets?.first?.data
    }
    
    // A project will have a valid assets path if it contains an asset and if the asset path is not empty.
    func hasValidAssetsPath() -> Bool {
        if (self.xcassets?.first != nil) {
            return PathBookmarkResolver.isBookmarkValid(self.xcassets!.first!.data) && !self.xcassets!.first!.path.isEmpty
        }
        
        return false
    }
    
    mutating func invalidateAssets() {
        self.xcassets = nil
    }
    

    mutating private func retrieveAssets(#directory: String) -> [XCAsset]? {
        var task: NSTask = NSTask()
        var pipe = NSPipe()
        
        task.launchPath = "/usr/bin/find"
        task.arguments = [directory, "-name", "*.xcassets"]
        task.standardOutput = pipe
        
        task.launch()
        
        var string: String = NSString(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)!
        
        // If string not empty, convert it into an array and get the first value.
        let assetPath: String? = string.isEmpty ? nil : string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\n")).first
        
        
        if let path = assetPath {
            var data: NSData = PathBookmarkResolver.resolveBookmarkFromPath(path)
            return [XCAsset(data: data)]
        } else {
            return nil
        }
        
    }
    
    private func XCProjectDirectoryPath() -> String {
        return self.path.stringByDeletingLastPathComponent + ("/") // .extend
    }
    
}
