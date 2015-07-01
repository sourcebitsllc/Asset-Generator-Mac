//
//  AssetCatalog.swift
//  XCAssetGenerator
//
//  Created by Bader on 10/6/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

struct AssetCatalog: Printable {
    let path: Path
    
    init(path: Path) {
        self.path = path
    }

    var title: String {
        return path.lastPathComponent
    }
    
    // MARK: - Printable
    
    var description: String {
        return path
    }
}

extension AssetCatalog: Serializable {
    
    // MARK: - Serializable
    
    typealias Serialized = Bookmark
    
    var serialized: Serialized {
        return BookmarkResolver.resolveBookmarkFromPath(path)
    }
}