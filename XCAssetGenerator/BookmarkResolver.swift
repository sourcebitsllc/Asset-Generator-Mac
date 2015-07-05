//
// BookmarkResolver.swift
// XCAssetGenerator
//
// Created by Bader on 10/30/14.
// Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

typealias Path = String
typealias Bookmark = NSData

struct BookmarkResolver {
    
    static func resolvePathFromBookmark(data: Bookmark) -> Path? {
        let url = NSURL(byResolvingBookmarkData: data, options: NSURLBookmarkResolutionOptions.WithoutMounting, relativeToURL: nil, bookmarkDataIsStale: nil, error: nil)
        return url?.path ?? nil
    }
    
    static func resolveBookmarkFromPath(path: Path) -> Bookmark? {
        let url: NSURL = NSURL(fileURLWithPath: path)!
        return resolveBookmarkFromURL(url)
    }
    
    // TODO: Potential bugs here. Reduce the amount
    static func resolveBookmarkFromURL(url: NSURL) -> Bookmark? {
        return url.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.SuitableForBookmarkFile, includingResourceValuesForKeys: nil, relativeToURL: nil, error: nil)
    }
}
