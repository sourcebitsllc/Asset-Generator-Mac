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
        return "\(s) added to \(catalog)"
    }
    
    static func status(selection: ImageSelection, target: XCProject?) -> Status {
        switch (selection, target?.catalog) {
        case (.Folder, .Some(let catalog)):
            return newAssetsStatus(selection.asAssets(), catalog: catalog)
        case (.Images, .Some(let catalog)):
            return newAssetsStatus(selection.asAssets(), catalog: catalog)
        case (.None ,_):
            fallthrough
        case (_, .None):
            return "Drop a folder with slices you'd like to add to your Xcode project"
        default:
            return ""
        }
        
    }
    
    private static func newAssetsStatus(assets: [Asset], catalog: AssetCatalog) -> Status {
        let total = AssetDiff.diffWithOperation(assets, catalog: catalog)(operation: .NewAssets)
        let n = pluralize(total, singular: "new asset", plural: "new assets")
        return  "Hit Build to add \(n) to your project"
    }
    
}


