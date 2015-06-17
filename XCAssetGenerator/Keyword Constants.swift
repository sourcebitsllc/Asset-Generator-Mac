//
//  Keywords.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/8/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

struct GenerationKeywords {
    static let PPI1x = "@1x"
    static let PPI2x = "@2x"
    static let PPI3x = "@3x"
    
    static let iPhone = "~iphone"
    static let iPad = "~ipad"
    static let Mac = "~mac"
    static let Watch = "~watch"
}

struct SerializedAssetAttributeKeys {
    static let Filename = "filename"
    static let Scale = "scale"
    static let Idiom = "idiom"
    
    static let Size = "size"
    
    static let Orientation = "orientation"
    static let Extent = "extent"
    static let Subtype = "sub-type"
    static let MinimumSystemVersion = "minimum-system-version"
    
    static let WidthClass = "widthClass"
    static let HeightClass = "heightClass"
    
    static let Alignment = "alignment-insets"
    
    // watch
    static let ScreenWidth = "screenWidth"
    static let Role = "role"

}
