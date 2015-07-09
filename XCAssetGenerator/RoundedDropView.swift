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

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupRoundedness()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupRoundedness()
    }
    
    func setupRoundedness() {
        self.layer?.cornerRadius = self.frame.size.width / 2
        self.layer?.masksToBounds = true
    }
    
    override func layoutSubtreeIfNeeded() {
        setupRoundedness()
    }
}