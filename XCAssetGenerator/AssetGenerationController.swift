//
//  AssetGenerationController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/25/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa
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



enum AssetGenerationOptions {
    case GenerateMissingAssets
    case CreateDesitnationIfMissing
}

class AssetGenerationController: NSObject {

    private let assetGenerator: AssetGenerator

    var assetGeneratorSignal: SignalProducer<Float, NoError>!
    let generatedSignal: Signal<Int, NoError>
    private let generatedSink: SinkOf<Event<Int, NoError>>
    
    let running: MutableProperty<Bool> = MutableProperty<Bool>(false)
    let source: MutableProperty<Path?>
    let target: MutableProperty<Path?>
    
    
    override init() {
        assetGenerator = AssetGenerator()
        source = MutableProperty<Path?>(nil)
        target = MutableProperty<Path?>(nil)
        (generatedSignal, generatedSink) = Signal<Int, NoError>.pipe()
        super.init()
        
        assetGeneratorSignal = SignalProducer<Float, NoError> { (sink, disposable) -> () in
            self.running.put(true)
//            sendNext(sink, 100)
            // If sources are not ready. Send back Error.
            let s = self.source.value!
            let t = self.target.value!
            self.assetGenerator.generateAssets(s, target: t)(observer: sink, generatedObserver: self.generatedSink) {
                self.running.put(false)
            }
            
//            return // is this needed?
        }
        
//        running |> start(next: { a in println(a) })
        
    }
    func test_put() {
        let v = running.value
        running.put(v)
    }
    
//    func canPreformAssetGeneration() -> Bool {
//        return delegate != nil ? delegate!.hasValidGeneratorInputs() && !assetGenerator.running : false
//        // return (can <^> delegate) ?? false. Which is more readable? // TODO:
//    }
//    
    func executeScript(options: [AssetGenerationOptions]?) {
        if let ops = options {
            let generate1x = contains(ops, .GenerateMissingAssets)
            let createDest = contains(ops, .CreateDesitnationIfMissing)
            preformAssetGeneration(generate1x: generate1x, extraArgs: nil)
        } else {
//            preformAssetGeneration()
        }
    }
    
    func prepare(path: Path) -> Path {
        if !path.hasSuffix("/") {
            return path + "/"
        }
        return path
    }
    
    private func preformAssetGeneration(sink: SinkOf<Event<Float, NoError>>) {
        let source = prepare("/Users/Bader/Asset Generator Misc./Pew Pew Pew/")
        let target = prepare("/Users/Bader/Developer/Randomer/Randomer/Images2.xcassets")
        let s = self.source.value!
        let t = self.target.value!
//        assetGenerator.generateAssets(s, target: t)(observer: sink)
    }
    
    private func preformAssetGeneration(#generate1x: Bool, extraArgs args: [String]?) {
//        let source = prepare(delegate!.source!)
//        let target = prepare(delegate!.target!)
        assetGeneratorSignal |> observeOn(QueueScheduler.mainQueueScheduler) |> start(completed: { () -> () in
            println("COMPLETED")
//            self._running.put(false)
            }, next: { r in
                println("NEXT: \(r)")
        })
//        assetGenerator.generateAssets(source, target: target)
    }
}
