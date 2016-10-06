//
//  Extensions.swift
//  CookieCrunchTut
//
//  Created by User on 10/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

extension Dictionary
{
    //this is mostly boilerplate code; one day I'll understand what this means?
    //to learn more about JSON do this tut: https://www.raywenderlich.com/5492/working-with-json-in-ios-5
    static func loadJSONFromBundle(filename: String) -> Dictionary <String, AnyObject>?
    {
        var dataOK: NSData
        var dictionaryOK: NSDictionary = NSDictionary()
        
        if let path = Bundle.main.path(forResource: filename, ofType: "json")
        {
            let  _: NSError?
            
            do
            {
                let pathURL = NSURL(fileURLWithPath: path)  //need to convert to URL as specified here: http://stackoverflow.com/questions/24410473/how-to-convert-this-var-string-to-nsurl-in-swift
                let data = try NSData(contentsOf: pathURL as URL, options: NSData.ReadingOptions()) as NSData!
                dataOK = data!
            }
            catch
            {
                print("Could not load level file: \(filename), error: \(error)")
                return nil
            }
            
            do
            {
                let dictionary = try JSONSerialization.jsonObject(with: dataOK as Data, options: JSONSerialization.ReadingOptions()) as AnyObject!
                dictionaryOK = (dictionary as! NSDictionary as? Dictionary <String, AnyObject>)! as NSDictionary    //"idk Kev", the IDE inserted a bunch of auto-correct casts here for me that I don't understand!
                //You can read up more on the typecasting here: https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/TypeCasting.html
            }
            catch
            {
                print("Level file '\(filename)' is not valid JSON: \(error)")
                return nil
            }
        }
        return dictionaryOK as? Dictionary <String, AnyObject>
    }
}


