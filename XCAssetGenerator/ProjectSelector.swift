//
//  ProjectSelection.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/29/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import Result
import ReactiveCocoa


struct ProjectSelector {
        
    /// Given a URL, find a project with an AssetCatalog. Return ProjectSelectionError if none.
    static func excavateProject(url: Path) -> Result<XCProject, ProjectSelectionError> {
        let fromProject = assetFromProject <^> asProject(url)
        return fromProject ?? assetFromDirectory(url)
    }
    
    static func inspectProject(url: Path) -> Result<XCProject, ProjectSelectionError> {
        let fromProject = assetFromProject <^> asProject(url)
        return fromProject!
    }
    
    private static func assetFromDirectory(url: Path) -> Result<XCProject, ProjectSelectionError> {
        return retrieveProject(url) >>- assetFromProject
    }
    
    private static func asProject(url: Path) -> Path? {
        return url.isXCProject() ? url : nil
    }
    
    private static func retrieveProject(directory: Path) -> Result<Path, ProjectSelectionError> {
        let project = PathValidator.retreiveProject(directory)
        return (Result.success <^>  project) ?? Result.failure(ProjectSelectionError.ProjectNotFound)
    }
    
    private static func assetFromProject(url: Path) -> Result<XCProject, ProjectSelectionError> {
        let directory = url.stringByDeletingLastPathComponent + ("/")
        let hasAsset = PathValidator.directoryContainsXCAsset(directory: directory)
        let name = url.lastPathComponent
        return (hasAsset) ? Result.success(XCProject(path: url)) : Result.failure(ProjectSelectionError.AssetNotFound(name))
    }
    
}