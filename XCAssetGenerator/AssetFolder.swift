//
//  AssetFolder.swift
//  XCAssetGenerator
//
//  Created by Bader on 10/6/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Foundation

func == (lhs: AssetFolder, rhs: AssetFolder) -> Bool {
    // TODO: This needs a rethink.
    if lhs.bookmark == rhs.bookmark { return true }
    
    switch ( ProjectValidator.isAssetValid(lhs), ProjectValidator.isAssetValid(rhs) ) {
        case (true, true): return lhs.path == rhs.path
        case (false, false): return true
        case (_,_): return false
    }
}

func == (lhs: AssetFolder?, rhs: AssetFolder?) -> Bool {
    switch (lhs, rhs) {
        case (.Some(let a), .Some(let b)): return a == b
        case (.None,.None): return true
        case (_,_): return false
    }
}

// MARK:- Printable Protocol
extension AssetFolder: Printable {
    
    var description: String {
        get {
            return self.path
        }
    }
    
    var title: String {
        get {
            return self.path.lastPathComponent
        }
    }
}



// The bookmark data canot be invalid in here. It doesnt make sense for an AssetFolder to not exist.
// So, invalid data = crash. Protect.Yo.Self.
struct AssetFolder: Equatable {
    
    var bookmark: Bookmark
    let path: Path
    
    init (bookmark: Bookmark) {
        self.bookmark = bookmark
        self.path = BookmarkResolver.resolvePathFromBookmark(bookmark)!
    }
    
    init (bookmark: Bookmark, path: Path) {
        self.bookmark = bookmark
        self.path = path
    }
    
}