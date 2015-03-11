//
//  XCAsset.swift
//  XCAssetGenerator
//
//  Created by Bader on 10/6/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Foundation

func == (lhs: XCAsset, rhs: XCAsset) -> Bool {
    return lhs.path == rhs.path
}

func == (lhs: XCAsset?, rhs: XCAsset?) -> Bool {
    switch (lhs, rhs) {
        case (.Some(let a), .Some(let b)): return a == b
        case (.None,.None): return true
        case (_,_): return false
    }
}

// MARK:- Printable Protocol
extension XCAsset: Printable {
    
    var description: String {
        get {
            return "\(self.path)"
        }
    }
    
    var title: String {
        get {
            return self.path.lastPathComponent
        }
    }
}



// The bookmark data canot be invalid in here. It doesnt make sense for an XCAsset to not exist.
// So, invalid data = crash. Protect.Yo.Self.
struct XCAsset: Equatable {
    var data: Bookmark
    
    internal private(set) var path: String {
        get {
            // This may be not ideal; we can just access the string property. But its better to get the "truth" directly from its source.
            return BookmarkResolver.resolvePathFromBookmark(self.data)!
        }
        
        set {
            path = newValue
        }
        
    }
    
    init (data aData: Bookmark) {
        data = aData
    }
    
    init (data aData: Bookmark, path aPath: String) {
        data = aData
        path = aPath
    }
    
}