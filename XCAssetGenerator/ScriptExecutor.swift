//
//  ScriptExecutor.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/12/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Foundation

protocol ScriptProgessDelegate {
    func scriptDidStartExecutingScipt(executor: ScriptExecutor)
    func scriptFinishedExecutingScript(executor: ScriptExecutor)
    func scriptExecutingScript(progress: Int?)
    
}

// TODO: hmm to functionally-identical protocols.... You know what to do.
protocol ScriptSourcePathDelegate {
    func sourcePath() -> String?
    func hasValidSourceProject() -> Bool
}

protocol ScriptDestinationPathDelegate {
    func destinationPath() -> String?
    func hasValidDestinationProject() -> Bool
}

enum ScriptDestinationValidator {
    
}

// TODO: make the script safer to use.

class ScriptExecutor: NSObject {
    var running: Bool = false
    
    var progressDelegate: ScriptProgessDelegate?
    var sourceDelegate: ScriptSourcePathDelegate?
    var destinationDelegate: ScriptDestinationPathDelegate?
    
    private let scriptPath: String
    
    required override init() {
        self.scriptPath = NSBundle.mainBundle().pathForResource("XCasset Generator", ofType: "sh")!
        super.init()
    }
    
    convenience init(progressDelegate: ScriptProgessDelegate?) {
        self.init()
        self.progressDelegate = progressDelegate
    }
    
    func canExecuteScript() -> Bool {
        switch (self.sourceDelegate, self.destinationDelegate) {
            case (.Some(let source), .Some(let destination)):
                return source.hasValidSourceProject() && destination.hasValidDestinationProject() && !self.executing()
            case (_,_):
                return false
        }
    }
    
    func executing() -> Bool {
        return self.running
    }
    
    func executeScript() {
        self.executeScript(source: self.sourceDelegate!.sourcePath()!, destination: self.destinationDelegate!.destinationPath()!, generate1x: false, extraArgs: nil)
    }
    
    func executeScript(#generate1x: Bool, extraArgs args: [String]?) {
        self.executeScript(source: self.sourceDelegate!.sourcePath()!, destination: self.destinationDelegate!.destinationPath()!, generate1x: generate1x, extraArgs: args)
    }
    
    // TODO: maybe we should return error in here? + This should probably be private.
    func executeScript(source src: String, destination dst: String, generate1x: Bool, extraArgs args: [String]?) {
        self.running = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            
            var task = NSTask()
            var pipe = NSPipe()
            task.launchPath = self.scriptPath
            task.arguments = [src, dst]
            task.standardOutput = pipe
            
            pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: pipe.fileHandleForReading, queue: nil) { (notification: NSNotification!) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var echo = NSString(data: pipe.fileHandleForReading.availableData, encoding: NSUTF8StringEncoding)

                    if echo.containsString("progress:") {
                        var progress = echo.stringByReplacingOccurrencesOfString("progress:", withString: "")
                        
                        // If we yanked more than progress line, remove the rest.
                        var rangeOfEndline = progress.rangeOfString("\n", options: NSStringCompareOptions.CaseInsensitiveSearch, range:nil, locale: nil)
                        
                        if let range = rangeOfEndline {
                            progress = progress.substringToIndex(range.startIndex)
                        }
                        self.progressDelegate?.scriptExecutingScript(progress.toInt()!) // FIXME: unsafe.
                    }
                })
                
                pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.running = true
                self.progressDelegate?.scriptDidStartExecutingScipt(self)
            })
            task.launch()
            task.waitUntilExit() // This blocks.
            
            // Notify delegate in main thread.
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.running = false
                self.progressDelegate?.scriptFinishedExecutingScript(self)
            })
        })
    }
}
