//
//  NSColor+Extensions.swift
//  XCAssetGenerator
//
//  Created by Bader on 6/10/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa

extension NSColor {
    static func dropViewAcceptedColor() -> NSColor {
        return NSColor(calibratedRed: 0.233, green: 0.819 , blue: 0.251, alpha: 1)
    }
    
    static func dropViewHoveringColor() -> NSColor {
        return NSColor(calibratedRed: 0.185, green: 0.390 , blue: 0.820, alpha: 1)
    }
    
    static func dropViewRejectedColor() -> NSColor {
        return NSColor(calibratedRed: 0.986, green: 0 , blue: 0.093, alpha: 1)
    }
}