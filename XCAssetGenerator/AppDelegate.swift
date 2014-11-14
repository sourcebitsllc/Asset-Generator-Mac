//
//  AppDelegate.swift
//  XCAssetGenerator
//
//  Created by Pranav Shah on 7/30/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        PathValidator.directoryContainsInvalidCharacters(path: "/Users/Bader/Downloads/test a/", options: nil)
        var string1 = "a"
        var string2 = "b"
        var data1 = NSKeyedArchiver.archivedDataWithRootObject(string1)
        var data2 = NSKeyedArchiver.archivedDataWithRootObject(string2)
        var a1 = [data1, data2]
        
        var dataa1 = NSKeyedArchiver.archivedDataWithRootObject(a1)
        
        var a11: AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(dataa1)!
        
        var string11: String = NSKeyedUnarchiver.unarchiveObjectWithData(a11[1]! as NSData) as String
        let a: [Int] = [Int]()
        let b = a.map({(Void) -> String in
            return "a"
        })
        
        println(b)
        println("the string = \(string11)")
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

