//
//  Array2D.swift
//  CookieCrunchTut
//
//  Created by User on 10/6/16.
//  Copyright © 2016 User. All rights reserved.
//


//this is a generic struct, swift does not natively have 2D array support like Objective C does so make a struct for it
struct Array2D<T>
{
    let columns: Int
    let rows: Int
    private var array: Array<T?>
    
    //creates an array of rows*columns all set to nil
    init(columns: Int, rows: Int)
    {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(repeating: nil, count: rows * columns)
    }
    
    subscript(column: Int, row: Int) -> T?
    {
        get
        {
            return array[row * columns + column]
        }
        set
        {
            array[row * columns + column] = newValue
        }
    }
    
    
}


