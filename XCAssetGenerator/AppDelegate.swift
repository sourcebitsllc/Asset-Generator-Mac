//
//  AppDelegate.swift
//  XCAssetGenerator
//
//  Created by Bader on 7/30/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa
import ReactiveCocoa
//let source = "/Users/Bader/Asset Generator Misc./Melissa Test Slices/"
//let target = "/Users/Bader/Developer/Randomer/Randomer/Images.xcassets/"
//let temp = source + ".XCAssetTemp/"
class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController: NSWindowController!
    var queue: dispatch_queue_t!
    var fildes: CInt!
    var source: dispatch_queue_t!
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let viewModel = AssetWindowViewModel()
        windowController = AssetGeneratorWindowController.instantiate(viewModel)
        
        windowController.window?.setFrame(NSRect(x: 0, y: 0, width: 450, height: 300), display: true)
        windowController.window?.center()
        windowController.showWindow(nil)
        windowController.window?.makeKeyAndOrderFront(nil)
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true;
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        return NSApplicationTerminateReply.TerminateNow
    }
    
}

