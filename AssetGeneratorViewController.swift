//
//  AssetGeneratorViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/12/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

class AssetGeneratorViewController: NSViewController, NSToolbarDelegate {

    @IBOutlet var fileDropController: FileDropViewController! // Force unwrap since it doesnt make sense it this doesnt exist.
    var toolbar: NSToolbar?
    @IBOutlet var browseButton: NSButton!
    
    required init(coder: NSCoder!) {
//        toolbar = NSToolbar(identifier: "MyToolbar")
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
// TODO: Find better way to connect containerController to local var. sigh.
//        self.fileDropController = self.childViewControllers.first! as FileDropViewController //
//        NSLog("\(self.fileDropController.description)")
        
//        toolbar.allowsUserCustomization = false
//        toolbar.displayMode = NSToolbarDisplayMode.IconOnly
//        toolbar.sizeMode = NSToolbarSizeMode.Regular
        
        // HACKAGE GALORE. DAFAQ IS THIS.
//        self.toolbar = NSApplication.sharedApplication().windows[0].toolbar as NSToolbar
//        self.toolbar!.delegate = self
//        NSLog("\(self.toolbar!.items)")
       // window.toolbar = toolbar
    }
    
    @IBAction func browseButtonPressed(sender: AnyObject!) {
        NSLog("Browse Button pressed")
        
        var panel: NSOpenPanel = NSOpenPanel()
        
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["xcassets"]
        
        panel.beginWithCompletionHandler() { (handler: Int) -> Void in
            if handler == NSFileHandlingPanelOKButton {
                let path = panel.URL.path
                NSLog("the URL: \(path)")
            }
        }
        
    }
    // Is this better?
    override func prepareForSegue(segue: NSStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "embeddedContainer" {
            self.fileDropController = segue.destinationController as FileDropViewController;
        }
    }

}
