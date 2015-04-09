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

// MARK:- NSUserDefaults compliance extension.
// Converts the current project into a propertylist Dictionary and initiates project from dictionary content
extension XCProject {
    
    func dictionaryRepresentation() -> [String: Bookmark] {
        if let assets = xcassets {
            var assetsAsBookmarksArray: [Bookmark] = assets.map { asset -> Bookmark in
                return asset.bookmark
            }
            var assetsData = NSKeyedArchiver.archivedDataWithRootObject(assetsAsBookmarksArray)
            return [pathKey: bookmark, assetPathKey: assetsData]
        } else {
            return [pathKey: bookmark, assetPathKey: Bookmark() ]
        }
        
    }
    
    func userDefaultsDictionaryRepresentation() -> [NSString: Bookmark] {
        return dictionaryRepresentation()
    }
    
    // TODO:
    static func projectFromDictionary(dictionary: [String: Bookmark]) -> XCProject {
        let bookmarks = dictionary[pathKey]!
        
        if let assetsBookmarks: Bookmark = dictionary[assetPathKey] {
            // TODO: Hack.
            // the data can be initialized but empty -> should be equivelant to nil data.
            // If asset data is not empty, process it. else, ignore it.
            let emptyDataTester = Bookmark()
            
            if assetsBookmarks.isEqualToData(emptyDataTester) == false {
                let assetsAsData = NSKeyedUnarchiver.unarchiveObjectWithData(assetsBookmarks) as! [Bookmark]
                let XCAssets = assetsAsData.map { (bookmark: Bookmark) -> AssetsFolder in
                    return AssetsFolder(bookmark: bookmark)
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
    
    var bookmark : Bookmark
    let path: Path
    private var xcassets: [AssetsFolder]?
    
    
    // MARK:- Initializers
    
    internal init(bookmark: Bookmark) {
        self.bookmark = bookmark
        self.path = BookmarkResolver.resolvePathFromBookmark(bookmark)!
     //   self.xcassets = fetchAssets(directory: XCProjectDirectoryPath())
        self.xcassets = PathQuery.availableAssetFolders(from: projectCurrentWorkingDirectory).map {
            let bookmark = BookmarkResolver.resolveBookmarkFromPath($0)
            return AssetsFolder(bookmark: bookmark)
        }
    }

    internal init(bookmark: Bookmark, xcassetBookmarks: [Bookmark]?) {
        var assets: [AssetsFolder]? = nil
        
        if let assetsData = xcassetBookmarks {
            var validBookmarks: [BookmarkResolver.ResolvedBookmark] = BookmarkResolver.resolveValidPathsFromBookmarks(assetsData)

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
        self.xcassets = xcassets ?? nil
    }

    private var projectCurrentWorkingDirectory: Path {
        get {
            return path.stringByDeletingLastPathComponent + ("/")
        }
    }
    
    // MARK - Mutating Functions
    mutating func invalidateAssets() {
        xcassets = nil
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

