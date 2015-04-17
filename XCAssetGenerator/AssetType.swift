//
//  XCAssetsImage.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/3/15.
//  Copyright (c) 2015 Pranav Shah. All rights reserved.
//

import Foundation

typealias SerializedAssetAttribute =  [String: String]

struct AssetAttribute: Serializable {
    var filename: String
    let scale: String
    let idiom: String
    let size: String?
    let extent: String?
    let subtype: String?
    let orientation: String?
    let minimumSystemVersion: String?
    
    // MARK: - Initializers
    
    private init (filename: String, scale: String, idiom: String, size: String? = nil, subtype: String? = nil, orientation: String? = nil, minimumSystemVersion: String? = nil, extent: String? = nil) {
        self.filename = filename
        self.scale = scale
        self.idiom = idiom
        self.size = size
        self.extent = extent
        self.subtype = subtype
        self.orientation = orientation
        self.minimumSystemVersion = minimumSystemVersion
    }
    
    // MARK: -
    
    typealias Serialized = SerializedAssetAttribute
    var serialized: Serialized {
        get {
            var s = [SerializedAssetAttributeKeys.Filename: filename, SerializedAssetAttributeKeys.Scale: scale, SerializedAssetAttributeKeys.Idiom: idiom]
            if let size = size {
                s.updateValue(size, forKey: SerializedAssetAttributeKeys.Size)
            }
            if let extent = extent {
                s.updateValue(extent, forKey: SerializedAssetAttributeKeys.Extent)
            }
            if let subtype = subtype {
                s.updateValue(subtype, forKey: SerializedAssetAttributeKeys.Subtype)
            }
            if let orientation = orientation {
                s.updateValue(orientation, forKey: SerializedAssetAttributeKeys.Orientation)
            }
            if let minimumSystemVersion = minimumSystemVersion {
                s.updateValue(minimumSystemVersion, forKey: SerializedAssetAttributeKeys.MinimumSystemVersion)
            }
            return s
        }
    }
}


enum AssetType {
    case Image
    case Icon
    case LaunchImage
    
}


struct Asset {
    let attributes: AssetAttribute
    let type: AssetType
    let path: Path
    
    // MARK: - Initializers
    
    private init(path: Path,type: AssetType) {
        self.type = type
        self.path = path
        switch self.type {
        case .Image:
            self.attributes = AssetAttributeProcessor.withAsset(path)
        case .Icon:
            self.attributes = AssetAttributeProcessor.withIcon(path)
        case .LaunchImage:
            self.attributes = AssetAttributeProcessor.withLaunchImage(path)
        }
    }
    
    static func create(path: Path) -> Asset {
        let name = path.lastPathComponent
        if name.hasPrefix("AppIcon") {
            return Asset(path: path, type: .Icon)
        } else if name.hasPrefix("LaunchImage") || name.hasPrefix("Default") {
            return Asset(path: path, type: .LaunchImage)
        } else {
            return Asset(path: path, type: .Image)
        }
    }
    
    // MARK: - Properties
    
    var enclosingFolder: Path {
        get {
            switch type {
            case .Image: return stripKeywords(path) + ".imageset"
            case .Icon: return "AppIcon.appiconset"
            case .LaunchImage: return "LaunchImage.launchimage"
            }
        }
    }
    
    typealias AssetComparator = (SerializedAssetAttribute -> Bool)
    var comparator: AssetComparator {
        get {
            
            let attribute = attributes
            switch type {
            case .Image:
                return { dict in
                    let sameIdiom = dict[SerializedAssetAttributeKeys.Idiom] as String? == attribute.idiom
                    let sameScale = dict[SerializedAssetAttributeKeys.Scale] as String? == attribute.scale
                    return sameIdiom && sameScale
                }
            case .Icon:
                return { dict in
                    let sameIdiom = dict[SerializedAssetAttributeKeys.Idiom] as String? == attribute.idiom
                    let sameScale = dict[SerializedAssetAttributeKeys.Scale] as String? == attribute.scale
                    let sameSize  = dict[SerializedAssetAttributeKeys.Size]  as String? == attribute.size
                    return sameIdiom && sameScale && sameSize
                }
            case .LaunchImage:
                return { dict in
                    let sameIdiom = dict[SerializedAssetAttributeKeys.Idiom] as String? == attribute.idiom
                    let sameScale = dict[SerializedAssetAttributeKeys.Scale] as String? == attribute.scale
                    let sameSubtype = dict[SerializedAssetAttributeKeys.Subtype] as String? == attribute.subtype
                    let sameOrientation = dict[SerializedAssetAttributeKeys.Orientation] as String? == attribute.orientation
                    return sameIdiom && sameScale && sameOrientation && sameSubtype
                }
            }
        }
    }
    
