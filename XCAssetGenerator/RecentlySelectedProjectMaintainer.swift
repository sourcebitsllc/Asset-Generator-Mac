//
//  RecentlySelectedProjectCacheManager.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/13/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Foundation

let kRecentProjectsKey = "XCAssetGeneratorRecentProjects"
let kSelectionStateKey = "XCAssetGeneratorSetProject"
let MaximumCacheCapacity: Int = 10


class RecentlySelectedProjectMaintainer : NSObject {
    
    private var recentProjects: [XCProject]?
    
    var didSetProject: Bool = false
    
    required override init() {
        super.init()
//        __flushStoredProjects()
        loadRecentProjects()
    }
    
    
    // Return whether the selected project is suitable for script execution
    func isSelectedProjectValid() -> Bool {
        return (selectedProject != nil) ? ProjectValidator.isProjectValid(selectedProject!) && selectedProject!.hasValidAssetsPath() : false
    }

    // TODO: Too much state manipulation. fix it buddy yea? HEY? fix it.
    // TODO: ......
    // TODO: ...... Terrible .......
    // FIXME:
    func addProject(#project: XCProject) {
        addProject(project: project, index: 0)
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
        didSetProject = true
        storeRecentProjects()
    }

    
    func addProject(#url: NSURL) {
        let bookmark: Bookmark = BookmarkResolver.resolveBookmarkFromURL(url)
        addProject(project: XCProject(bookmark: bookmark))
    }
    
    func removeProject(#project: XCProject) {
        if let projectsList = recentProjects, let index: Int = find(projectsList, project)  {
            recentProjects!.removeAtIndex(index)
            storeRecentProjects()
        }
    }
    
    private func cullStaleAssets() {
        recentProjects = recentProjects?.map { (project: XCProject) -> XCProject in
            return !project.hasValidAssetsPath() ? XCProject(bookmark: project.bookmark) : project
        }
    }
}


// MARK:- Recent Project Queries Interface
extension RecentlySelectedProjectMaintainer {
    
    func resetSelectedProject() {
        didSetProject = false
        storeSelectionState()
    }
    
    func recentProjectsCount() -> Int {
        return recentProjects?.count ?? 0
    }
    
    // TODO: If i can remove this function, it would make alot more sense.
    func projects() -> [XCProject]? {
        return recentProjects
    }
    
    var selectedProject: XCProject? {
        get {
            return (didSetProject) ? recentProjects?.first : nil
        }
    }

    func projectAtIndex(index: Int) -> XCProject? {
        return recentProjects?[index]
    }
    
    func indexOfProject(project: XCProject) -> Int? {
        return (recentProjects != nil) ? find(recentProjects!,project) : nil
    }
    
    // Returns the title of the projects which will appear in the dropdown view
    func recentProjectsTitlesList() -> [String]? {
        return recentProjects?.map { proj in
                return proj.title + "  > " + proj.assetTitle
        }
    }
    
    // Returns the most recent project matching the predicate indicated in the closure.
    private func recentProject(closure: (project: XCProject) -> Bool) -> XCProject? {
        let matches = recentProjects?.filter(closure)
        if matches?.count > 1 {
            println("[XCAssetGenerator] Houston, we have a problem. Found multiple projects for a check that should return one.")
        }
        
        return matches?.first
    }
    
    func recentProjects(filter: (project: XCProject) -> Bool) -> [XCProject]? {
        return recentProjects?.filter(filter)
    }
    
}

extension RecentlySelectedProjectMaintainer {
   
    // TODO: Find better hooks for these calls.
    private func storeRecentProjects() {
        let projects = recentProjects?.map { $0.serialized }
        NSUserDefaults.standardUserDefaults().setObject(projects, forKey: kRecentProjectsKey)
        storeSelectionState()
    }
    
    private func storeSelectionState() {
        NSUserDefaults.standardUserDefaults().setBool(didSetProject, forKey: kSelectionStateKey)
    }
    
    ///
    ///
    private func loadRecentProjects() {
        let projectDicts = NSUserDefaults.standardUserDefaults().objectForKey(kRecentProjectsKey) as? [[String: NSData]]
        didSetProject = NSUserDefaults.standardUserDefaults().boolForKey(kSelectionStateKey)
        
        func validProject(dict: [String: NSData]) -> Bool {
            let validPath =  BookmarkResolver.isBookmarkValid(dict[PathKey])
            let validAsset = BookmarkResolver.isBookmarkValid(dict[AssetPathsKey])
            return validPath && validAsset
        }
        
        // Make sure the current selected project is valid and adjust the selection state accordingly.
        if let dict = projectDicts?.first where didSetProject {
            didSetProject = validProject(dict)
        }
        // Filter out invalid/corrupted projects
        recentProjects = projectDicts?.filter(validProject)
                                      .map(XCProject.projectFromDictionary)
        storeRecentProjects()
    }
    
    private func __flushStoredProjects() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kRecentProjectsKey)
    }
}