//
//  AssetGeneratorInputValidator.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

struct AssetGeneratorInputValidator {
    
    static func validateSource(selection: [Asset]?) -> Bool {
        return selection?.count > 0
    }
    
    static func validateTarget(catalog: AssetCatalog?) -> Bool {
        return catalog.map { PathValidator.directoryExists(path: $0.path) } ?? false
    }
}