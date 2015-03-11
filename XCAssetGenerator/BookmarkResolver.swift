//
//  BookmarkResolver.swift
//  XCAssetGenerator
//
//  Created by Bader on 10/30/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Foundation

typealias Path = String
typealias Bookmark = NSData

class BookmarkResolver {
    
    class func resolvePathFromBookmark(data: Bookmark) -> String? {
        let url = NSURL(byResolvingBookmarkData: data, options: NSURLBookmarkResolutionOptions.WithoutMounting, relativeToURL: nil, bookmarkDataIsStale: nil, error: nil)
        
        return url?.path ?? nil
    }
    
    class func resolveBookmarkFromPath(path: Path) -> Bookmark {
        let url: NSURL = NSURL(fileURLWithPath: path, isDirectory: true)!
        return resolveBookmarkFromURL(url)
    }
    
    // TODO: Potential bugs here. Reduce the amount
    class func resolveBookmarkFromURL(url: NSURL) -> Bookmark {
        var data: Bookmark = url.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.SuitableForBookmarkFile, includingResourceValuesForKeys: nil, relativeToURL: nil, error: nil)!
        
        return data
    }
}

extension BookmarkResolver {
    
    // Find better name for struct
    struct ResolvedBookmark {
        let bookmark: Bookmark
        let path: Path
    }
    class func resolveValidPathsFromBookmarks(bookmarks: [Bookmark]) -> [ResolvedBookmark] {
        
        var valid: [ResolvedBookmark] = [ResolvedBookmark]()
        
        for bookmark in bookmarks {
            let path: Path? = self.resolvePathFromBookmark(bookmark)
            if let p = path {
                valid.append(ResolvedBookmark(bookmark: bookmark, path: p))
            }
        }
        return valid
    }
}

protocol BookmarkValidator {}
    
extension BookmarkResolver: BookmarkValidator {
    
    class func isBookmarkValid(bookmark: Bookmark) -> Bool {
        let path: Path? = self.resolvePathFromBookmark(bookmark)
        return (path != nil) ? PathValidator.directoryExists(path: path!) : false
    }
}
