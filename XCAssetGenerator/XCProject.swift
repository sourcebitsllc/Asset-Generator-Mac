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
    
    func dictionaryRepresentation() -> [String: Bookmark] {
        if let assets = xcassets {
            var assetsAsBookmarksArray: [Bookmark] = assets.map { asset -> Bookmark in
                return asset.bookmark
            }
            var assetsData = NSKeyedArchiver.archivedDataWithRootObject(assetsAsBookmarksArray)
            return [pathKey: self.bookmark, assetPathKey: assetsData]
        } else {
            return [pathKey: self.bookmark, assetPathKey: Bookmark() ]
        }
        
    }
    
    func userDefaultsDictionaryRepresentation() -> [NSString: Bookmark] {
        return self.dictionaryRepresentation()
    }
    
    static func projectFromDictionary(dictionary: [String: Bookmark]) -> XCProject {
        let bookmarks = dictionary[pathKey]!
        
        if let assetsBookmarks: Bookmark = dictionary[assetPathKey] {
            // TODO: Hack.
            // the data can be initialized but empty -> should be equivelant to nil data.
            // If asset data is not empty, process it. else, ignore it.
            let emptyDataTester = Bookmark()
            
            if assetsBookmarks.isEqualToData(emptyDataTester) == false {
                let assetsAsData = NSKeyedUnarchiver.unarchiveObjectWithData(assetsBookmarks) as [Bookmark]
                let XCAssets = assetsAsData.map { (bookmark: Bookmark) -> XCAsset in
                    return XCAsset(bookmark: bookmark)
                }
                return XCProject(bookmark: bookmarks, xcassets: XCAssets)
            
            } else {
                return XCProject(bookmark: bookmarks)
            }
        
        } else {
            return XCProject(bookmark: bookmarks)
        }
    }
    
}



// MARK:-
struct XCProject: Equatable {
    
    var path: Path {
        get {
            var url = NSURL(byResolvingBookmarkData: self.bookmark, options: NSURLBookmarkResolutionOptions.WithoutMounting, relativeToURL: nil, bookmarkDataIsStale: nil, error: nil)
            
            return url!.path! // This cannot be nil. If it is, catastrophe. It doesnt make sense for a project to not have a valid path -- else it shouldnt exist
        }
    }
    var bookmark : Bookmark
    private var xcassets: [XCAsset]?
    
    
    // MARK:- Initializers
    
    
    internal init(bookmark: Bookmark) {
        self.bookmark = bookmark
        self.xcassets = retrieveAssets(directory: self.XCProjectDirectoryPath())
    }

    internal init(bookmark: Bookmark, xcassetBookmarks: [Bookmark]?) {
        var assets: [XCAsset]? = nil
        
        if let assetsData = xcassetBookmarks {
            var validBookmarks: [BookmarkResolver.ResolvedBookmark] = BookmarkResolver.resolveValidPathsFromBookmarks(assetsData)

            if validBookmarks.count > 0 {
                assets = validBookmarks.map { rb -> XCAsset in
                    return XCAsset(bookmark: rb.bookmark, path: rb.path)
                }
            }
        }
        
        self.xcassets = assets
        self.bookmark = bookmark
    }
    
    internal init(bookmark: Bookmark, xcassets: [XCAsset]?) {
        self.bookmark = bookmark
    
        self.xcassets = xcassets ?? nil
    }
    
    private func XCProjectDirectoryPath() -> Path {
        return self.path.stringByDeletingLastPathComponent + ("/") // .extend
    }
    
    
    // MARK - Mutating Functions
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
            var data: Bookmark = BookmarkResolver.resolveBookmarkFromPath(path)
            return [XCAsset(bookmark: data)]
        } else {
            return nil
        }
        
    }
    
}


// MARK:- XCProject Assets Public Query Interface
extension XCProject {
    func assetDirectoryTitle() -> Path {
        return self.xcassets?.first?.title ?? invalidAssetTitleDisplay
    }
    
    func assetDirectoryPath() -> Path? {
        return self.xcassets?.first?.path
    }
    
    func assetDirectoryBookmark() -> Bookmark? {
        return self.xcassets?.first?.bookmark
    }
    
    // A project will have a valid assets path if it contains an asset and if the asset path is not empty.
    func hasValidAssetsPath() -> Bool {
        if (self.xcassets?.first != nil) {
            return BookmarkResolver.isBookmarkValid(self.xcassets!.first!.bookmark) && !self.xcassets!.first!.path.isEmpty
        }
        
        return false
    }
}

