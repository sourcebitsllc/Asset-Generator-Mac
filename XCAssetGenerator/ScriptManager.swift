//
//  ScriptManager.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/12/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

import Foundation

protocol ScriptProgessDelegate {
    var percentageProgress: Int { get set }
}

class ScriptManager: NSObject {
    //let path: String
    let scriptPath: String
    var delegate: ScriptProgessDelegate?
    
    required override init() {
        self.scriptPath = NSBundle.mainBundle().pathForResource("XCasset Generator", ofType: "sh")!
        super.init()
    }
    
    convenience init(delegate aDelegate: ScriptProgessDelegate?) {
        self.init()
        self.delegate = aDelegate
    }
    
    // TODO: maybe we should return error in here?
    func executeScript(source src: String, destination dst: String, generate1x g1x: Bool, extraArgs args: [AnyObject?]?) {
        
//        let path: String? = NSBundle.mainBundle().pathForResource("XCasset Generator", ofType: "sh")
//        if let url = path {
//            println(url)
//        }
        
        var task: NSTask = NSTask()
        
        task.launchPath = self.scriptPath
        task.arguments = [src, dst]
        
        task.launch()
        
        task.waitUntilExit()
    }
}
