//
//  ViewController.swift
//  XCAssetGenerator
//
//  Created by Pranav Shah on 7/30/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, FileViewDelegate {
                            
    @IBOutlet weak var sourceView: FileView!
    @IBOutlet weak var destinationView: FileView!
    @IBOutlet weak var sourcePath: NSTextField!
    @IBOutlet weak var destinationPath: NSTextField!
    
    var selectedSourcePath = ""
    var selectedDestinationPath = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sourceView.layer.backgroundColor = NSColor.redColor().CGColor
        sourceView.layer.cornerRadius = sourceView.frame.size.width/2
        destinationView.layer.backgroundColor = NSColor.redColor().CGColor
        destinationView.layer.cornerRadius = sourceView.frame.size.width/2
        
        sourceView.delegate = self
        destinationView.delegate = self
        // Do any additional setup after loading the view.
//        runShell()
        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
                                    
    }
    
    func runShell() {
        let task = NSTask()
        task.launchPath = "/bin/sh"
        
        task.arguments = ["first-", "second-argument"]
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        print(output)
    }

    func fileDraggedToView(fileView: FileView, path : String) {
        if fileView.isEqual(sourceView) {
            selectedSourcePath = path
        } else if fileView.isEqual(destinationView) {
            selectedDestinationPath = path
        }
        
        validatePaths()
    }
    
    func validatePaths() {
        sourcePath.stringValue = selectedSourcePath
        destinationPath.stringValue = selectedDestinationPath
    }

}

