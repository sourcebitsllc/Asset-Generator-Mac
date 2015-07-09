//
//  AssetGenerationController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/25/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa
import Result
import ReactiveCocoa

enum GenerationState {
    case Progress(Float)
    case Assets(Int)
}

enum AssetGeneratorError: ErrorType {
    case InvalidSource
    case InvalidCatalog
    
    var nsError: NSError {
        return NSError()
    }
}

class AssetGenerationController {

    private let assetGenerator: AssetGenerator
    let running: MutableProperty<Bool> = MutableProperty<Bool>(false)
    
    init() {
        assetGenerator = AssetGenerator()
    }
    
    func assetGenerationProducer(assets: [Asset]?, destination: Path?) -> SignalProducer<GenerationState, AssetGeneratorError> {
        return SignalProducer { (sink, disposable) in
            self.running.put(true)
            
            // TODO: Swift 2.0 guard + defer.
            if assets == nil {
                sendError(sink, .InvalidSource)
                self.running.put(false)
                return
            }
            
            if destination == nil {
                sendError(sink, .InvalidCatalog)
                self.running.put(false)
                return
            }
            
            self.assetGenerator.generateAssets(assets!, target: destination!)(observer: sink) {
                self.running.put(false)
            }
        }
    }
    
    func prepare(path: Path) -> Path {
        if !path.hasSuffix("/") {
            return path + "/"
        }
        return path
    }
    
    func intermedieteDirectory() -> Path {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first as! Path
        return cacheDir + "/.XCAssetTemp/"
    }
}
