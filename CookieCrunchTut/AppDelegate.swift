//
//  AppDelegate.swift
//  CookieCrunchTut
//
//  Created by User on 10/5/16.
//  Copyright © 2016 User. All rights reserved.
//

/*
 If you encounter errors with code signing in the future, follow the steps and advice from these links below:
 http://stackoverflow.com/questions/29242485/command-usr-bin-codesign-failed-with-exit-code-1-code-sign-error
 http://stackoverflow.com/questions/2017756/command-usr-bin-codesign-failed-with-exit-code-1
 http://stackoverflow.com/questions/1090288/usr-bin-codesign-failed-with-exit-code-1
 
 If all else fails, a system restart might be all that is needed; but in my case it wasn't... I created a new project in an attempt to pin point what caused the code signing issue from before. I determined the cause of the problem is related to adding a folder to the project directory with the name "resources"; whenever I do this, the codesign error occurs and it doesn't seem like there is anything I can do to fix it - I am forced to start a new project to not have the error anymore.
 
 More details on how to fix the invalid argument error can be found here: http://stackoverflow.com/questions/27037589/installation-failed-invalid-argument-when-trying-to-run-today-application-exte and detailed information on how to reproduce the problem can be found within the "bug_report" folder that is within the project directory.
 */

//btw, the tutorial I'm using for this game provides a great explanation of MVC under header "The Scene and the View Controller" here: https://www.raywenderlich.com/125311/make-game-like-candy-crush-spritekit-swift-part-1

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

