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
    private var line: NSView!
    let viewModel: ProgressIndicationViewModel
    
    
    init?(viewModel: ProgressIndicationViewModel, width: CGFloat) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        let lineWidth = viewModel.lineWidth
//        view.translatesAutoresizingMaskIntoConstraints = false
//        line.translatesAutoresizingMaskIntoConstraints = false
        view = NSView(frame: NSRect(x: 0, y: 0, width: width, height: CGFloat(lineWidth)))
        line = NSView(frame: NSRect(x: 0, y: 0, width:0, height: CGFloat(lineWidth)))
        line.wantsLayer = true
        line.layer?.masksToBounds = true
        
        view.layer?.backgroundColor = NSColor.redColor().CGColor
        view.addSubview(line)
        
        /// RAC3
        viewModel.progress
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> observe(next: { progress in
                self.viewModel.animating.put(true)
                switch progress {
                case .Ongoing(let amount):
                    let width = self.line.superview!.bounds.size.width * (CGFloat(amount) / 100)
                    self.line.animator().frame.size.width = width
                case .Finished:
                    self.resetUI()
                case .Started:
                    self.line.animator().frame.size.width = 0
                }
                
        })
        
        viewModel.color.producer
            |> observeOn(QueueScheduler.mainQueueScheduler)
            |> start(next: { color in
                println("ProgressVieWcontroller.color")
                self.line.layer!.backgroundColor = color.CGColor
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented and will not be.")
    }

    
    func resetProgress(completion: () -> Void) {
        let width = line.superview!.bounds.size.width
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
            self.line.animator().frame.size.width = width
            }, completionHandler: { () -> Void in
                
                NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
                    self.line.animator().alphaValue = 0
                    }, completionHandler: { () -> Void in
                        self.line.frame.size.width = 0
                        self.line.alphaValue = 1
                        completion()
                })
        })
        
    }
    
    func resetUI() {
        let width = line.superview!.bounds.size.width
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
            self.line.animator().frame.size.width = width
            }, completionHandler: { () -> Void in
                
                NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
                    self.line.animator().alphaValue = 0
                    }, completionHandler: { () -> Void in
                        self.line.frame.size.width = 0
                        self.line.alphaValue = 1
                        println("RESETUI PROGRESS DONE")
                        self.viewModel.animating.put(false)
                })
        })
        
    }
}