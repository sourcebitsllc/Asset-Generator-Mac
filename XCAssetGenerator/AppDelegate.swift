//
//  AppDelegate.swift
//  XCAssetGenerator
//
//  Created by Bader on 7/30/14.
//  Copyright (c) 2014 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController: NSWindowController!

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

