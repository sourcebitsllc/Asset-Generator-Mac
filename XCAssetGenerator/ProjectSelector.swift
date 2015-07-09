//
//  ProjectSelection.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/29/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Result
import ReactiveCocoa

enum ProjectSelectionError: ErrorType {
    
    case AssetNotFound(String)
    case ProjectNotFound
    
    var nsError: NSError {
        let message: String
        switch self {
        case .AssetNotFound(let project):
            message = "The selected project (\(project)) does not contain a valid xcassets folder."
        case .ProjectNotFound:
            message = NSLocalizedString("The selected folder does not contain an Xcode Project.",comment: "")
        }
        return NSError(domain: "com.sourcebits.assetgenerator", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

struct ProjectSelector {
        
    /// Given a URL, find a project with an AssetCatalog. Return ProjectSelectionError if none.
    static func excavateProject(url: Path) -> Result<XCProject, ProjectSelectionError> {
        return projectFromPath(url) >>- assetFromProject
    }

    private static func projectFromPath(path: Path) -> Result<Path, ProjectSelectionError> {
        return asProject(path).map { Result.success($0) } ?? retrieveProject(path)
    }
    
    private static func asProject(url: Path) -> Path? {
        return url.isXCProject() ? url : nil
    }
    
    private static func retrieveProject(directory: Path) -> Result<Path, ProjectSelectionError> {
        let project = PathValidator.retreiveProject(directory)
        return project.map(Result.success) ?? Result.failure(ProjectSelectionError.ProjectNotFound)
    }
    
    private static func assetFromProject(url: Path) -> Result<XCProject, ProjectSelectionError> {
        let directory = url.stringByDeletingLastPathComponent + ("/")
        let hasAsset = PathValidator.directoryContainsXCAsset(directory: directory)
        let name = url.lastPathComponent
        return (hasAsset) ? Result.success(XCProject(path: url)) : Result.failure(ProjectSelectionError.AssetNotFound(name))
    }
    
}
