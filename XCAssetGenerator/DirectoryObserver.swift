//
//  DirectoryObserver.swift
//  XCAssetGenerator
//
//  Created by Bader on 11/5/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

// Maybe have a base class with all the proper layouts and have the subclasses override the cool shit and augment the rest?
import Foundation

// These classes can be the stateful "shell" to the immutable + stateless cores.
class SourceObserver {
    
    typealias SourceDirectoryObserverClosure = FileSystemObserverBlock
    
    let sourceClosure: SourceDirectoryObserverClosure
    
    var directoryObserver: FileSystemObserver
    var observedPath: String?
    
    init(sourceObserver: SourceDirectoryObserverClosure) {
        sourceClosure = sourceObserver
        directoryObserver = FileSystemObserver()
    }
    
    
    func observeSource(path: String) -> Void {
        if let previousPath = self.observedPath {
            self.directoryObserver.removeObserverForPath(previousPath, restartStream: false)
            
        }
        
        self.observedPath = path
        self.directoryObserver.addObserverForPath(path, handler: self.sourceClosure)
    }
    
    
    func stopObservingPath(path: String) {
        self.observedPath = nil
        self.directoryObserver.removeObserverForPath(path)
    }
    
    
    func updatePathForObserver(#oldPath: String, newPath: String) -> Void {
        self.directoryObserver.replacePathForObserversFrom(oldPath, to: newPath)
    }
}

class ProjectObserver {

    typealias DestinationDirectoryObserverClosure = FileSystemObserverBlock
    

    let destinationClosure: DestinationDirectoryObserverClosure
    
    var directoryObserver: FileSystemObserver
    
    init(projectObserver: DestinationDirectoryObserverClosure) {
        directoryObserver  = FileSystemObserver()
        destinationClosure = projectObserver
    }
    
    
    func observeProject(project: XCProject) -> Void {
        self.observePath(project.path)
        
        if project.hasValidAssetsPath() {
            self.observePath(project.assetDirectoryPath()!)
        }
    }
    
    func stopObservingProject(project: XCProject) {
        self.stopObservingPath(project.path)
        
        if project.hasValidAssetsPath() {
            self.stopObservingPath(project.assetDirectoryPath()!)
        }
    }
    
    func observePath(path: String) {
        self.directoryObserver.addObserverForPath(path, handler: self.destinationClosure)
    }
    
    func stopObservingPath(path: String) {
        self.directoryObserver.removeObserverForPath(path)
    }
    
    
    func updatePathForObserver(#oldPath: String, newPath: String) -> Void {
        self.directoryObserver.replacePathForObserversFrom(oldPath, to: newPath)
    }
    
    func updateProjectForObserver(#oldProject: XCProject, newProject: XCProject) -> Void {
        self.updatePathForObserver(oldPath: oldProject.path, newPath: newProject.path)
        
        switch (oldProject.hasValidAssetsPath(), newProject.hasValidAssetsPath()) {
        case (true, true):
            self.updatePathForObserver(oldPath: oldProject.assetDirectoryPath()!, newPath: newProject.assetDirectoryPath()!)
        case (true, false):
            self.stopObservingPath(oldProject.assetDirectoryPath()!)
        case (false, true):
            self.observePath(newProject.assetDirectoryPath()!)
        case (false, false):
            fallthrough
        default:
            break;
        }
        
    }
}


class DirectoryObserver {
    
    typealias SourceDirectoryObserverClosure = FileSystemObserverBlock
    typealias DestinationDirectoryObserverClosure = FileSystemObserverBlock

    
    enum DirectoryType {
        case SourceDirectory
        case DestinationDirectory
    }
    
    let sourceClosure: SourceDirectoryObserverClosure!
    let projectClosure: DestinationDirectoryObserverClosure!
    
    var directoryObserver: FileSystemObserver
    
    
    init(sourceObserver: SourceDirectoryObserverClosure, destinationObserver: DestinationDirectoryObserverClosure) {
        sourceClosure = sourceObserver
        projectClosure = destinationObserver
        directoryObserver = FileSystemObserver()
    }
    
    init(sourceObserver: SourceDirectoryObserverClosure) {
        sourceClosure = sourceObserver
        directoryObserver = FileSystemObserver()
    }

    // There should only be 1 source. Thus, remove the old path if it exists.
    func observeSource(path: String) -> Void {
        let previousPath = self.directoryObserver.pathForBlock(self.sourceClosure)
        if (previousPath != nil) {
            self.directoryObserver.removeObserverForPath(previousPath, restartStream: false)
        }
        
        self.directoryObserver.addObserverForPath(path, handler: self.sourceClosure)
    }
    

    
    func observeDestination(path: String) -> Void {
        self.directoryObserver.addObserverForPath(path, handler: self.projectClosure)
    }
    
    func stopObservingPath(path: String) {
        self.directoryObserver.removeObserverForPath(path)
    }
    
    func updatePathForObserver(#oldPath: String, newPath: String) -> Void {
        self.directoryObserver.replacePathForObserversFrom(oldPath, to: newPath)
    }
    
}
