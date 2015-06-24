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
    
    func replace(characters: [Character], withCharacter character: Character) -> String {
        return String(map(self) {
            if find(characters, $0) == nil {
                return $0
            } else {
                return character
            }
        })
    }
    
    func contains(substring: String) -> Bool {
        return self.rangeOfString(substring) != nil
    }
    
    func removeAssetSetsComponent() -> String {
        let notAssetSet = { (set: Path) in return !set.isAssetSet() }
//        return self.pathComponents.filter (notAssetSet) |> String.pathWithComponents
//        return String.pathWithComponents(self.pathComponents.filter(notAssetSet))
        return (self.pathComponents, notAssetSet) |> filter |> String.pathWithComponents // Again, Which is more readable and more maintianable?
    }
    
    func removeTrailingSlash() -> String {
        var v = self
        if v.hasSuffix("/") {
            v.removeAtIndex(v.endIndex.predecessor())
        }
        return v
    }
}
