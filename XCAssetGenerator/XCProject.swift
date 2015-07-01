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

// MARK:-
struct XCProject: Printable {
    
    let path: Path
    private var xcassets: AssetCatalog?
    
    // MARK:- Initializers
    
    internal init(path: Path) {
        self.path = path
        let found = PathQuery.availableAssetCatalogs(from: currentWorkingDirectory)
        self.xcassets = found.count > 0 ? AssetCatalog(path: found.first!) : nil
    }
    
    internal init(path: Path, catalogs: AssetCatalog?) {
        self.path = path
        self.xcassets = catalogs
    }

    private var currentWorkingDirectory: Path {
        return path.stringByDeletingLastPathComponent + ("/")
    }
    
    var title: String {
        return path.lastPathComponent
    }
    
    // MARK: - Printable
    
    var description: String {
        return "path: \(path) -> assets: \(xcassets)"
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
            let bookmark = BookmarkResolver.resolveBookmarkFromPath(path)
            let assets = xcassets?.serialized ?? Bookmark()
            return [PathKey: bookmark, AssetPathsKey: assets]
        }
    }
    
    static func projectFromDictionary(dictionary: Serialized) -> XCProject {

        let path = BookmarkResolver.resolvePathFromBookmark(dictionary[PathKey]!)!
        var catalogs: AssetCatalog? = nil
        if let data = dictionary[AssetPathsKey], let catalog = BookmarkResolver.resolvePathFromBookmark(data) {
            catalogs = AssetCatalog(path: catalog)
        }
        return XCProject(path: path, catalogs: catalogs)
    }
}


// MARK:- XCProject Assets Public Query Interface
extension XCProject {
    
    var catalog: AssetCatalog? {
        return xcassets
    }
    
    // A project will have a valid assets path if it contains an asset and if the asset path is not empty.
    func hasValidAssetsPath() -> Bool {
        if let folder = xcassets {
            return PathValidator.directoryExists(path: folder.path)
        }
        return false
    }
    
    func ownsCatalog(catalog: AssetCatalog) -> Bool {
        return catalog.path.hasPrefix(currentWorkingDirectory)
    }
}

