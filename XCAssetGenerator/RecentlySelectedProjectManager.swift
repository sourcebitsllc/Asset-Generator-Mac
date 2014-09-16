//
//  RecentlySelectedProjectCacheManager.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/13/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

import Foundation

let RecentProjectsKey: String = "XCAssetGeneratorRecentProjects"


struct Project : Any {
    let title: String
    let path: String
    let thumbnailImage: NSData?
}

typealias Path = (title: String, path: String)

let MaximumCacheCapacity: Int = 10

class RecentlySelectedProjectManager : NSObject {
    
    private var recentProjects: [String]?
    
    required override init() {
        super.init()
        self.loadRecentProjects()
//        recentProjects = ["Home", "User", "Bader", "Downloads"]
    }
    
    // Returns the currenly selected Project/most recently used project. nil if "cache" empty.
    func selectedProject() -> String? {
        return recentProjects?.first
    }
    
    func isSelectedProjectValid() -> Bool {
        return (self.selectedProject()? != nil) ? true : false
    }
    
    // Returns a sorted list of the most recently used "projects"
    func recentProjectsList() -> [String]? {
        let list = recentProjects
        return list
    }
    
    // TODO: Too much state manipulation. fix it buddy yea? HEY? fix it.
    // TODO: ......
    // TODO: ...... Terrible .......
    func addProject(path: String) {
        if let projectsList = recentProjects {
            if contains(projectsList, path) {
                let index: Int = find(projectsList, path)!
                recentProjects!.removeAtIndex(index)
            }
            if projectsList.count == MaximumCacheCapacity {
                recentProjects!.removeLast()
            }
            recentProjects!.insert(path, atIndex: 0)
            
        } else {
            recentProjects = [path]
        }
        
        self.storeRecentProjects()
    }
    
    // MARK:- Convenience functions
    // TODO: Find better hooks for these calls.
    func storeRecentProjects() {
        NSUserDefaults.standardUserDefaults().setObject(self.recentProjects, forKey: RecentProjectsKey)
    }
    
    func loadRecentProjects() {
        recentProjects = NSUserDefaults.standardUserDefaults().arrayForKey(RecentProjectsKey) as? [String]
    }
    
    func flushStoredProjects() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(RecentProjectsKey)
    }
    
}