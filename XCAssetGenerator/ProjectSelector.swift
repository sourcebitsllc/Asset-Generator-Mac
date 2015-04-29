//
//  ProjectSelection.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/29/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import Result
import Box


struct ProjectSelector {
    
    /// Given a URL, find an assetsCatalog. Return ProjectSelectionError if none.
    static func excavateProject(url: NSURL) -> Result<NSURL, ProjectSelectionError> {
        return (assetFromProject <^> asProject(url)) ?? assetFromDirectory(url)
    }
    
    private static func assetFromDirectory(url: NSURL) -> Result<NSURL, ProjectSelectionError> {
        return retreiveProject(url) >>- assetFromProject
    }
    
    private static func asProject(url: NSURL) -> NSURL? {
        return url.path!.isXCProject() ? url : nil
    }
    
    private static func retreiveProject(directory: NSURL) -> Result<NSURL, ProjectSelectionError> {
        let project = PathValidator.retreiveProject(directory)
        return map(project, Result.success) ?? Result.failure(ProjectSelectionError.NoProjectFound)
    }
    
    private static func assetFromProject(url: NSURL) -> Result<NSURL, ProjectSelectionError> {
        let directory = url.path!.stringByDeletingLastPathComponent + ("/")
        let hasAsset = PathValidator.directoryContainsXCAsset(directory: directory)
        let name = url.path!.lastPathComponent
        return (hasAsset) ? .Success(Box(url)) : .Failure(Box(ProjectSelectionError.AssetNoFound(name)))
    }
    
}