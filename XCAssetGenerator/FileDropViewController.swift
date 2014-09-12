//
//  FileDropViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/11/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

class FileDropViewController: NSViewController, DropViewDelegate {

    @IBOutlet var dropView: DropView!
    private var folderPath : String?
    
    required init(coder: NSCoder!) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropView.delegate = self
    }
    
    override func loadView() {
        super.loadView()
    }
    
    func sourcePath(Void) -> String? {
        let sourcePath = self.folderPath
        return sourcePath
    }
    
    // MARK: - DropViewDelegate required functions.
    func dropViewDidDropFileToView(dropView: DropView, filePath: String) {
        NSLog("File dropped with path %@", filePath);
        self.folderPath = filePath
    }
    
    func dropViewDidDragFileIntoView(dropView: DropView) {
        dropView.layer!.backgroundColor = NSColor.init(red: 144/255, green: 230/255, blue: 33/255, alpha:1).CGColor
    }
    
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        NSLog("File dragged out of view");
        dropView.layer!.backgroundColor = NSColor.clearColor().CGColor
    }
    
}
