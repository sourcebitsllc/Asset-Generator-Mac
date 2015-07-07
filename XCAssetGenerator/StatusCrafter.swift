//
//  StatusViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

typealias Status = String

struct StatusCrafter {

    static func postGeneration(catalog: Path, amount: Int) -> Status {
        let s = pluralize(amount, singular: "asset was", plural: "assets were")
        return "\(s) added to \(catalog)."
    }
    
    static func status(#assets: [Asset]?, target: AssetCatalog?) -> Status {
        switch (assets, target) {
        case (.None, _):
            return "Drop a folder with slices you'd like to add to your Xcode project."
        case (.Some(let a), .None):
            let end = (a.count > 0) ? pluralize(a.count, singular: "asset", plural: "assets") : "assets"
            return "Choose an Xcode project to add " + end + "."
        case (.Some(let a), .Some(let catalog)) where a.count == 0:
            return "Add slices to the folder in order to build assets."
        case (.Some(let a), .Some(let catalog)):
            return newAssetsStatus(a, catalog: catalog)
        default:
            return ""
        }
    }
    
    private static func newAssetsStatus(assets: [Asset], catalog: AssetCatalog) -> Status {
        let total = AssetDiff.diffWithOperation(assets, catalog: catalog)(operation: .NewAssets)
        let n = pluralize(total, singular: "new asset", plural: "new assets")
        return  "Hit Build to add \(n) to your project."
    }
    
}


