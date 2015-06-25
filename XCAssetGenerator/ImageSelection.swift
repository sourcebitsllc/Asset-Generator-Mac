//
//  ImageSelection.swift
//  XCAssetGenerator
//
//  Created by Bader on 6/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

enum ImageSelection: Printable, Serializable {
    case Images([Path])
    case Folder(Path)
    case None
    
    // TODO: Documentation
    static func create(path: Path) -> ImageSelection {
        return isSupportedImage(path) ? .Images([path]) : PathValidator.directoryExists(path: path) ? .Folder(path) : .None
    }
    
    static func create(paths: [Path]) -> ImageSelection {
        if paths.count == 1 {
            return create(paths[0])
        }
        let acceptable = paths.filter(isSupportedImage)
        return acceptable.count > 0 ? .Images(acceptable) : .None
    }
    
    func analysis<T>(@noescape #ifNone: () -> T, @noescape ifImages: [Path] -> T, @noescape ifFolder: Path -> T) -> T {
        switch self {
        case .None:
            return ifNone()
        case .Images(let images):
            return ifImages(images)
        case .Folder(let folder):
            return ifFolder(folder)
        }
    }
    
    // MARK: - Printable
    
    var description: String {
        return analysis(
            ifNone: { "None:" },
            ifImages: { "Image: \($0)" },
            ifFolder: { "Folder: \($0)" })
    }
    
    
    // MARK: - Serializable
    
    typealias Serialized = [Bookmark]?
    
    var serialized: Serialized {
        return analysis(
            ifNone: { nil },
            ifImages: { $0.map(BookmarkResolver.resolveBookmarkFromPath) },
            ifFolder: { [BookmarkResolver.resolveBookmarkFromPath($0)] })
    }
    
    static func deserialize(serial: Serialized) -> ImageSelection {
        if let s = serial {
            let paths = s.map(BookmarkResolver.resolvePathFromBookmark).filter { $0 != nil }.map{ $0! } as [Path]
            return create(paths)
        } else {
            return .None
        }
    }
}