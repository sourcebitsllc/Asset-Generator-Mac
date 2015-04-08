//
//  JSON.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/3/15.
//  Copyright (c) 2015 Pranav Shah. All rights reserved.
//

import Foundation


typealias JSONDictionary = NSDictionary

struct JSON {
    
    static func writeJSON(json: JSONDictionary, toFile file: Path) {
        let outputStream = NSOutputStream(toFileAtPath: file, append: false)
        outputStream?.open()
        NSJSONSerialization.writeJSONObject(json, toStream: outputStream!, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        outputStream?.close()
    }
    
    ///
    /// :param:
    /// :returns:
    static func createJSONDefaultWrapper(images: [SerializedAssetAttribute]) -> JSONDictionary {
        let info = ["version": "1", "author": "xcode"]
        let json = ["images": images, "info": info]
        return json
    }
    
    static func readJSON(path: Path) -> JSONDictionary {
        let data = NSData(contentsOfFile: path)!
        let json: JSONDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)! as JSONDictionary
        return json
    }
}