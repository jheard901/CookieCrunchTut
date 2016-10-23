//
//  Swap.swift
//  CookieCrunchTut
//
//  Created by User on 10/23/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

struct Swap: CustomStringConvertible, Hashable
{
    let cookieA: Cookie
    let cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie)
    {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String
    {
        return "swap \(cookieA) with \(cookieB)"
    }
    
    //combines the hash values of the two cookies with the "exclusive-or" operator
    var hashValue: Int
    {
        return cookieA.hashValue ^ cookieB.hashValue
    }
}


extension Swap: Equatable
{
    static func ==(lhs: Swap, rhs:Swap) -> Bool
    {
        return (lhs.cookieA == rhs.cookieA && lhs.cookieB == rhs.cookieB) ||
               (lhs.cookieB == rhs.cookieA && lhs.cookieA == rhs.cookieB)
    }
}



