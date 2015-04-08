//
//  AppDelegate.swift
//  XCAssetGenerator
//
//  Created by Pranav Shah on 7/30/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa
//let source = "/Users/Bader/Asset Generator Misc./Melissa Test Slices/"
//let target = "/Users/Bader/Developer/Randomer/Randomer/Images.xcassets/"
//let temp = source + ".XCAssetTemp/"
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        let az = PathValidator.directoryContainsImages(path: "/Users/Bader/Downloads/Testz")
        println("contains: \(az)")
        
        println(PathValidator.directoryContainsInvalidCharacters(path: "/Users/Bader/Downloads/Testz", options: nil))
   
        let d = PathValidator.directoryContainsInvalidCharacters(path: "/Users/Bader/Downloads/Testz", options: nil)
        println("d: \(d)")
        
        let image = Asset.create("/Users/Bader/Asset Generator Misc./test a/untitled folder/Icons/AppIcon@2x.png")
        println(image.attributes)

        var i = Asset.create("/Users/Bader/Asset Generator Misc./test a/untitled folder/Icons/AppIcon@2x.png")
        var p = i.attributes
        println(p.serialized)
        var i1 = Asset.create("/Users/Bader/Asset Generator Misc./Melissa Test Slices/Dialing_GroupAvatar_SM@2x.png")
        println(p.serialized)
    }
    
    
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication!) -> Bool {
        return true;
    }
    
    func applicationShouldTerminate(sender: NSApplication!) -> NSApplicationTerminateReply {
        return NSApplicationTerminateReply.TerminateNow
    }
    
}

