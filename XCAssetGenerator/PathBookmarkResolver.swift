//
//  PathBookmarkResolver.swift
//  XCAssetGenerator
//
//  Created by Bader on 10/30/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Foundation


typealias Bookmark = NSData

class PathBookmarkResolver {
    
    
    class func resolvePathFromBookmark(data: Bookmark) -> String? {
        let url = NSURL(byResolvingBookmarkData: data, options: NSURLBookmarkResolutionOptions.WithoutMounting, relativeToURL: nil, bookmarkDataIsStale: nil, error: nil)
        
        if let p = url {
            return p.path!
        } else {
            return nil
        }
    }
    
    class func resolveBookmarkFromPath(path: String) -> Bookmark {
        let url: NSURL = NSURL(fileURLWithPath: path, isDirectory: true)!
        return resolveBookmarkFromURL(url)
    }
    
    
    class func resolveBookmarkFromURL(url: NSURL) -> Bookmark {
        var data: Bookmark = url.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.SuitableForBookmarkFile, includingResourceValuesForKeys: nil, relativeToURL: nil, error: nil)!
        
        return data
    }
}

extension PathBookmarkResolver {
    typealias PathBookmark = (path: String, bookmark: Bookmark)
    
    class func resolveValidPathsFromBookmarks(data: [Bookmark]) -> [PathBookmark] {
        
        var valid: [PathBookmark] = [PathBookmark]()
        
        for d in data {
            let path: String? = self.resolvePathFromBookmark(d)
            if let p = path {
                valid.insert((p,d), atIndex: 0)
            }
        }
//        let validData = data.filter({ (d: NSData) -> Bool in
//            let path: String? = self.resolvePathFromBookmark(d)
//            return (path != nil) ? true : false
//        })
//        
//        let valid: [(String, NSData)] = validData.map({ (d: NSData) -> (String, NSData) in
//            return (self.resolvePathFromBookmark(d)!, d)
//        })
        return valid
    }
}

protocol BookmarkValidator {
}
    
extension PathBookmarkResolver: BookmarkValidator {
    class func isBookmarkValid(bookmark: Bookmark) -> Bool {
        let path: String? = self.resolvePathFromBookmark(bookmark)
        if path == nil {
            return false
        } else {
            return true
        }
    }
}



