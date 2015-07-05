//
//  ProjectError.swift
//  XCAssetGenerator
//
//  Created by Bader on 3/24/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa

enum ProjectSelectionError: ErrorType, Printable {
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
    
    var description: String {
        switch self {
        case .AssetNotFound(let project):
            return "AssetNotFound Error: project"
        case .ProjectNotFound:
            return "ProjectNotFound Error:"
        }
    }
}