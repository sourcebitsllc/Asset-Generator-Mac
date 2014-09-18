//
//  RecentlySelectedProjectCacheManager.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/13/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

import Foundation

let RecentProjectsKey: String = "XCAssetGeneratorRecentProjects"
let pathKey = "path"
let assetPathKey = "assetPath"

struct Project : Any {
    let title: String
    let path: String
    let thumbnailImage: NSData?
}

typealias Path = (title: String, path: String)

struct XCProject {
    var path: String {
        didSet {
            println("Did set path")
            self.xcassetPathFinder()
        }
    }
    private var xcassetPath: String?
    
    
    mutating private func xcassetPathFinder() {
        var task: NSTask = NSTask()
        task.launchPath = "/usr/bin/find"
        task.arguments = [self.XCProjectDirectoryPath(), "-name", "*.xcassets"]
        
        var pipe = NSPipe()
        task.standardOutput = pipe
        
        task.launch()
        
        var string: String = NSString(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
        
        var paths = string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\n"))
        println("\(paths.first)")
        self.xcassetPath = paths.first
    }
    
    private func XCProjectDirectoryPath() -> String {
        return self.path.stringByDeletingLastPathComponent + ("/") // .extend
    }
    
    func assetDirectoryPath() -> String? {
        return xcassetPath
    }
    func hasValidAssetsPath() -> Bool {
        return (self.xcassetPath? != nil) ? true : false
    }
    
    // Conform XCProject to AnyObject protocol. // Not ideal but no time. TODO:
    func dictionaryRepresentation() -> [String: String] {
        return [pathKey: self.path, assetPathKey: self.xcassetPath ?? ""]
    }
    func userDefaultsDictionaryRepresentation() -> [NSString: NSString] {
        return self.dictionaryRepresentation()
    }
    
    static func projectFromDictionary(dictionary: [String: String]) -> XCProject {
        let path = dictionary[pathKey]!
        let asset: String? = dictionary[assetPathKey]!.isEmpty ? nil : dictionary[assetPathKey]!
        return XCProject(path: path, xcassetPath: asset)
    }
    
    func description() -> String {
        return "[\(self)] -- path: \(self.path), asset path: \(self.xcassetPath)"
    }
}


let MaximumCacheCapacity: Int = 10

class RecentlySelectedProjectManager : NSObject {
    
//    private var recentProjects: [String]?
    private var recentProjects: [XCProject]?
    
    required override init() {
        super.init()
//        self.loadRecentProjects()
        
        var z = XCProject(path: "c", xcassetPath: nil)
        var x = XCProject(path: "b", xcassetPath: "gg")
        self.recentProjects = [z, x]
//        println(z.description())
        var s: NSDictionary = z.userDefaultsDictionaryRepresentation()
        println([z.dictionaryRepresentation()])
        var ss: NSArray = [s]
        NSUserDefaults.standardUserDefaults().setObject(ss, forKey: "v")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Read.
        var projects1 = self.recentProjects?.map({ (proj: XCProject) -> [NSString: NSString] in
            return proj.userDefaultsDictionaryRepresentation()
        })
        
        println(projects1)
        NSUserDefaults.standardUserDefaults().setObject(projects1, forKey: "asd")
        
        // Write
        var rr = NSUserDefaults.standardUserDefaults().objectForKey("asd") as [NSDictionary]
        
        var projects: [XCProject] = rr.map({ (a: NSDictionary) -> XCProject in
            return XCProject.projectFromDictionary(a as [String: String])
        })
        for  a in projects {
            println("****")
            println(a.description())
        }
        
//        println(NSUserDefaults.standardUserDefaults().valueForKey("v"))
//        let recentProjectsDictionaries = NSUserDefaults.standardUserDefaults().arrayForKey("v") as [NSDictionary]
//        var projects: [XCProject] = recentProjectsDictionaries.map({ (a: NSDictionary) -> XCProject in
//            return XCProject.projectFromDictionary(a as [String: String])
//        })
//        for  a in projects {
//            println("****")
//            println(a.description())
//        }
//        var projects : [Project] = recentProjectsDictionaries?.map({ (dict: [String: String?]) -> Project in
//            return XCProject.projectFromDictionary(dict)
//        })
//        var Projects: [Project] = recentProjectsDictionaries?.
//        var a = [proj]
//        var c: NSData = NSArchiver.archivedDataWithRootObject(proj)
//        var b = a.map { (proj : XCProject) -> NSData in
//            return NSArchiver.archivedDataWithRootObject(proj)
//        }
//        NSUserDefaults.standardUserDefaults().setObject(a, forKey: "ASDASDASD")
        //        recentProjects = ["Home", "User", "Bader", "Downloads"]
    }
    
    // Returns the currenly selected Project/most recently used project. nil if "cache" empty.
    func selectedProject() -> XCProject? {
        return recentProjects?.first
    }
    
    func isSelectedProjectValid() -> Bool {
        return (self.selectedProject()? != nil) ? self.selectedProject()!.hasValidAssetsPath() : false
    }
    
    // Returns a sorted list of the most recently used "projects"
    func recentProjectsTitlesList() -> [String]? {
        return self.recentProjects?.map({ (proj: XCProject) -> String in
            return proj.path
        })
    }
    
    // TODO: Too much state manipulation. fix it buddy yea? HEY? fix it.
    // TODO: ......
    // TODO: ...... Terrible .......
    func addProject(path: String) {
        if let projectsList = recentProjects {
            
            let storedProjectPaths = projectsList.map() { (proj: XCProject) -> String in
                return proj.path
            }
            
            if let index: Int = find(storedProjectPaths, path) {
                recentProjects!.removeAtIndex(index)
            }
            if projectsList.count == MaximumCacheCapacity {
                recentProjects!.removeLast()
            }
            recentProjects!.insert(XCProject(path: path, xcassetPath: nil), atIndex: 0)
            
        } else {
            recentProjects = [XCProject(path: path, xcassetPath: nil)]
        }
        
        self.storeRecentProjects()
    }
    
    // MARK:- Convenience functions
    // TODO: Find better hooks for these calls.
    func storeRecentProjects() {
        let projects = self.recentProjects?.map({ (proj: XCProject) -> [NSString: NSString] in
            return proj.userDefaultsDictionaryRepresentation()
        })
        NSUserDefaults.standardUserDefaults().setObject(projects, forKey: RecentProjectsKey)
    }
    
    func loadRecentProjects() {
        let projectDicts = NSUserDefaults.standardUserDefaults().objectForKey(RecentProjectsKey) as [NSDictionary]
        
       self.recentProjects = projectDicts.map({ (a: NSDictionary) -> XCProject in
            return XCProject.projectFromDictionary(a as [String: String])
        })
//        recentProjects = NSUserDefaults.standardUserDefaults().arrayForKey(RecentProjectsKey)
    }
    
    func flushStoredProjects() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(RecentProjectsKey)
    }
    
}