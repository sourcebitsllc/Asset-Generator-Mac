//
//  Storage.swift
//  XCAssetGenerator
//
//  Created by Bader on 7/9/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

// TODO: Swift 2.0

// Segfaults
protocol Storage {
    typealias T: Serializable
    func store(item: T)
    
    func load() -> T
}

struct ProjectStorage {
    private let ProjectKey = "RecentlySelectedProject"
    
    typealias T = XCProject?
    
    func load() -> T {
        let projectDict = NSUserDefaults.standardUserDefaults().objectForKey(ProjectKey) as? [String: NSData]
        var project: XCProject? = nil
        func validProject(dict: [String: NSData]) -> Bool {
            let validPath =  BookmarkResolver.isBookmarkValid(dict[PathKey])
            let validAsset = BookmarkResolver.isBookmarkValid(dict[AssetPathsKey])
            return validPath && validAsset
        }
        if let dict = projectDict where validProject(dict) {
            project = dict |> XCProject.projectFromDictionary
        }
        
        store(project)
        return project
    }
    
    func store(item: T) {
        if let serialized = item?.serialized {
            NSUserDefaults.standardUserDefaults().setObject(serialized, forKey: ProjectKey)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(ProjectKey)
        }
    }
}

struct ImagesStorage {
    
    private let SelectionKey = "RecentlySelectedAssets"
    typealias T = ImageSelection
    
    func store(item: T) {
        if let serialized = item.serialized {
            NSUserDefaults.standardUserDefaults().setObject(serialized, forKey: SelectionKey)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(SelectionKey)
        }
    }
    
    func load() -> T {
        let srlz = NSUserDefaults.standardUserDefaults().objectForKey(SelectionKey) as? [Bookmark]
        let selection = ImageSelection.deserialize(srlz)
        store(selection)
        return selection
    }
}