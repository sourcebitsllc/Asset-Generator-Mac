//
//  CABasicAnimation+Extensions.swift
//  XCAssetGenerator
//
//  Created by Bader on 6/25/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa

extension CABasicAnimation {
    static func shakeAnimation(#magnitude: Float) -> CABasicAnimation {
        let anim = CABasicAnimation(keyPath: "position.x")
        anim.duration = 0.05
        anim.repeatCount = 3
        anim.autoreverses = true
        anim.fromValue = magnitude
        anim.toValue = -magnitude
        anim.additive = true
        return anim
    }
}