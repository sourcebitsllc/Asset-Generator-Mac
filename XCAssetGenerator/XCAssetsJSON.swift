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
        let info = ["version": "1", "author": "xcode"]
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

    static func readJSON(path: Path) -> JSONDictionary {
        var error: NSError?
        let d = NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
        let data = NSData(contentsOfFile: path)!
        let json: JSONDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)! as! JSONDictionary
        return json
    }
}

