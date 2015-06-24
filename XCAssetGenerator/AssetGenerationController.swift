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


/*

class AssetGeneration {
    var progress: Enum Progress. Or signal
    var running/executing: MutableProperty<Bool>(false)
    var assetGenerationSignalProducer: SignalProducer<ENUM,ERROR>

    var assetsGenerated: Signal // MAYBE but not necessarily necessary.

    + Need to refactor assetGeneration to integrate SignalProducer with my logic. (in essense, delegate calls become sink dumps.
}
*/

enum AssetGeneratorError: ErrorType {
    case InvalidSource
    case InvalidCatalog
    
    var nsError: NSError {
        return NSError()
    }
}


enum AssetGenerationOptions {
    case GenerateMissingAssets
    case CreateDesitnationIfMissing
}

class AssetGenerationController: NSObject {

    private let assetGenerator: AssetGenerator
    let running: MutableProperty<Bool> = MutableProperty<Bool>(false)
    
    override init() {
        assetGenerator = AssetGenerator()
        super.init()
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
