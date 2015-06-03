//
//  NSImage+Extensions.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/20/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {
    static func systemImage(path: Path, size: NSSize) -> NSImage {
        let image = NSWorkspace.sharedWorkspace().iconForFile(path)
        image.size = size
        return image
    }
}