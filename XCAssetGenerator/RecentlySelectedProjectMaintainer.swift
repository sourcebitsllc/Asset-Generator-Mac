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


class RecentlySelectedProjectMaintainer : NSObject {
    
    private var recentProjects: [XCProject]?
    
    required override init() {
        super.init()
//        self.__flushStoredProjects
        self.loadRecentProjects()
    }
    
    
    // Return whether the selected project is suitable for script execution
    func isSelectedProjectValid() -> Bool {
        return (self.selectedProject()? != nil) ? self.isProjectValid(self.selectedProject()!) && self.selectedProject()!.hasValidAssetsPath() : false
    }
    
    // Returns whether a project _can_ exist.
    private func isProjectValid(project: XCProject) -> Bool {
        return PathBookmarkResolver.isBookmarkValid(project.pathBookmark)
    }
    
    
    // TODO: Too much state manipulation. fix it buddy yea? HEY? fix it.
    // TODO: ......
    // TODO: ...... Terrible .......
    // FIXME:
    func addProject(project newProject: XCProject) {
        self.addProject(project: newProject, index: 0)
    }
    
    func addProject(project newProject: XCProject, index: Int) {
        if let projectsList = recentProjects {
            
            if let index: Int = find(projectsList, newProject) {
                recentProjects!.removeAtIndex(index)
            }
            if projectsList.count == MaximumCacheCapacity {
                recentProjects!.removeLast()
            }
            recentProjects!.insert(newProject, atIndex: index)
            
        } else {
            recentProjects = [newProject]
        }
        
        self.storeRecentProjects()
    }

    
    func addProject(#url: NSURL) {
        var data: NSData = PathBookmarkResolver.resolveBookmarkFromURL(url)
        addProject(project: XCProject(data: data))
    }
    
    func removeProject(#project: XCProject) {
        if let projectsList = recentProjects {
            
            if let index: Int = find(projectsList, project) {
                recentProjects!.removeAtIndex(index)
            }
        }
    }
    
    func cullStaleProjectsAndAssets() -> Void {
        self.cullStaleProjects()
        self.cullStaleAssets()
        self.storeRecentProjects()
    }
    
    private func cullStaleProjects() -> Void {
        self.recentProjects =  self.recentProjects?.filter({ (project: XCProject) -> Bool in
            return self.isProjectValid(project)
        })
        
    }
    
    private func cullStaleAssets() -> Void {
        self.recentProjects = self.recentProjects?.map({ (project: XCProject) -> XCProject in
            if !project.hasValidAssetsPath() {
                return XCProject(data: project.pathBookmark)
            } else {
                return project
            }
        })
        
    }
}


// MARK:- Recent Project Queries Interface
extension RecentlySelectedProjectMaintainer {
    
    func recentProjectsCount() -> Int {
        return self.recentProjects?.count ?? 0
    }
    
    // TODO: If i can remove this function, it would make alot more sense.
    func projects() -> [XCProject]? {
        return self.recentProjects
    }
    
    // Returns the currenly selected Project/most recently used project. nil if "cache" empty.
    func selectedProject() -> XCProject? {
        return recentProjects?.first
    }
    
    func projectAtIndex(index: Int) -> XCProject? {
        return recentProjects?[index]
    }
    
    func indexOfProject(project: XCProject) -> Int? {
        return (self.recentProjects != nil) ? find(self.recentProjects!,project) : nil
    }
    
    // Returns the title of the projects which will appear in the dropdown view
    func recentProjectsTitlesList() -> [String]? {
        return self.recentProjects?.map({ (proj: XCProject) -> String in
            return proj.title + "  > " + proj.assetDirectoryTitle()
        })
    }
    
    
    private func recentProject(closure: (project: XCProject) -> Bool) -> XCProject? {
        let matches = self.recentProjects?.filter(closure)
        if matches?.count > 1 {
            println("Houston, we have a problem. Found multiple projects. with the same fucking asset path; which is not possible btw,")
        }
        
        return matches?.first
    }
    
    func recentProjectWithAsset(path: String) -> XCProject? {
        return recentProject({ (project) -> Bool in
            return project.assetDirectoryPath() == path
        })
    }
    
    func recentProjectWithPath(path: String) -> XCProject? {
        return recentProject({ (project) -> Bool in
            return project.path == path
        })
    }
}


extension RecentlySelectedProjectMaintainer {
   
    // TODO: Find better hooks for these calls.
    private func storeRecentProjects() {
        let projects = self.recentProjects?.map({ (proj: XCProject) -> [NSString: NSData] in
            return proj.userDefaultsDictionaryRepresentation()
        })
        NSUserDefaults.standardUserDefaults().setObject(projects, forKey: kRecentProjectsKey)
    }
    
    
    private func loadRecentProjects() {
        let projectDicts = NSUserDefaults.standardUserDefaults().objectForKey(kRecentProjectsKey) as? [NSDictionary]
        
        let validProjectDicts = projectDicts?.filter({ (dictionary: NSDictionary) -> Bool in
            return PathBookmarkResolver.isBookmarkValid(dictionary[pathKey]! as Bookmark)
        })
        
        self.recentProjects = validProjectDicts?.map({ (a: NSDictionary) -> XCProject in
            return XCProject.projectFromDictionary(a as [String: NSData])
        })
        
        //        self.cullStaleProjectsAndAssets()
        self.cullStaleAssets()
    }
    
    private func __flushStoredProjects() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kRecentProjectsKey)
    }
}
