//
//  StringExtension.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/8/15.
//  Copyright (c) 2015 Pranav Shah. All rights reserved.
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
}
