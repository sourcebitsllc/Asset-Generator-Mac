//
//  Pluralize.swift
//  XCAssetGenerator
//
//  Created by Bader on 6/10/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

func pluralize(amount: Int, #singular: String, #plural: String) -> String {
    switch amount {
    case 1:
        return "1 \(singular)"
    case let a:
        return "\(a) \(plural)"
    }
}