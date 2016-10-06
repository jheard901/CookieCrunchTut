//
//  Level.swift
//  CookieCrunchTut
//
//  Created by User on 10/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level
{
    //when this is private the information cannot be directly accessed by other objects
    private var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    
    private func createInitialCookies() -> Set<Cookie>
    {
        //a set is a collection - like an array - but it allows each element to only appear once, and it doesn't store elements in a particular order
        var set = Set<Cookie>()
        
        //this syntax for Swift... what were the developers thinking when designing this language? this for loop declaration is simply silly and there is no reason the syntax couldn't of been designed to follow the same conventions as Java or C++; I sense somebody just wanted to be a rebel and make people suffer to understand this language so it would be uniquely understood only by iOS developers *facepalm*
        for row in 0..<NumColumns
        {
            for column in 0..<NumColumns
            {
                //creates a tile only if the value in the array isn't nil
                if tiles[column, row] != nil
                {
                    let cookieType = CookieType.random()
                    
                    //creates a new Cookie object then adds it to the 2D array
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    
                    set.insert(cookie)
                }
            }
        }
        
        return set
    }
    
    //returns a specific cookie at [column, row]
    //return type is an optional because not all grid squares will necessarily have a cookie (they could be nil)
    func cookieAt(column: Int, row: Int) -> Cookie?
    {
        //checks that input values conform to these conditions | assert helps here because if the app crashes, the backtrace will point exactly to the asserted condition that caused the crash
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cookies[column, row]
    }
    
    func tileAt(column: Int, row: Int) -> Tile?
    {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func shuffle() -> Set<Cookie> {
        return createInitialCookies()
    }
    
    
    init(filename: String)
    {
        //load the named file into a Dictionary | guard handles the case if it returning nil
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else { return }
        //[[Int]] means array-of-array-of-Int
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else { print("Dictionary shows as nil. Check that the level filename is correct.");return }
        for (row, rowArray) in tilesArray.enumerated()
        {
            //in SpriteKit (0,0) is at the bottom of screen, so reverse the order of the rows so that the first row read from the JSON corresponds to the last row of the 2D grid
            let tileRow = NumRows - row - 1
            
            //step through the columns in the current row, each time a '1' is found it creates a Tile object in the "tiles" array
            for (column, value) in rowArray.enumerated()
            {
                if value == 1
                {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
    }
    
    
}



