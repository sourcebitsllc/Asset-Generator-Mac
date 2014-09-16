//
//  ScriptExecutor.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/12/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

import Foundation

protocol ScriptProgessDelegate {
//    @objc optional var percentageProgress: Int { get set }
    func scriptFinishedExecutingScript(executor: ScriptExecutor)
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

// TODO: make the script safer to use.

class ScriptExecutor: NSObject {
    private let scriptPath: String
    var task: NSTask
    var pipe: NSPipe
    var running: Bool = false
    
    var progressDelegate: ScriptProgessDelegate?
    var sourceDelegate: ScriptSourcePathDelegate?
    var destinationDelegate: ScriptDestinationPathDelegate?
    
    required override init() {
        self.scriptPath = NSBundle.mainBundle().pathForResource("XCasset Generator", ofType: "sh")!
        self.task = NSTask()
        self.pipe = NSPipe()
        super.init()
    }
    
    convenience init(progressDelegate: ScriptProgessDelegate?) {
        self.init()
        self.progressDelegate = progressDelegate
    }
    
    func canExecuteScript() -> Bool {
        // verbose much?
        switch (self.sourceDelegate, self.destinationDelegate) {
            case (.Some(let source), .Some(let destination)):
                return source.hasValidSourceProject() && destination.hasValidDestinationProject() && !self.executing()
            case (_,_):
                return false
        }
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
            
            self.task.launchPath = self.scriptPath
            self.task.standardOutput = self.pipe
            
            self.pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: self.pipe.fileHandleForReading, queue: nil) { (notification: NSNotification!) -> Void in
                println("Reading")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                   println("\(NSString(data: self.pipe.fileHandleForReading.availableData, encoding: NSUTF8StringEncoding))")
                })
                
                self.pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            }
            self.task.arguments = [src, dst]
            self.task.launch()
            self.task.waitUntilExit()
            
            self.running = false
            self.progressDelegate?.scriptFinishedExecutingScript(self)
        })
    }
    
    func executing() -> Bool {
        return task.running || self.running
    }
}
