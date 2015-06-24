//
//  AssetGeneratorInputValidator.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

struct AssetGeneratorInputValidator: Validator {
    
    static func validateSource(selection: [Asset]?) -> Bool {
        return selection?.count > 0
    }
    
//    static func validateTarget(project: XCProject?) -> Bool {
//        return (project != nil) ? ProjectValidator.isProjectValid(project!) && project!.hasValidAssetsPath() : false
//    }
    
    static func validateTarget(project: XCProject?) -> Bool {
        return (project != nil) ? ProjectValidator.isProjectValid(project!) && project!.hasValidAssetsPath() : false
    }
}