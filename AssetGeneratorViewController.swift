//
//  AssetGeneratorViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/12/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

import Cocoa

class AssetGeneratorViewController: NSViewController, FileDropControllerDelegate {

    @IBOutlet var fileDropController: FileDropViewController! // Force unwrap since it doesnt make sense it this doesnt exist.
    @IBOutlet var browseButton: NSButton!
    @IBOutlet var generateButton: NSButton!
    @IBOutlet var recentlyUsedProjectsDropdownList: NSPopUpButton!
    
    var toolbar: NSToolbar?
    var destination: String?
    
    let recentListManager: RecentlySelectedProjectManager
//    var panel: NSOpenPanel
    
    required init(coder: NSCoder!) {
//        panel = NSOpenPanel()
        recentListManager = RecentlySelectedProjectManager()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.recentlyUsedProjectsDropdownList.addItemsWithTitles(self.recentListManager.recentProjectsList())
//        self.updateGenerateButton()
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
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.updateGenerateButton()
    }

    // MARK:- Convenience Functions.
    func updateGenerateButton() -> Void {
        self.generateButton.enabled = self.fileDropController.hasValidPath() && self.recentListManager.isSelectedProjectValid()
    }
    
    func updateRecentUsedProjectsDropdownView() {
        self.recentlyUsedProjectsDropdownList.removeAllItems()
        self.recentlyUsedProjectsDropdownList.addItemsWithTitles(self.recentListManager.recentProjectsList())
        self.recentlyUsedProjectsDropdownList.selectItemAtIndex(0)
    }
    
    func updateRecentProjectsList(project path: String){
        self.recentListManager.addProject(path)
        self.updateRecentUsedProjectsDropdownView()
    }
    
    // MARK: - IBActions
    @IBAction func generateButtonPressed(sender: AnyObject!) {

        var scriptManager: ScriptManager = ScriptManager()
        
        scriptManager.executeScript(source: self.fileDropController.sourcePath()!,
            destination: self.recentListManager.selectedProject()!,
            generate1x: false,
            extraArgs: nil)
    }

    
    @IBAction func browseButtonPressed(sender: AnyObject!) {
        
        var panel: NSOpenPanel = NSOpenPanel()
        
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["xcassets"]
        
        panel.beginWithCompletionHandler() { (handler: Int) -> Void in
            if handler == NSFileHandlingPanelOKButton {
                let path = panel.URL.path
                NSLog("the URL: \(path)")
                self.destination = panel.URL.path
//                self.recentListManager.addProject(panel.URL.path!)
//                self.updateRecentUsedProjectsDropdownView()
                self.updateRecentProjectsList(project: path!)
                
                self.updateGenerateButton()
            }
        }
        
    }
    
    
    @IBAction func recentlyUsedProjectsDropdownListChanged(sender: NSPopUpButton!) {
//        self.recentListManager.addProject(sender.title)
//        self.updateRecentUsedProjectsDropdownView()
        self.updateRecentProjectsList(project: sender.title)
    }
    
    
    // Is this better?
    // MARK: - Segues functions
    override func prepareForSegue(segue: NSStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "embeddedContainer" {
            self.fileDropController = segue.destinationController as FileDropViewController
            self.fileDropController.delegate = self
        }
    }
    
    
    // MARK: - FileDropController Delegate
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController) {
        self.updateGenerateButton()
        
    }
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController) {
        self.updateGenerateButton()
    }

}
