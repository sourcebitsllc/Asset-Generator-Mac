//
//  ProgressIndicationViewModel.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/26/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import ReactiveCocoa

enum Progress {
    case Started
    case Ongoing(Float)
    case Finished
}

class ProgressIndicationViewModel {
    let animating: MutableProperty<Bool>
    
    let progress: Signal<Progress, NoError> // faux Hot signal. "Warm". How do i make model one signal in terms of other operations, even when it does not incur sideeffects by itself.
    private let sink: SinkOf<Event<Progress, NoError>>
    
    let lineWidth: CGFloat = 3
    let color: MutableProperty<NSColor>
    
    init() {
        self.animating = MutableProperty<Bool>(false)
        self.color = MutableProperty<NSColor>(NSColor(calibratedRed: 0.047, green: 0.261, blue: 0.993, alpha: 1))
        (self.progress, self.sink) = Signal<Progress, NoError>.pipe()
    }
    
    func updateProgress(amount: Float) {
        sendNext(sink, .Ongoing(amount))
    }
    
    func progressFinished() {
        sendNext(sink, .Finished)
    }
    
    func progressStarted() {
        sendNext(sink, .Started)
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