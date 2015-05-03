//
//  XCProject.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/19/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved. 
//

import Foundation

let PathKey = "XCAssetGeneratorXcodeProjectPath"
let AssetPathsKey = "XCAssetGeneratorXcodeAssetsPath"


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


// MARK:-
struct XCProject: Equatable, Printable {
    
    var bookmark : Bookmark
    let path: Path
    private var xcassets: [AssetCatalog]?
    
    // MARK:- Initializers
    
    internal init(bookmark: Bookmark) {
        self.bookmark = bookmark
        self.path = BookmarkResolver.resolvePathFromBookmark(bookmark)!
        self.xcassets = PathQuery.availableAssetCatalogs(from: currentWorkingDirectory).map {
            let bookmark = BookmarkResolver.resolveBookmarkFromPath($0)
            return AssetCatalog(bookmark: bookmark)
        }
    }

    internal init(bookmark: Bookmark, assetsBookmarks: [Bookmark]?) {
        self.bookmark = bookmark
        self.path = BookmarkResolver.resolvePathFromBookmark(bookmark)!
        self.xcassets = assetsBookmarks?.filter(BookmarkResolver.isBookmarkValid)
                                        .map { AssetCatalog(bookmark: $0) }
    }
    
    internal init(bookmark: Bookmark, xcassets: [AssetCatalog]?) {
        self.bookmark = bookmark
        self.path = BookmarkResolver.resolvePathFromBookmark(bookmark)!
        self.xcassets = xcassets?.count > 0 ? xcassets : nil
    }

    private var currentWorkingDirectory: Path {
        return path.stringByDeletingLastPathComponent + ("/")
    }
    
    var title: String {
        return path.lastPathComponent
    }
    
    // MARK: - Printable
    
    var description: String {
        return "path: \(path) -> assets: \(xcassets?.first)"
    }
}

// MARK: -  Serializable.
extension XCProject: Serializable {
    
    /// For the key "PathKey", the NSData is the project bookmark.
    /// For the key "AssetPathsKey", the NSData is an array of asset bookmarks.
    /// TODO: 2.0: Store all found AssetFolders of the project. (We only store the "selected" one right now. Keep code messy and revisit later).
    typealias Serialized = [String: NSData]
    
    var serialized: Serialized {
        get {
            let assets = xcassets?.first?.serialized ?? Bookmark()
//            let assetsData = NSKeyedArchiver.archivedDataWithRootObject([assets])
            return [PathKey: bookmark, AssetPathsKey: assets]
        }
    }
    
    static func projectFromDictionary(dictionary: Serialized) -> XCProject {
        let projectPath = dictionary[PathKey]!
        var assets: [Bookmark]? = nil
        if let data = dictionary[AssetPathsKey] {
//            assets = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Bookmark]
            assets = [data]
        }
        return XCProject(bookmark: projectPath, assetsBookmarks: assets)
    }
}


// MARK:- XCProject Assets Public Query Interface
extension XCProject {
    var assetTitle: String {
        return xcassets?.first?.title ?? NSLocalizedString("Invalid Asset Title", comment: "")
    }
    
    var assetPath: Path? {
        return xcassets?.first?.path
    }
    
    var assetBookmark: Bookmark? {
        return xcassets?.first?.bookmark
    }
    
    // A project will have a valid assets path if it contains an asset and if the asset path is not empty.
    func hasValidAssetsPath() -> Bool {
        if let folder = xcassets?.first {
            return BookmarkResolver.isBookmarkValid(folder.bookmark) && !folder.path.isEmpty
        }
        return false
    }
}

