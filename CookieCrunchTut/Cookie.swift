//
//  Cookie.swift
//  CookieCrunchTut
//
//  Created by User on 10/5/16.
//  Copyright © 2016 User. All rights reserved.
//

import SpriteKit

enum CookieType: Int, CustomStringConvertible
{
    case Unknown = 0, Croissant, Cupcake, Danish, Donut, Macaroon, SugarCookie
    
    var spriteName: String
    {
        let spriteNames = [
            "Croissant",
            "Cupcake",
            "Danish",
            "Donut",
            "Macaroon",
            "SugarCookie"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String
    {
        return spriteName + "-Highlighted"
    }
    
    var description: String
    {
        return spriteName
    }
    
    
    static func random() -> CookieType
    {
        return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
}


class Cookie: CustomStringConvertible, Hashable
{
    //custom string convertible protocol allows print() to print out specific information defined for this class in the var "description"
    var description: String
    {
        return "type: \(cookieType) square:(\(column),\(row))"
    }
    
    //the Hashable protocol should return an Int that is unique for each object in var "hashValue"
    var hashValue: Int
    {
        return (row * 10) + column
    }
    
    var column: Int
    var row: Int
    let cookieType: CookieType
    var sprite: SKSpriteNode?   //the sprite property is optional, thus the ? since the cookie object may not always have its sprite set
    
    init(column: Int, row: Int, cookieType:CookieType)
    {
        self.column = column
        self.row = row
        self.cookieType = cookieType
    }
    
}

//with Equatable, we expand functionality of Hashable protocol and overload the '==' operator to compare any two instances of a Cookie to see if they are equal
extension Cookie: Equatable
{
    //returns true if lhs (left hand side) and rhs are equal
    static func == (lhs: Cookie, rhs: Cookie) -> Bool
    {
        return lhs.column == rhs.column && lhs.row == rhs.row && lhs.cookieType == rhs.cookieType
    }
}

