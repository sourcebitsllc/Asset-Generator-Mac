//
//  DirectoryObserver.swift
//  XCAssetGenerator
//
//  Created by Bader on 11/5/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
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
        if let previousPath = self.observedPath {
            self.directoryObserver.removeObserverForPath(previousPath, restartStream: false)
        }
        
        self.observedPath = path
        self.directoryObserver.addObserver(self.observer, forFileSystemPath: path)
    }
    
    
    func stopObservingPath(path: Path) {
        self.observedPath = nil
        self.directoryObserver.removeObserverForPath(path)
    }
    
    
    func updatePathForObserver(#oldPath: String, newPath: String) -> Void {
        self.directoryObserver.replacePathForObserversFrom(oldPath, to: newPath)
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
        self.observePath(project.path)
        
        if project.hasValidAssetsPath() {
            self.observePath(project.assetPath!)
        }
    }
    
    func stopObservingProject(project: XCProject) {
        self.stopObservingPath(project.path)
        
        if project.hasValidAssetsPath() {
            self.stopObservingPath(project.assetPath!)
        }
    }
    
    func observePath(path: Path) {
        self.directoryObserver.addObserver(self.observer, forFileSystemPath: path)
    }
    
    func stopObservingPath(path: Path) {
        self.directoryObserver.removeObserverForPath(path)
    }
    
    
    func updatePathForObserver(#oldPath: String, newPath: String) -> Void {
        self.directoryObserver.replacePathForObserversFrom(oldPath, to: newPath)
    }
    
    func updateProjectForObserver(#oldProject: XCProject, newProject: XCProject) -> Void {
        self.updatePathForObserver(oldPath: oldProject.path, newPath: newProject.path)
        
        switch (oldProject.hasValidAssetsPath(), newProject.hasValidAssetsPath()) {
        case (true, true):
            self.updatePathForObserver(oldPath: oldProject.assetPath!, newPath: newProject.assetPath!)
        case (true, false):
            self.stopObservingPath(oldProject.assetPath!)
        case (false, true):
            self.observePath(newProject.assetPath!)
        case (false, false):
            fallthrough
        default:
            break;
        }
        
    }
}
