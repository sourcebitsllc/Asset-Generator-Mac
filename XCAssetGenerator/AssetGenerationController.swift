//
//  AssetGenerationController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/25/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

// TODO: hmm to functionally-identical protocols.... You know what to do.
protocol AssetGeneratorSource {
    var sourcePath: String? { get }
    func hasValidSourceProject() -> Bool
}

protocol AssetGeneratorDestination {
    var destinationPath: String? { get }
    func hasValidDestinationProject() -> Bool
}

enum ScriptOptions {
    case GenerateMissingAssets
    case CreateDesitnationIfMissing
}

class AssetGenerationController: NSObject {

    let assetGenerator: AssetGenerator
    var sourceDelegate: AssetGeneratorSource?
    var destinationDelegate: AssetGeneratorDestination?
    var progressDelegate: AssetGeneratorProgessDelegate? {
        set {
            assetGenerator.progressDelegate = newValue
        }
        
        get {
            return assetGenerator.progressDelegate
        }
    }
    
    override init() {
        assetGenerator = AssetGenerator()
        super.init()
    }
    
    func canExecuteScript() -> Bool {
        switch (sourceDelegate, destinationDelegate) {
        case (.Some(let source), .Some(let destination)):
            return source.hasValidSourceProject() && destination.hasValidDestinationProject() && !assetGenerator.executing()
        case (_,_):
            return false
        }
    }
    
    func executeScript(options: [ScriptOptions]?) {
        if let ops = options {
            let generate1x = contains(ops, ScriptOptions.GenerateMissingAssets)
            let createDest = contains(ops, ScriptOptions.CreateDesitnationIfMissing)
            executeScript(generate1x: generate1x, extraArgs: nil)
        } else {
            executeScript()
        }
    }
    private func executeScript() {
        assetGenerator.generateAssets(sourceDelegate!.sourcePath!, target: destinationDelegate!.destinationPath!)
    }
    
    private func executeScript(#generate1x: Bool, extraArgs args: [String]?) {
        assetGenerator.generateAssets(sourceDelegate!.sourcePath!, target: destinationDelegate!.destinationPath!)
    }
    
    
    // MARK:- For future usages, maybe.
    private func createNewAsset(#project: String) -> String {
        return project.stringByDeletingPathExtension + "/Images.xcassets"
    }
}
