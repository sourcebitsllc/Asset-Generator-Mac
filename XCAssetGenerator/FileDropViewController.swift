//
//  FileDropViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/11/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

import Cocoa

protocol FileDropControllerDelegate {
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController)
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController)
    
    // shoudl it be did change sourcepath? and have an enum with Add-Remove-Update
}

class FileDropViewController: NSViewController, DropViewDelegate {

    @IBOutlet var dropView: DropView!
    var delegate: FileDropControllerDelegate?
    
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
    func hasValidPath() -> Bool {
        // TODO: Path validation logic can go here
        return (self.folderPath? != nil) ? true : false
    }
    func sourcePath() -> String? {
        let sourcePath = self.folderPath
        return sourcePath
    }
    
    // MARK: - DropViewDelegate required functions.
    func dropViewDidDropFileToView(dropView: DropView, filePath: String) {
        self.folderPath = filePath
        delegate?.fileDropControllerDidSetSourcePath(self)
    }
    
    func dropViewDidDragFileIntoView(dropView: DropView) {
        dropView.layer!.backgroundColor = NSColor.init(red: 144/255, green: 230/255, blue: 33/255, alpha:1).CGColor
    }
    
    func dropViewDidDragFileOutOfView(dropView: DropView) {
        NSLog("File dragged out of view");
        dropView.layer!.backgroundColor = NSColor.clearColor().CGColor
    }
    
}
