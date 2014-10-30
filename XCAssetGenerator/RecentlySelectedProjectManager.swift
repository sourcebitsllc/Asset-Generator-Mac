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
    
    // Returns the title of the projects which will appear in the dropdown view
    func recentProjectsTitlesList() -> [String]? {
        return self.recentProjects?.map({ (proj: XCProject) -> String in
            return proj.title + "  > " + proj.assetDirectoryTitle()
        })
    }
    
    func recentProjectsCount() -> Int {
        return self.recentProjects?.count ?? 0
    }
    
    func removeProject(#project: XCProject) {
        if let projectsList = recentProjects {
            
            if let index: Int = find(projectsList, project) {
                recentProjects!.removeAtIndex(index)
            }
        }
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
    
//    func addProject(#path: String) {
//        addProject(project: XCProject(path: path))
//    }
    
    func addProject(#url: NSURL) {
        var data: NSData = url.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.SuitableForBookmarkFile, includingResourceValuesForKeys: nil, relativeToURL: nil, error: nil)!
        addProject(project: XCProject(data: data))
    }
    
    
    
    // MARK:- Convenience functions
    // TODO: Find better hooks for these calls.
    func storeRecentProjects() {
        let projects = self.recentProjects?.map({ (proj: XCProject) -> [NSString: NSData] in
            return proj.userDefaultsDictionaryRepresentation()
        })
        NSUserDefaults.standardUserDefaults().setObject(projects, forKey: kRecentProjectsKey)
    }
    
    func loadRecentProjects() {
        let projectDicts = NSUserDefaults.standardUserDefaults().objectForKey(kRecentProjectsKey) as? [NSDictionary]
        
       self.recentProjects = projectDicts?.map({ (a: NSDictionary) -> XCProject in
            return XCProject.projectFromDictionary(a as [String: NSData])
        })
    }
    
    private func flushStoredProjects() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kRecentProjectsKey)
    }
    
}