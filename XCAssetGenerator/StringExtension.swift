//
//  StringExtension.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/8/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

extension String {
    func remove(strings: [String]) -> String {
        var v = self
        for s in strings {
            v = v.stringByReplacingOccurrencesOfString(s, withString: "")
        }
        return v
    }
    // TODO: Swift 2.0
    func replace(characters: [Character], withCharacter character: Character) -> String {
        return String(map(self) { find(characters, $0) == nil ? $0 : character })
    }
    
    func contains(substring: String) -> Bool {
        return self.rangeOfString(substring) != nil
    }
    
    func removeAssetSetsComponent() -> String {
        return self.pathComponents.filter { !$0.isAssetSet() }
            |> String.pathWithComponents
    }
    
    func removeTrailingSlash() -> String {
        var v = self
        if v.hasSuffix("/") {
            v.removeAtIndex(v.endIndex.predecessor())
        }
        return v
    }
}
