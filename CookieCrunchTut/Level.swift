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

let NumLevels = 4 //excluding level 0

class Level
{
    var targetScore = 0
    var maximumMoves = 0
    
    private var comboMultiplier = 0
    
    //contains Swap objects | if player tries to swap two cookies not in the set then the game will not accept the swap as a valid move
    private var possibleSwaps = Set<Swap>()
    
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
                    //picks a cookie type at random and repeats selection until it does not create a chain of three or more
                    var cookieType: CookieType
                    repeat
                    {
                        cookieType = CookieType.random()
                    } while (
                        (column >= 2 &&
                            cookies[column - 1, row]?.cookieType == cookieType &&
                            cookies[column - 2, row]?.cookieType == cookieType)
                        || (row >= 2 &&
                            cookies[column, row - 1]?.cookieType == cookieType &&
                            cookies[column, row - 2]?.cookieType == cookieType)
                    )
                    
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
    
    
    func shuffle() -> Set<Cookie>
    {
        //at the start of each turn detect which cookies the player can swap
        var set: Set<Cookie>
        repeat
        {
            set = createInitialCookies()
            detectPossibleSwaps()
            print("Possible swaps: \(possibleSwaps)")
        } while (possibleSwaps.count == 0)
        
        return set
    }
    
    func detectPossibleSwaps()
    {
        var set = Set<Swap>()
        
        //go through each spot on the grid
        for row in 0..<NumRows
        {
            for column in 0..<NumColumns
            {
                if let cookie = cookies[column, row]
                {
                    //begin detection logic
                    
                    //can this cookie be swapped with the one on the right?
                    if (column < NumColumns - 1)
                    {
                        //have a cookie in this spot? If there is no tile, there is no cookie
                        if let other = cookies[column + 1, row]
                        {
                            //swap them
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie
                            
                            //is either cookie not part of a chain?
                            if(hasChainAt(column: column + 1, row: row) || hasChainAt(column: column, row: row))
                            {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            //swap them back
                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                        }
                    }
                    
                    if (row < NumRows - 1)
                    {
                        if let other = cookies[column, row + 1]
                        {
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            
                            //is either cookie not part of a chain?
                            if(hasChainAt(column: column, row: row + 1) || hasChainAt(column: column, row: row))
                            {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            //swap them back
                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }
                    
                }
            }
        }
        
        possibleSwaps = set
    }
    
    //helper method to detectPossibleSwaps()
    private func hasChainAt(column: Int, row: Int) -> Bool
    {
        let cookieType = cookies[column, row]!.cookieType
        
        //horizontal chain check
        var horzLength = 1
        
        //left
        var i = column - 1
        while (i >= 0 && cookies[i, row]?.cookieType == cookieType)
        {
            i -= 1
            horzLength += 1
        }
        
        //right
        i = column + 1
        while (i < NumColumns && cookies[i, row]?.cookieType == cookieType)
        {
            i += 1
            horzLength += 1
        }
        //if there is a match of at least 3 consecutive cookieTypes on the same row comparing both in the left and right directions from the cookie location, then return true for a chain found
        if (horzLength >= 3)
        {
            return true
        }
        
        //vertical chain check
        var vertLength = 1
        
        //down
        i = row - 1
        while (i >= 0 && cookies[column, i]?.cookieType == cookieType)
        {
            i -= 1
            vertLength += 1
        }
        
        //up
        i = row + 1
        while (i < NumRows && cookies[column, i]?.cookieType == cookieType)
        {
            i += 1
            vertLength += 1
        }
        
        //returns true if there is a match of at least 3 consecutive cookieTypes vertically, or false if no matches (horz or vert) were found at all
        return vertLength >= 3
    }
    
    //this method detects where there are empty tiles and shifts any cookies down to fill up those tiles. It starts at the bottom and scans upward. If it finds a sqare that should have a cookie but doesn't, then it finds the nearest cookie above it and moves this cookie to the empty tile
    func fillHoles() -> [[Cookie]]
    {
        var columns = [[Cookie]]()
        
        //loop through rows from bottom to top
        for column in 0..<NumColumns
        {
            var array = [Cookie]()
            
            for row in 0..<NumRows
            {
                //if there is a tile at a position but no cookie, then there is a hole (recall tat the tiles array describes the shape of the level)
                if tiles[column, row] != nil && cookies[column, row] == nil
                {
                    //we can scan upward to find the cookie that sits directly above the hole. Note that the hole may be bigger than one square (eg a vertical chain) and that there may be holes in the grid shape as well
                    for lookup in (row + 1)..<NumRows
                    {
                        if let cookie = cookies[column, lookup]
                        {
                            //if we find another cookie, move that cookie to the hole; this effectively moves the cookie down
                            cookies[column, lookup] = nil
                            cookies[column, row] = cookie
                            cookie.row = row
                            
                            //add the cookie to the array. Each column gets its own array and cookies that are lower on the screen are first in the array. It's important to keep this order intact, so the animation code can apply the correct delay. The farther up the piece is, the bigger the delay before the animation starts
                            array.append(cookie)
                            
                            //once we've found a cookie, we don't need to scan up any farther so break out the inner loop
                            break
                        }
                    }
                }
            }
            
            //if a column does not have any holes, then there is not point in adding it to the final array
            if !(array.isEmpty)
            {
                columns.append(array)
            }
        }
        
        return columns
    }
    
    //adds new cookies to fill the columns to the top (where necessary). Returns an array with the new Cookie objects for each column that had empty tiles. The cookie objects in this array are ordered from top to bottom
    func topUpCookies() -> [[Cookie]]
    {
        var columns = [[Cookie]]()
        var cookieType: CookieType = .Unknown
        
        for column in 0..<NumColumns
        {
            var array = [Cookie]()
            
            //loop through the column from top to bottom. This while loop ends when cookies[column, row] is not nil (ie when it has found a cookie)
            var row = NumRows - 1
            while row >= 0 && cookies[column, row] == nil
            {
                //ignore gaps in the level, because you only need to fill up grid squares that have a tile
                if tiles[column, row] != nil
                {
                    //randomly create a new cookie type. It cannot be equal to the type of the last new cookie to prevent too many "free" matches
                    var newCookieType: CookieType
                    repeat
                    {
                        newCookieType = CookieType.random()
                    } while (newCookieType == cookieType)
                    
                    cookieType = newCookieType
                    
                    //create the new Cookie object and add it to the array for this column
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    array.append(cookie)
                }
                
                row -= 1
            }
            
            //if a column does not have any holes, you don;t add it to the final array
            if !(array.isEmpty)
            {
                columns.append(array)
            }
        }
        
        return columns
    }
    
    //calls helper methods and then combines their results into a single set
    func removeMatches() -> Set<Chain>
    {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeCookies(chains: horizontalChains)
        removeCookies(chains: verticalChains)
        
        calculateScores(for: horizontalChains)
        calculateScores(for: verticalChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    //called by removeMatches()
    private func removeCookies(chains: Set<Chain>)
    {
        for chain in chains
        {
            for cookie in chain.cookies
            {
                cookies[cookie.column, cookie.row] = nil
            }
        }
    }
    
    //helper method to removeMatches()
    private func detectHorizontalMatches() -> Set<Chain>
    {
        //create a new set to hold the horizontal chains (Chain objects)
        var set = Set<Chain>()
        
        //loop through the rows and columns | never look at the last two columns because these cookies can never begin a new chain
        for row in 0..<NumRows
        {
            var column = 0
            
            while (column < NumColumns - 2)
            {
                //skip over any gaps in the level design
                if let cookie = cookies[column, row]
                {
                    let matchType = cookie.cookieType
                    
                    //check whether the next two columns have the same cookie type. Normally, we would have to be careful not to step outside the bounds of the array when doing something like cookies[columns + 2, row] but that is not a problem here. That is why the for loop only goes up to NumColumns - 2. Note: the use of optional chaining with the '?'
                    if (cookies[column + 1, row]?.cookieType == matchType && cookies[column + 2, row]?.cookieType == matchType)
                    {
                        //there is a guarantee of a chain with at least 3 cookies, but potentially there are more. this steps through all the matching cookies until it finds a cookie that breaks the chain or it reaches the end of the grid. Then it adds all the matching cookies to a newChain object. Increment column for each match
                        let chain = Chain(chainType: .horizontal)
                        repeat
                        {
                            chain.add(cookie: cookies[column, row]!)
                            column += 1
                        } while (column < NumColumns && cookies[column, row]?.cookieType == matchType)
                        
                        set.insert(chain)
                        continue
                    }
                }
                
                //if the next two cookies don;t match the current one or if there is an empty tile then there is no chain, so skip over the cookie
                column += 1
            }
        }
        
        return set;
    }
    
    //helper method to removeMatches()
    //same logic as the horizontal version, but loops by column in the outer while loop and by row in the inner loop
    private func detectVerticalMatches() -> Set<Chain>
    {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns
        {
            var row = 0
            
            while (row < NumRows - 2)
            {
                if let cookie = cookies[column, row]
                {
                    let matchType = cookie.cookieType
                    
                    if (cookies[column, row + 1]?.cookieType == matchType && cookies[column, row + 2]?.cookieType == matchType)
                    {
                        let chain = Chain(chainType: .vertical)
                        repeat
                        {
                            chain.add(cookie: cookies[column, row]!)
                            row += 1
                        } while (row < NumRows && cookies[column, row]?.cookieType == matchType)
                        
                        set.insert(chain)
                        continue
                    }
                }
                
                row += 1
            }
        }
        
        return set
    }
    
    //checks to see if the set of possible swaps contains the specified Swap object (it automagically works...)
    func isPossibleSwap(_ swap:Swap) -> Bool
    {
        return possibleSwaps.contains(swap)
    }
    
    //makes temp copies of the row and column numbers from the Cookie objects since they get overwritten. To make the swap it updates the cookies array as well as the column and row properties of the Cookie objects, which shouldn't go out of sync
    func performSwap(swap: Swap)
    {
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
    
    private func calculateScores(for chains: Set<Chain>)
    {
        //3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on...
        for chain in chains
        {
            chain.score = 60 * (chain.length - 2) * comboMultiplier
            comboMultiplier += 1
        }
    }
    
    func resetComboMultiplier()
    {
        comboMultiplier = 1
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
        
        targetScore = dictionary["targetScore"] as! Int
        maximumMoves = dictionary["moves"] as! Int
    }
    
    
}



