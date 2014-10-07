//
//  RecentlySelectedProjectCacheManager.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/13/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Foundation

let kRecentProjectsKey: String = "XCAssetGeneratorRecentProjects"
let MaximumCacheCapacity: Int = 10


class RecentlySelectedProjectManager : NSObject {
    
    private var recentProjects: [XCProject]?
    
    required override init() {
        super.init()
//        self.flushStoredProjects()
        self.loadRecentProjects()
    }
    
    // Returns the currenly selected Project/most recently used project. nil if "cache" empty.
    func selectedProject() -> XCProject? {
        return recentProjects?.first
    }
    
    func projectAtIndex(index: Int) -> XCProject? {
        return recentProjects?[index]
    }
    
    // Returns true if the selected project contains a xcasset folder.
    func isSelectedProjectValid() -> Bool {
        return (self.selectedProject()? != nil) ? self.selectedProject()!.hasValidAssetsPath() : false
    }
    
    // Returns a sorted list of the titles of the most recently used "projects"
    func recentProjectsTitlesList() -> [String]? {
        return self.recentProjects?.map({ (proj: XCProject) -> String in
            return proj.title
        })
    }
    
    func recentProjectsCount() -> Int {
        return self.recentProjects?.count ?? 0
    }
    
    
    // TODO: Too much state manipulation. fix it buddy yea? HEY? fix it.
    // TODO: ......
    // TODO: ...... Terrible .......
    // FIXME:
    func addProject(project newProject: XCProject) {
        if let projectsList = recentProjects {
        
            if let index: Int = find(projectsList, newProject) {
                recentProjects!.removeAtIndex(index)
            }
            if projectsList.count == MaximumCacheCapacity {
                recentProjects!.removeLast()
            }
            recentProjects!.insert(newProject, atIndex: 0)
            
        } else {
            recentProjects = [newProject]
        }
        
        self.storeRecentProjects()
    }
    
    func addProject(#path: String) {
        addProject(project: XCProject(path: path))
    }
    
    
    
    // MARK:- Convenience functions
    // TODO: Find better hooks for these calls.
    func storeRecentProjects() {
        let projects = self.recentProjects?.map({ (proj: XCProject) -> [NSString: NSString] in
            return proj.userDefaultsDictionaryRepresentation()
        })
        NSUserDefaults.standardUserDefaults().setObject(projects, forKey: kRecentProjectsKey)
    }
    
    func loadRecentProjects() {
        let projectDicts = NSUserDefaults.standardUserDefaults().objectForKey(kRecentProjectsKey) as? [NSDictionary]
        
       self.recentProjects = projectDicts?.map({ (a: NSDictionary) -> XCProject in
            return XCProject.projectFromDictionary(a as [String: String])
        })
    }
    
    func flushStoredProjects() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kRecentProjectsKey)
    }
    
}