//
//  AssetGeneratorInputValidator.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

struct AssetGeneratorInputValidator: Validator {
    
    static func validateSource(path: Path?) -> Bool {
        return (path != nil) ? PathValidator.directoryContainsImages(path: path!) : false
    }
    
//    static func validateTarget(project: XCProject?) -> Bool {
//        return (project != nil) ? ProjectValidator.isProjectValid(project!) && project!.hasValidAssetsPath() : false
//    }
    
    static func validateTarget(project: XCProject?) -> Bool {
        return (project != nil) ? ProjectValidator.isProjectValid(project!) && project!.hasValidAssetsPath() : false
    }
}