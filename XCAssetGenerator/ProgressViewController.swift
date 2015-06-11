//
//  ProgressController.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/18/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation
import Cocoa
import ReactiveCocoa

class ProgressViewController: NSViewController {
    var progressView: ProgressLineView
    let viewModel: ProgressIndicationViewModel
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(viewModel: ProgressIndicationViewModel, width: CGFloat) {
        self.viewModel = viewModel
        progressView = ProgressLineView(width: width)
        let lineWidth = viewModel.lineWidth // TODO: right now this is ignored.
        super.init(nibName: nil, bundle: nil)
        
        view = progressView
        
        /// RAC3
        viewModel.progress
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> observe(next: { progress in
                self.viewModel.animating.put(true)
                switch progress {
                case .Ongoing(let amount):
                    self.progressView.animateTo(progress: amount)
                case .Finished:
                    self.resetUI()
                case .Started:
                    self.progressView.initiateProgress()
                }
                
        })
        
        viewModel.color.producer
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> start(next: { color in
                self.progressView.color = color
        })
    }

    
    func resetProgress(completion: () -> Void) {
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
            self.progressView.forceAnimateFullProgress()
            }, completionHandler: { () -> Void in
                
                NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
                    self.progressView.animateFadeOut()
                    }, completionHandler: { () -> Void in
                        self.progressView.resetProgress()
                        completion()
                })
        })
        
    }
    
    func resetUI() {
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
            self.progressView.forceAnimateFullProgress()
            }, completionHandler: { () -> Void in
                
                NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
                    self.progressView.animateFadeOut()
                    }, completionHandler: { () -> Void in
                        self.progressView.resetProgress()
                        self.viewModel.animating.put(false)
                })
        })
    }
}