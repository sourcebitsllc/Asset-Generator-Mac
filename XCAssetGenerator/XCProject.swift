//
//  XCProject.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/19/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved. 
//

import Foundation

let PathKey = "XCAssetGeneratorXcodeProjectPath"
let AssetPathsKey = "XCAssetGeneratorXcodeAssetsPath"
let invalidAssetTitleDisplay = ""


// MARK:- Equatable Conformance
func == (lhs: XCProject, rhs: XCProject) -> Bool {
    // TODO: This needs a rethink.
    if lhs.bookmark == rhs.bookmark { return true }
    
    switch (ProjectValidator.isProjectValid(lhs), ProjectValidator.isProjectValid(rhs)) {
    case (true, true):
        return lhs.path == rhs.path && lhs.xcassets?.first == rhs.xcassets?.first
    case (false, false):
        return true
    case (_,_):
        return false
    }
}
// MARK: Convenience Funcion
func == (lhs: XCProject?, rhs: XCProject?) -> Bool {
    switch (lhs, rhs) {
    case (.Some(let a), .Some(let b)):
        return a == b
    case (.None,.None):
        return true
    case (_,_):
        return false
    }
}

// MARK:- Printable Protocol
extension XCProject: Printable {
    
    var description: String {
        get {
            return "path: \(path) -> assets: \(xcassets?.first)"
        }
    }
    
    var title: String {
        get {
            return path.lastPathComponent
        }
    }
}

// MARK: -  Serializable.
extension XCProject: Serializable {
    
    /// For the key "PathKey", the NSData is the project bookmark.
    /// For the key "AssetPathsKey", the NSData is an array of asset bookmarks.
    typealias Serialized = [String: NSData]
    
    var serialized: Serialized {
        get {
            let assets = xcassets?.map { $0.bookmark } ?? [Bookmark]()
            let assetsData = NSKeyedArchiver.archivedDataWithRootObject(assets)
            return [PathKey: bookmark, AssetPathsKey: assetsData]
        }
    }
    
    static func projectFromDictionary(dictionary: Serialized) -> XCProject {
        let projectPath = dictionary[PathKey]!
        var assets: [Bookmark]? = nil
        if let data = dictionary[AssetPathsKey] {
            assets = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Bookmark]
        }
        return XCProject(bookmark: projectPath, xcassetBookmarks: assets)
    }
}



// MARK:-
struct XCProject: Equatable {
    
    var bookmark : Bookmark
    let path: Path
    private var xcassets: [AssetsFolder]?
    
    // MARK:- Initializers
    
    internal init(bookmark: Bookmark) {
        self.bookmark = bookmark
        self.path = BookmarkResolver.resolvePathFromBookmark(bookmark)!
        self.xcassets = PathQuery.availableAssetFolders(from: currentWorkingDirectory).map {
            let bookmark = BookmarkResolver.resolveBookmarkFromPath($0)
            return AssetsFolder(bookmark: bookmark)
        }
    }

    internal init(bookmark: Bookmark, xcassetBookmarks: [Bookmark]?) {
        var assets: [AssetsFolder]? = nil
        
        if let assetsData = xcassetBookmarks  {
            let validBookmarks: [BookmarkResolver.ResolvedBookmark] = BookmarkResolver.resolveValidPathsFromBookmarks(assetsData)

            if validBookmarks.count > 0 {
                assets = validBookmarks.map { rb -> AssetsFolder in
                    return AssetsFolder(bookmark: rb.bookmark, path: rb.path)
                }
            }
        }
        
        self.xcassets = assets
        self.bookmark = bookmark
        self.path = BookmarkResolver.resolvePathFromBookmark(bookmark)!
    }
    
    internal init(bookmark: Bookmark, xcassets: [AssetsFolder]?) {
        self.bookmark = bookmark
        self.path = BookmarkResolver.resolvePathFromBookmark(bookmark)!
        self.xcassets = xcassets?.count > 0 ? xcassets : nil
    }

    private var currentWorkingDirectory: Path {
        get {
            return path.stringByDeletingLastPathComponent + ("/")
        }
    }
}


// MARK:- XCProject Assets Public Query Interface
extension XCProject {
    var assetTitle: Path {
        get {
            return xcassets?.first?.title ?? invalidAssetTitleDisplay
        }
    }
    
    var assetPath: Path? {
        get {
            return xcassets?.first?.path
        }
    }
    
    var assetBookmark: Bookmark? {
        get {
            return xcassets?.first?.bookmark
        }
    }
    
    // A project will have a valid assets path if it contains an asset and if the asset path is not empty.
    func hasValidAssetsPath() -> Bool {
        if (xcassets?.first != nil) {
            return BookmarkResolver.isBookmarkValid(xcassets!.first!.bookmark) && !xcassets!.first!.path.isEmpty
        }
        
        return false
    }
}

