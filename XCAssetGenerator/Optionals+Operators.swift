//
//  Optionals.swift
//  XCAssetGenerator
//
//  Created by Bader on 4/29/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Foundation

infix operator <^> { associativity left }
infix operator <*> { associativity left }
infix operator >>- { associativity left precedence 150 }
infix operator |> { associativity left precedence 95 }
infix operator <| { associativity left precedence 95 }

public func <^><T, U>(f: T -> U, x: T?) -> U? {
    return x.map(f)
}

public func <*><T,U>(f: (T -> U)?, x: T?) -> U? {
    if let f = f {
        return x.map(f)
    } else {
        return .None
    }
}

public func >>-<T, U>(x: T?, f: T -> U?) -> U? {
    return x.flatMap(f)
}

public func |> <T, U> (left: T, @noescape right: T -> U) -> U {
    return right(left)
}

public func <| <T, U> (@noescape left: T -> U, right: T) -> U {
    return left(right)
}
