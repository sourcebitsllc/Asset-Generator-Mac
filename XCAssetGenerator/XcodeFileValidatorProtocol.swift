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

extension String: XcodeFileValidator {
    func isXCProject() -> Bool {
        return self.hasSuffix(".xcodeproj")
    }
    
    func isXCAsset() -> Bool {
        return self.hasSuffix(".xcassets")
    }
}

extension Bookmark: XcodeFileValidator {
    func isXCProject() -> Bool {
        let path: String? = PathBookmarkResolver.resolvePathFromBookmark(self)
        
        if let validPath = path {
            return validPath.isXCProject()
        } else {
            return false
        }
    }
    
    func isXCAsset() -> Bool {
        let path: String? = PathBookmarkResolver.resolvePathFromBookmark(self)
        
        if let validPath = path {
            return validPath.isXCAsset()
        } else {
            return false
        }
    }
}

