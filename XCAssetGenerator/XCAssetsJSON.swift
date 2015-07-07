//
//  JSON.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/3/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

// NOPE
// TODO:
typealias JSONDictionary = NSDictionary
typealias MutableJSONDictionary = NSMutableDictionary

struct XCAssetsJSONHelper {
    static func createJSONDefaultWrapper(images: [XCAssetsJSON]) -> JSONDictionary {
        let info = ["version": "1", "author": "Asset Generator"]
        let json: JSONDictionary = ["images": images, "info": info]
        return json
    }
    
    static func updateImagesValue(json: XCAssetsJSONWrapper)(value: [XCAssetsJSON]) -> JSONDictionary {
        var copy = json
        copy["images"] = value
        return copy
    }
    
}

struct JSON {
    
    static func writeJSON(json: JSONDictionary, toFile file: Path) {
        let outputStream = NSOutputStream(toFileAtPath: file, append: false)
        outputStream?.open()
        NSJSONSerialization.writeJSONObject(json, toStream: outputStream!, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        outputStream?.close()
    }
    
    static func writeJSON(to file: Path)(withJSON json: JSONDictionary) {
        let outputStream = NSOutputStream(toFileAtPath: file, append: false)
        outputStream?.open()
        NSJSONSerialization.writeJSONObject(json, toStream: outputStream!, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        outputStream?.close()
    }

    static func readJSON(path: Path) -> JSONDictionary? {
        return NSData(contentsOfFile: path).flatMap { NSJSONSerialization.JSONObjectWithData($0, options: NSJSONReadingOptions.MutableContainers, error: nil) as? JSONDictionary }
    }
}

