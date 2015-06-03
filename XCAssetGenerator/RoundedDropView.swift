//
//  RoundDropView.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/11/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import Cocoa


class RoundedDropView : DropView {
//    @IBInspectable var radius: Float = 25 {
//        didSet {
//            self.layer?.cornerRadius = CGFloat(radius)
//        }
//    }
//    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setItUp()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setItUp()
    }
    
    func setItUp() {
        self.layer?.cornerRadius = self.bounds.size.width / 2
        self.layer?.masksToBounds = true
    }
    
}