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
        
        
        // Insert code here to initialize your application
//        let az = PathValidator.directoryContainsImages(path: "/Users/Bader/Downloads/Testz")
//        println("contains: \(az)")
//        
//        println(PathValidator.directoryContainsInvalidCharacters(path: "/Users/Bader/Downloads/Testz", options: nil))
//   
//        let d = PathValidator.directoryContainsInvalidCharacters(path: "/Users/Bader/Downloads/Testz", options: nil)
//        println("d: \(d)")
//        
//        let image = Asset.create("/Users/Bader/Generator Misc./test a/untitled folder/Icons/AppIcon@2x.png")
//        println(image.attributes)
//
//        var i = Asset.create("/Useer/Asset Generator Misc./test a/untitled folder/Icons/AppIcon@2x.png")
//        var p = i.attributes
//        println(p.serialized)
//        var i1 = Asset.create("/Users/r/Asset Generator Misc./Melissa Test Slices/Dialing_GroupAvatar_SM@2x.png")
//        println(p.serialized)
//        let p: AnyObject? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
////        println(p)
//        let (s1, o1) = Signal<Bool, NoError>.pipe()
//        let (s2, o2) = Signal<Bool, NoError>.pipe()
//        
////
//        let status = MutableProperty<String>("")
//        status <~ combineLatest(s1, s2)
//                |> map { (a, b) in
//                    println("LOL")
//                    return "Kid" }
//        
//        sendNext(o1, true)
//        sendNext(o2, true)
//        println(status.value)
//
//        
//        
//        
//        let a = MutableProperty<Bool>(true)
//        let b = MutableProperty<Bool>(false)
//        
//        let ab = MutableProperty<String>("")
//        ab <~ combineLatest(a.producer, b.producer)
//            |> map { a, b in
//                println("LAL a: \(a), b: \(b)")
//                return "Hello"
//        }
//        let statuz = MutableProperty<String>("")
//        statuz <~ zip(a.producer, b.producer)
//            |> map { (a, b) in
//                println("OLO a:\(a), b:\(b)")
//                return "dik"
//        }
//        
//        let c = MutableProperty<String>("")
//        c <~ a.producer |> map { _ in
//            println("changed")
//            return ""
//        }
//        
//        let (sig, sin) = SignalProducer<Int, NoError>.buffer()
//        
//        sendNext(sin, 1)
//        sendNext(sin, 2)
//        
//        sendCompleted(sin)
//        sendNext(sin, 3)
//        sig |> start()
//        sendNext(sin, 4)
//        a.put(false)

//        let fildes = open("/Users/Bader/Downloads/AssetGeneratorWindowController.swift", O_EVTONLY)
//        
//        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//        let source = dispatch_source_create(
//            DISPATCH_SOURCE_TYPE_VNODE,
//            UInt(fildes),
//            DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE,
//            queue)
//
//        dispatch_source_set_event_handler(source, {
//            println("SOMETHING")
//            //Reload the config file
//    })
//        
//        dispatch_source_set_cancel_handler(source,
//            {
//                //Handle the cancel
//        })
//        
//        dispatch_resume(source);
        
//       let (signal, sink) = Signal<Void, NoError>.pipe()
//        
//        signal.observe(next: {
//            println("YEP")
//        })
//        
//        sendNext(sink, Void())
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

