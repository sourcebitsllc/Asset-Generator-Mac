//
//  AssetGenerationController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/25/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

enum AssetGenerationOptions {
    case GenerateMissingAssets
    case CreateDesitnationIfMissing
}

protocol AssetGeneratorInput {
    var source: Path? { get }
    var target: Path? { get }
    
    func hasValidGeneratorInputs() -> Bool
}

class AssetGenerationController: NSObject {

    private let assetGenerator: AssetGenerator
    var delegate: AssetGeneratorInput?
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
    
    func canPreformAssetGeneration() -> Bool {
        return delegate?.hasValidGeneratorInputs() ?? false
    }
    
    func executeScript(options: [AssetGenerationOptions]?) {
        if let ops = options {
            let generate1x = contains(ops, .GenerateMissingAssets)
            let createDest = contains(ops, .CreateDesitnationIfMissing)
            preformAssetGeneration(generate1x: generate1x, extraArgs: nil)
        } else {
            preformAssetGeneration()
        }
    }
    
    private func preformAssetGeneration() {
        assetGenerator.generateAssets(delegate!.source!, target: delegate!.target!)
    }
    
    private func preformAssetGeneration(#generate1x: Bool, extraArgs args: [String]?) {
        assetGenerator.generateAssets(delegate!.source!, target: delegate!.target!)
    }
}
