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

class RecentlySelectedProjectManager : NSObject {
    
    private var recentProjects: [String]?
    let MaximumCacheCapacity: Int = 15
    
    required override init() {
        super.init()
        recentProjects = NSUserDefaults.standardUserDefaults().arrayForKey(RecentProjectsKey) as? [String]
        recentProjects = ["Home", "User", "Bader", "Downloads"]
    }
    
    
    // Returns the currenly selected Project/most recently used project.
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
    
    // TODO: Too much state manipulation. fix it buddy.
    func addProject(path: String) {
        if let projectsList = recentProjects {
            if contains(projectsList, path) {
                let index: Int = find(projectsList, path)!
                recentProjects?.removeAtIndex(index)
            }
            if recentProjects!.count == self.MaximumCacheCapacity {
                recentProjects?.removeLast()
            }
            recentProjects?.insert(path, atIndex: 0)
            
        } else {
            recentProjects?.append(path)
        }
    }
    
    
    
}