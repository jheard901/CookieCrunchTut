//
//  Chain.swift
//  CookieCrunchTut
//
//  Created by User on 10/23/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation


//a chain has a list of cookie objects and a type: it's either horizontal (a row of cookies) or vertical (a column). The type is defined as an enum, it is nested insided the Chain class because these two things are tightly coupled. More advanced chains types can be added later on such as L shaped or T shaped chains. An array is used here to store the cookie objects because it's convenient to remeber the order of the cookie objects so you know which cookies are at the ends of the chain
class Chain: Hashable, CustomStringConvertible
{
    var score = 0
    var cookies = [Cookie]()
    
    enum ChainType: CustomStringConvertible
    {
        case horizontal
        case vertical
        
        var description: String
        {
            switch self
            {
            case .horizontal: return "Horizontal"
            case .vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType)
    {
        self.chainType = chainType
    }
    
    func add(cookie:Cookie)
    {
        cookies.append(cookie)
    }
    
    func firstCookie() -> Cookie
    {
        return cookies[0]
    }
    
    func lastCookie() -> Cookie
    {
        return cookies[cookies.count - 1]
    }
    
    var length: Int
    {
        return cookies.count
    }
    
    var description: String
    {
        return "type: \(chainType) cookies: \(cookies)"
    }
    
    //hashValue simply perfrms an exclusive-or on the hash values of all the cookies in the chain; the reduce() function is one of Swift's more advanced features
    var hashValue: Int
    {
        return cookies.reduce(0) { $0.hashValue ^ $1.hashValue }
    }
    
}


extension Chain: Equatable
{
    static func ==(lhs: Chain, rhs: Chain) -> Bool
    {
        return lhs.cookies == rhs.cookies
    }
}




