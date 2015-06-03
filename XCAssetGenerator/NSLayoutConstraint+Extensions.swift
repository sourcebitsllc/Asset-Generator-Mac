//
//  NSLayoutConstraint+Extensions.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/27/15.
//  Copyright (c) 2015 Pranav Shah. All rights reserved.
//

import Cocoa

extension NSLayoutConstraint {
    static func centeringConstraints(view: NSView, into superView: NSView?) -> [NSLayoutConstraint] {
        let centerX: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        
        let centerY: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        
        return [centerX, centerY]
    }
    
    static func centeringConstraints(view: NSView, into superView: NSView?, size: NSSize) -> [NSLayoutConstraint] {
        let centerX = NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: superView, attribute: .CenterX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: superView, attribute: .CenterY, multiplier: 1, constant: 0)
        let widthAL = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: superView, attribute: .Width, multiplier: 0, constant: size.width)
        let heightAL = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: superView, attribute: .Height, multiplier: 0, constant: size.height)
        return [centerX, centerY, widthAL, heightAL]
    }
    
    static func fittingConstraints(view: NSView, into superView: NSView?) -> [NSLayoutConstraint] {
        let centerX = NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: superView, attribute: .CenterX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: superView, attribute: .CenterY, multiplier: 1, constant: 0)
        let widthAL = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: superView, attribute: .Width, multiplier: 1, constant: 0)
        let heightAL = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: superView, attribute: .Height, multiplier: 1, constant: 0)
        
        return [centerX, centerY, widthAL, heightAL]
    }
}