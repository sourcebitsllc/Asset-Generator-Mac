//
//  ScriptExecutor.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/12/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

import Foundation

protocol ScriptProgessDelegate {
    var percentageProgress: Int { get set }
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

class ScriptExecutor: NSObject {
    //let path: String
    private let scriptPath: String
    var task: NSTask
    
    var progressDelegate: ScriptProgessDelegate?
    var sourceDelegate: ScriptSourcePathDelegate?
    var destinationDelegate: ScriptDestinationPathDelegate?
    
    required override init() {
        self.scriptPath = NSBundle.mainBundle().pathForResource("XCasset Generator", ofType: "sh")!
        self.task = NSTask()
        super.init()
    }
    
    convenience init(delegate aDelegate: ScriptProgessDelegate?) {
        self.init()
        self.progressDelegate = aDelegate
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
    func executeScript(source src: String, destination dst: String, generate1x g1x: Bool, extraArgs args: [String]?) {
        
        task.launchPath = self.scriptPath
        task.arguments = [src, dst]
        
        task.launch()
        task.waitUntilExit()
    }
    
    func executing() -> Bool {
        return task.running
    }
}
