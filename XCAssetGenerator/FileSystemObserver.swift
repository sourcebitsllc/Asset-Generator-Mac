//
//  FileSystemObserver.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/28/15.
//  Copyright (c) 2015 Pranav Shah. All rights reserved.
//

import Foundation
import ReactiveCocoa

class FileSystemSignal {
    
    ///
    ///
    let renameSignal: Signal<Path, NoError>
    private let renameSink: Signal<Path, NoError>.Observer
   
    /// 
    /// On receiving an Event on this Signal, all the other Signal will cease sending Events and observer will only receive events upon `observe`ing again.
    let deleteSignal: Signal<Void, NoError>
    private let deleteSink: Signal<Void, NoError>.Observer
    
    ///
    ///
    let contentChangedSignal: Signal<Void, NoError>
    private let contentChangedSink: Signal<Void, NoError>.Observer
    
    var queue: dispatch_queue_t =  dispatch_queue_create("com.assetgenerator.XCAssetGeneratr.signalObserver", DISPATCH_QUEUE_CONCURRENT)
    private var filde: CInt!
    private var source: dispatch_queue_t?
    
    // Hack
    private var bookmark: Bookmark!
    
    convenience init(path: Path) {
        self.init()
        observe(path)
    }
    
    init() {
        (renameSignal, renameSink) = Signal<Path, NoError>.pipe()
        (deleteSignal, deleteSink) = Signal<Void, NoError>.pipe()
        (contentChangedSignal, contentChangedSink) = Signal<Void, NoError>.pipe()
    }
    
    private func handleDelete() {
        sendNext(deleteSink, Void())
        cancel()
    }
    
    private func handleRename(path: Path) {
        if let p = BookmarkResolver.resolvePathFromBookmark(bookmark) where PathValidator.directoryExists(path: p) {
            sendNext(renameSink, p)
        } else {
            handleDelete()
        }
    }
    
    func observe(path: Path) {
        cancel()

        bookmark = BookmarkResolver.resolveBookmarkFromPath(path)
        filde = open(path, O_EVTONLY)

        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, UInt(filde), DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_RENAME, queue)
        
        dispatch_source_set_event_handler(source!, {
            let flags = dispatch_source_get_data(self.source!)
            if (flags & DISPATCH_VNODE_DELETE != 0) {
                self.handleDelete()
            }
            
            if (flags & DISPATCH_VNODE_WRITE != 0) {
                sendNext(self.contentChangedSink, Void())
            }
            
            if (flags & DISPATCH_VNODE_RENAME != 0) {
                self.handleRename(path)
            }
            
        })
        
        // copy old file descriptor. (That way, we wont close the current file descriptor). Thanks Obama.
        let oldfd = filde
        dispatch_source_set_cancel_handler(source!, {
            // This cancel handler is called so late in the runloop that it will cancel the newly created source!.
            // Which will have catasttrophic consequences on the next generated source. (closing the filde of the previous source will also close the filde of the newly created source, its that late!
            close(oldfd)
        })
        
        
        dispatch_resume(source!)
    }
    
    func test_put() {
        sendNext(self.contentChangedSink, Void())
        sendNext(renameSink, "")
    }
    
    func cancel() -> Bool {
        if (source != nil) {
            dispatch_source_cancel(source!)
            source = nil
            return true
        }
        return false
    }
    
}