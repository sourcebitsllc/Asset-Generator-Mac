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
    
    func asAssets() -> [Asset]? {
        return analysis(
            ifNone: { nil },
            ifImages: { $0.map { Asset(fullPath: $0, ancestor: $0.stringByDeletingLastPathComponent) } },
            ifFolder: { folder in PathQuery.availableImages(from: folder).map { Asset(fullPath: $0, ancestor: folder)}})
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
            ifImages: { paths in
                let a = paths.map(BookmarkResolver.resolveBookmarkFromPath).flatMap { $0 != nil ? [$0!] : [] }
                
                return a.count > 0 ? a : nil
            },
            ifFolder: { folder in
                let s = BookmarkResolver.resolveBookmarkFromPath(folder)
                return s != nil ? [s!] : nil
        })
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