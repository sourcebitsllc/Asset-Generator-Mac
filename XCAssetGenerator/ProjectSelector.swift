//
//  ProjectSelection.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/29/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import Result


struct ProjectSelector {
    
    // Can this be done to be more linear? something like >>-,<^> withouth ??
    
    /// Given a URL, find a project with an AssetCatalog. Return ProjectSelectionError if none.
    static func excavateProject(url: NSURL) -> Result<NSURL, ProjectSelectionError> {
        let fromProject = assetFromProject <^> asProject(url)
        return fromProject ?? assetFromDirectory(url)
    }
    
    private static func assetFromDirectory(url: NSURL) -> Result<NSURL, ProjectSelectionError> {
        return retrieveProject(url) >>- assetFromProject
    }
    
    private static func asProject(url: NSURL) -> NSURL? {
        return url.path!.isXCProject() ? url : nil
    }
    
    private static func retrieveProject(directory: NSURL) -> Result<NSURL, ProjectSelectionError> {
        let project = PathValidator.retreiveProject(directory)
        return (Result.success <^> project) ?? Result.failure(ProjectSelectionError.NoProjectFound)
    }
    
    private static func assetFromProject(url: NSURL) -> Result<NSURL, ProjectSelectionError> {
        let directory = url.path!.stringByDeletingLastPathComponent + ("/")
        let hasAsset = PathValidator.directoryContainsXCAsset(directory: directory)
        let name = url.path!.lastPathComponent
        return (hasAsset) ? Result.success(url) : Result.failure(ProjectSelectionError.AssetNotFound(name))
    }
    
}