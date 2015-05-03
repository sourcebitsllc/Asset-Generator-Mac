//
//  DirectoryObserver.swift
//  XCAssetGenerator
//
//  Created by Bader on 11/5/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

// Maybe have a base class with all the proper layouts and have the subclasses override the cool shit and augment the rest?
import Foundation


protocol FileSystemObserverType {}

class SourceObserver: FileSystemObserverType {
    
    
    var directoryObserver: FileSystemObserver
    var observedPath: String?
    var observer: FileSystemObserverDelegate
    
    init(delegate: FileSystemObserverDelegate) {
        self.observer = delegate
        directoryObserver = FileSystemObserver()
    }
    
    
    func observeSource(path: Path) -> Void {
        if let previousPath = observedPath {
            directoryObserver.removeObserverForPath(previousPath, restartStream: false)
        }
        
        observedPath = path
        directoryObserver.addObserver(observer, forFileSystemPath: path)
    }
    
    
    func stopObservingPath(path: Path) {
        observedPath = nil
        directoryObserver.removeObserverForPath(path)
    }
    
    
    func updatePathForObserver(#oldPath: String, newPath: String) -> Void {
        directoryObserver.replacePathForObserversFrom(oldPath, to: newPath)
    }
}

class ProjectObserver: FileSystemObserverType {
    
    var directoryObserver: FileSystemObserver
    var observer: FileSystemObserverDelegate
    
    init(delegate: FileSystemObserverDelegate) {
        directoryObserver  = FileSystemObserver()
        self.observer = delegate
    }
    
    
    func observeProject(project: XCProject) -> Void {
        observePath(project.path)
        
        if project.hasValidAssetsPath() {
            observePath(project.assetPath!)
        }
    }
    
    func stopObservingProject(project: XCProject) {
        stopObservingPath(project.path)
        
        if project.hasValidAssetsPath() {
            stopObservingPath(project.assetPath!)
        }
    }
    
    func observePath(path: Path) {
        directoryObserver.addObserver(observer, forFileSystemPath: path)
    }
    
    func stopObservingPath(path: Path) {
        directoryObserver.removeObserverForPath(path)
    }
    
    
    func updatePathForObserver(#oldPath: String, newPath: String) -> Void {
        directoryObserver.replacePathForObserversFrom(oldPath, to: newPath)
    }
    
    func updateProjectForObserver(#oldProject: XCProject, newProject: XCProject) -> Void {
        updatePathForObserver(oldPath: oldProject.path, newPath: newProject.path)
        
        switch (oldProject.hasValidAssetsPath(), newProject.hasValidAssetsPath()) {
        case (true, true):
            updatePathForObserver(oldPath: oldProject.assetPath!, newPath: newProject.assetPath!)
        case (true, false):
            stopObservingPath(oldProject.assetPath!)
        case (false, true):
            observePath(newProject.assetPath!)
        case (false, false):
            fallthrough
        default:
            break;
        }
        
    }
}
