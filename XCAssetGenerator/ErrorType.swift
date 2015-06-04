//
//  ProjectError.swift
//  XCAssetGenerator
//
//  Created by Bader on 3/24/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa

enum ProjectSelectionError: ErrorType {
    case AssetNotFound(String)
    case ProjectNotFound
    
    var message: String {
        get {
            switch self {
            case .AssetNotFound(let project):
                return "The selected project (\(project)) does not contain a valid xcassets folder."
            case .ProjectNotFound:
                return NSLocalizedString("The selected folder does not contain an Xcode Project.",comment: "")
            }
        }
    }
    
    var nsError: NSError {
        return NSError(domain: message, code: 0, userInfo: nil)
    }
   
}