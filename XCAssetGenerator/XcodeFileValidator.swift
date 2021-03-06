//
//  XcodeFileValidatorProtocol.swift
//  XCAssetGenerator
//
//  Created by Bader on 11/11/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

protocol XcodeFileValidator {
    func isXCProject() -> Bool
    func isAssetCatalog() -> Bool
}

// TODO: We should probably check if its a directory too.
extension String: XcodeFileValidator {
    
    /*
        Determines whether the string is a project or asset. 
        NOTE: It does not determine whether that associated objects actually exist.
    */
    func isXCProject() -> Bool {
        return self.hasSuffix(".xcodeproj")
    }
    
    func isAssetCatalog() -> Bool {
        return self.hasSuffix(".xcassets")
    }
    
    func isAssetSet() -> Bool {
        return PathValidator.isAssetSet(self)
    }
}

extension PathValidator {
    static func isAssetSet(path: Path) -> Bool {
        return path.hasSuffix(".imageset") || path.hasSuffix(".appiconset") || path.hasSuffix(".launchimage")
    }
}