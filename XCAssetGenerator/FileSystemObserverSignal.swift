//
//  FileSystemSignal.swift
//  XCAssetGenerator
//
//  Created by Bader on 7/1/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//


import Foundation
import ReactiveCocoa

class FileSystemProjectObserver: NSObject, FileSystemObserverDelegate {
    var observer: FileSystemObserver
    
    let projectSignal: Signal<XCProject?, NoError>
    private let projectSink: Signal<XCProject?, NoError>.Observer
    
    let catalogSignal: Signal<AssetCatalog, NoError>
    private let catalogSink: Signal<AssetCatalog, NoError>.Observer
    
    let catalogContentSignal: Signal<Void, NoError>
    private let catalogContentSink: Signal<Void, NoError>.Observer
    
    override init() {
        observer = FileSystemObserver()
        
        (projectSignal, projectSink) = Signal<XCProject?, NoError>.pipe()
        (catalogSignal, catalogSink) = Signal<AssetCatalog, NoError>.pipe()
        (catalogContentSignal, catalogContentSink) = Signal<Void, NoError>.pipe()
    }
    
    func observe(project: XCProject?) -> Bool {
        if let project = project, catalog = project.catalog {
            observer.addObserver(self, forFileSystemPath: project.path, ignoreContents: true)
            observer.addObserver(self, forFileSystemPath: catalog.path, ignoreContents: false)
            return true
        } else {
            stop()
            return false
        }
    }
    
    func stop() {
        observer.removeAllObservers()
    }
    

    @objc func FileSystemDirectory(oldPath: String!, renamedTo newPath: String!) {
        if oldPath.isXCProject() && newPath.isXCProject() {
            sendNext(projectSink, XCProject(path: newPath))
        }
        
        if oldPath.isAssetCatalog() && newPath.isAssetCatalog() {
            sendNext(catalogSink, AssetCatalog(path: newPath))
        }
    }
    
    @objc func FileSystemDirectoryContentChanged(root: String!) {
        
        sendNext(catalogContentSink, Void())
    }
    
    @objc func FileSystemDirectoryDeleted(path: String!) {
        sendNext(projectSink, nil)
    }
    
    @objc func FileSystemDirectoryError(error: NSError!) {
        // TODO:
    }

}

class FileSystemImagesObserver: NSObject, FileSystemObserverDelegate {
    var observer: FileSystemObserver
    
    private var current: ImageSelection


    let selectionSignal: Signal<ImageSelection, NoError>
    private let selectionChangedSink: Signal<ImageSelection, NoError>.Observer
    
    let contentChangedSignal: Signal<Void, NoError>
    private let contentChangedSink: Signal<Void, NoError>.Observer
    
    override init() {
        observer = FileSystemObserver()
        current = .None
        
        (selectionSignal, selectionChangedSink) = Signal<ImageSelection, NoError>.pipe()
        (contentChangedSignal, contentChangedSink) = Signal<Void, NoError>.pipe()
    }
    
    func observe(selection: ImageSelection) {
        current = selection
        stop()
        switch current {
        case .None:
            break
        case .Folder(let path):
            observer.addObserver(self, forFileSystemPath: path, ignoreContents: false)
        case .Images(let paths):
            observer.addObserver(self, forFileSystemPaths: paths, ignoreContents: true)
        }
    }
    
    func stop() {
        observer.removeAllObservers()
    }
    
    func FileSystemDirectory(oldPath: String!, renamedTo newPath: String!) {

        switch current {
        case .Folder:
            sendNext(selectionChangedSink, ImageSelection.create(newPath))
        case .Images(var paths):
            let idx = find(paths, oldPath)
            if let idx = idx {
                paths.removeAtIndex(idx)
                paths.append(newPath)
                sendNext(selectionChangedSink, ImageSelection.create(paths))
            }
        case .None:
            break
        }
    }
    
    func FileSystemDirectoryContentChanged(root: String!) {
        sendNext(contentChangedSink, Void())
    }
    
    func FileSystemDirectoryDeleted(path: String!) {

        switch current {
        case .Folder:
            sendNext(selectionChangedSink, .None)
        case .Images(var paths):
            let idx = find(paths, path)
            if let idx = idx {
                paths.removeAtIndex(idx)
                sendNext(selectionChangedSink, ImageSelection.create(paths))
            }
        case .None:
            break
        }
    }
    
    func FileSystemDirectoryError(error: NSError!) {
        // TODO:
    }
    
}

