//
//  XcodeFileValidatorProtocol.swift
//  XCAssetGenerator
//
//  Created by Bader on 11/11/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

// I always seem to sturggle on where to include the new types and protocols. Where should they be placed for best possible visibility.

import Foundation

protocol XcodeFileValidator {}

// TODO: We should probably check if its a directory too.
extension String: XcodeFileValidator {
    
    /*
        Determines whether the string is a project or asset. 
        NOTE: It does not determine whether that associated objects actually exist.
    */
    func isXCProject() -> Bool {
        return self.hasSuffix(".xcodeproj")
    }
    
    func isXCAsset() -> Bool {
        return self.hasSuffix(".xcassets")
    }
}

extension Bookmark: XcodeFileValidator {
    
    func isXCProject() -> Bool {
        let path: Path? = BookmarkResolver.resolvePathFromBookmark(self)
        return (path != nil) ? path!.isXCProject() : false
    }
    
    func isXCAsset() -> Bool {
        let path: String? = BookmarkResolver.resolvePathFromBookmark(self)
        return (path != nil) ? path!.isXCAsset() : false
    }
    
}

