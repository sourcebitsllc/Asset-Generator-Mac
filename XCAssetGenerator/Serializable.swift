//
//  Serializable.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/9/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

protocol Serializable  {
    typealias Serialized
    
    /// Return a serialized representation of value
    ///
    var serialized: Serialized { get }
    
    /// Create new value from Serialized parameter
    ///
    /// :param: 
    /// :returns: Deserialzed value
//    func create(from: Serialized) -> Self
}