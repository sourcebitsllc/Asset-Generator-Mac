//
//  XCAssetsImage.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/3/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

enum AssetType {
    case Image
    case Icon
    case LaunchImage
    
    static func type(#path: Path) -> AssetType {
        return type(name: path.lastPathComponent)
    }
    
    static func type(#name: String) -> AssetType {
        if isIcon(name) {
            return .Icon
        } else if isLaunchImage(name) {
            return .LaunchImage
        } else {
            return .Image
        }
    }
    
    static func isIcon(name: String) -> Bool {
        return name.hasPrefix("AppIcon") || name.hasPrefix("Icon") || isMacIcon(name)
    }
    static func isMacIcon(name: String) -> Bool {
        return name.hasPrefix("icon_")
    }
    
    static func isLaunchImage(name: String) -> Bool {
        return name.hasPrefix("LaunchImage") || name.hasPrefix("Default")
    }
}

struct AssetMetaData {
    let attributes: AssetAttribute
    let type: AssetType
    
    private init(path: Path,type: AssetType) {
        self.type = type
        switch self.type {
        case .Image:
            self.attributes = AssetAttributeProcessor.withAsset(path)
        case .Icon:
            self.attributes = AssetAttributeProcessor.withIcon(path)
        case .LaunchImage:
            self.attributes = AssetAttributeProcessor.withLaunchImage(path)
        }
    }
    
    static func create(path: Path) -> AssetMetaData {
        let type = AssetType.type(path: path)
        return AssetMetaData(path: path, type: type)
    }
    
    static func create(asset: Asset) -> AssetMetaData {
        return create(asset.fullPath)
    }
    
    typealias AssetComparator = (XCAssetsJSON -> Bool)
    var comparator: AssetComparator {
        let attribute = attributes
        
        switch type {
        case .Image:
            return { dict in
                let sameIdiom = dict[XCAssetsJSONKeys.Idiom] as! String? == attribute.idiom
                let sameScale = dict[XCAssetsJSONKeys.Scale] as! String? == attribute.scale
                return sameIdiom && sameScale
            }
        case .Icon:
            return { dict in
                let sameIdiom = dict[XCAssetsJSONKeys.Idiom] as! String? == attribute.idiom
                let sameScale = dict[XCAssetsJSONKeys.Scale] as! String? == attribute.scale
                let sameSize  = dict[XCAssetsJSONKeys.Size]  as! String? == attribute.size
                return sameIdiom && sameScale && sameSize
            }
        case .LaunchImage:
            return { dict in
                let sameIdiom = dict[XCAssetsJSONKeys.Idiom] as! String? == attribute.idiom
                let sameScale = dict[XCAssetsJSONKeys.Scale] as! String? == attribute.scale
                let sameSubtype = dict[XCAssetsJSONKeys.Subtype] as! String? == attribute.subtype
                let sameOrientation = dict[XCAssetsJSONKeys.Orientation] as! String? == attribute.orientation
                return sameIdiom && sameScale && sameOrientation && sameSubtype
            }
        }
    }
}

struct Asset: Printable {
    let type: AssetType
    
    let ancestor: Path
    let fullPath: Path
    
    var name: Path {
        return fullPath.lastPathComponent
    }
    
    var description: String {
        return fullPath
    }
    
    /// Return path relative to its ancestor.
    /// Basically fullPath - ancestor
    var relativePath: Path {
        return fullPath.remove([ancestor])
    }

    // MARK: - Initializers
    
    init(fullPath path: Path, ancestor: Path) {
        self.fullPath = path
        self.ancestor = ancestor
        self.type = AssetType.type(path: path)
    }

    
    // MARK: - Properties
    
    var enclosingSet: Path {
        switch type {
        case .Image:
            return stripKeywords(fullPath) + ".imageset"
        case .Icon:
            return "AppIcon.appiconset"
        case .LaunchImage:
            return "LaunchImage.launchimage"
        }
    }
    
    // MARK: -
    
    ///
    /// Removes the various keywords used in Asset Generator.
    ///
    ///  scale: @1x, @2x, @3x
    ///  idiom: ~iphone, ~ipad
    ///  extention: .png, .jpg, etc.
    private func stripKeywords(path: Path) -> Path {
        var name = path.lastPathComponent.stringByDeletingPathExtension.remove([GenerationKeywords.PPI2x,
                                                                                GenerationKeywords.PPI3x,
                                                                                GenerationKeywords.PPI1x,
                                                                                GenerationKeywords.iPhone,
                                                                                GenerationKeywords.iPad,
                                                                                GenerationKeywords.Mac ])
        return name
    }
}

enum Device {
    case iPhone
    case iPad
    case Universal
    case Mac
    case Watch
    case NotYetKnownLol
}
