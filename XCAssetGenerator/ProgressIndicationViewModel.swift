//
//  ProgressIndicationViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import ReactiveCocoa

enum Progress {
    case Started
    case Ongoing(Float)
    case Finished
}

struct ProgressIndicationViewModel {
//    let progress: MutableProperty<Float> // Maybe the progress should be its own signal producer. each time it sends the progress then completed.
    let animating: MutableProperty<Bool>
    
    let progress: Signal<Progress, NoError> // faux Hot signal. "Warm". How do i make model one signal in terms of other operations, even when it does not incur sideeffects by itself.
    private let sink: SinkOf<Event<Progress, NoError>>
    
    let lineWidth: CGFloat = 3
    let color: MutableProperty<NSColor>
    
    init() {
//        self.progress =  MutableProperty<Float>(0)
        self.animating = MutableProperty<Bool>(false)
        self.color = MutableProperty<NSColor>(NSColor(calibratedRed: 0.047, green: 0.261, blue: 0.993, alpha: 1))
        (self.progress, self.sink) = Signal<Progress, NoError>.pipe()
//        animating <~ progress |> map { self.isAnimating($0) }
    }
    
    func updateProgress(amount: Float) {
//        progress.put(amount)
        sendNext(sink, .Ongoing(amount))
    }
    
    func progressFinished() {
        sendNext(sink, .Finished)
    }
        
    private func isAnimating(progress: Progress) -> Bool {
        switch progress {
        case .Finished:
            return false
        case _:
            return true
        }
    }
        
}

//func assetGenerationFinished(generated: Int) {
//    
//    progressController.resetProgress {
//        self.updateGenerateButton()
//        //            self.updateState()
//        //            self.fileDropController.displayDoneState(generated)
//        self.generateButton.title = "Build Again"
//        self.generateButton.sizeToFit()
//        let s = self.pluralize(generated, singular: "asset was", plural: "assets were")
//        let catalog = self.target!.lastPathComponent
//        self.statusLabel.stringValue = "\(s) added to \(catalog)"
//    }
//}
//
//private func pluralize(amount: Int, singular: String, plural: String) -> String {
//    switch amount {
//    case 1:
//        return "1 \(singular)"
//    case let a:
//        return "\(a) \(plural)"
//    }
//}

/*

class progressBarViewModel  {
    // VC will bind to this.
    var progress 	// Will send COMPLETED which is when we can execute our reset logic and maybe call completion closure or however we solve this.
    var isAnimating
    var color
    var lineWidth // MAYBE NOT NEEDED
}
*/