    // MARK: -
    
    ///
    /// Removes the various keywords used in Asset Generator.
    ///
    /// * scale: @1x, @2x, @3x
    /// * idiom: ~iphone, ~ipad
    /// * extention: .png, .jpg, etc.
    private func stripKeywords(path: Path) -> Path {
        var name = path.lastPathComponent.stringByDeletingPathExtension
        name = name.remove([GenerationKeywords.PPI2x,
                            GenerationKeywords.PPI3x,
                            GenerationKeywords.PPI1x,
                            GenerationKeywords.iPhone,
                            GenerationKeywords.iPad ])
        return name
    }
    
}

struct AssetAttributeProcessor {
    
    // usingAsset? withAsset? assetProcessor. process(asset:), with(asset:)
    static func withAsset(path: Path) -> AssetAttribute {
        let name = path.lastPathComponent
        
        let is2x = name.rangeOfString(GenerationKeywords.PPI2x) != nil
        let is3x = name.rangeOfString(GenerationKeywords.PPI3x) != nil
        let scale = is2x ? "2x" : is3x ? "3x" : "1x"
        
        let isiPhone = name.rangeOfString(GenerationKeywords.iPhone) != nil
        let isiPad = name.rangeOfString(GenerationKeywords.iPad) != nil
        let idiom = isiPhone ? "iphone" : isiPad ? "ipad" : "universal"
        
        return AssetAttribute(filename: name, scale: scale, idiom: idiom)
    }
    
    static func withIcon(path: Path) -> AssetAttribute {
        let imgURL = NSURL(fileURLWithPath: path)
        let src = CGImageSourceCreateWithURL(imgURL, nil)
        let result = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as NSDictionary
        
        let name = path.lastPathComponent
        let width = result[kCGImagePropertyPixelWidth as String]! as! Int
        
        var idiom = "iphone"
        var scale = "1x"
        var size = "60x60"
        
        switch width {
        case 60:
            break
        case 120:
            scale = "2x"
        case 180:
            scale = "3x"
        case 76:
            idiom = "ipad"
            size = "76x76"
        case 152:
            idiom = "ipad"
            scale = "2x"
            size = "76x76"
        default:
            break
        }
        
        return AssetAttribute(filename: name, scale: scale, idiom: idiom, size: size)
    }
    
    static func withLaunchImage(path: Path) -> AssetAttribute {
        let imgURL = NSURL(fileURLWithPath: path)
        let src = CGImageSourceCreateWithURL(imgURL, nil)
        let result = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as NSDictionary
        
        let name = path.lastPathComponent
        let width = result[kCGImagePropertyPixelWidth as String]! as! Float
        
        var idiom = "iphone"
        var scale = "1x"
        var subtype = ""
        var orientation = "portrait"
        var minimumVersion = "7.0"
        let extent = "full-screen"
        
        switch width {
        case 320:
            break
        case 640:
            scale = "2x"
            let height = result[kCGImagePropertyPixelHeight as String]! as! Float
            if (height == 1136) { subtype = "retina4" }
        case 1242:
            scale = "3x"
            subtype = "736h"
            minimumVersion = "8.0"
        case 750:
            scale = "2x"
            subtype = "667h"
            minimumVersion = "8.0"
        case 2208:
            scale = "3x"
            subtype = "736h"
            minimumVersion = "8.0"
        case 768:
            idiom = "ipad"
        case 1536:
            idiom = "ipad"
            scale = "2x"
        case 1024:
            idiom = "ipad"
            orientation = "landscape"
        case 2048:
            idiom = "ipad"
            scale = "2x"
            orientation = "landscape"
        default:
            break
        }

        return AssetAttribute(filename: name, scale: scale, idiom: idiom, extent: extent, subtype: subtype, orientation: orientation, minimumSystemVersion: minimumVersion)
    }

}

// TODO:
private enum DeviceType {
    case iPhone
    case iPad
    case Universal
    case Mac
    case Watch
}

