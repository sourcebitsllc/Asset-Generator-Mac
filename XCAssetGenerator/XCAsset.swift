//
//  XCAsset.swift
//  XCAssetGenerator
//
//  Created by Bader on 10/6/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Foundation

func == (lhs: XCAsset, rhs: XCAsset) -> Bool {
    return lhs.path == rhs.path
}

func == (lhs: XCAsset?, rhs: XCAsset?) -> Bool {
    switch (lhs, rhs) {
        case (.Some(let a), .Some(let b)) : return a == b
        case (_,_): return false
    }
}

// MARK:- Printable Protocol
extension XCAsset: Printable {
    
    var description: String {
        get {
            return "\(self.title) -- asset path: \(self.path),"
        }
    }
    
    var title: String {
        get {
            return self.path.lastPathComponent
        }
    }
}


struct XCAsset: Equatable {
    var path: String
    
    init (path aPath: String) {
        path = aPath
//        println(path)
    }
    

}