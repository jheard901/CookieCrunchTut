//
//  GameViewController.swift
//  CookieCrunchTut
//
//  Created by User on 10/5/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var scene: GameScene!
    var level: Level!
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override var shouldAutorotate: Bool
    {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return [.portrait, .portraitUpsideDown]
        
        /*
         if UIDevice.current.userInterfaceIdiom == .phone
         {
         return .allButUpsideDown
         } else {
         return .all
         }
         */
    }
    
    func beginGame()
    {
        shuffle()
    }
    
    func shuffle()
    {
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(cookies: newCookies)
    }
    
    //the core gameplay logic
    func handleSwipe(swap: Swap)
    {
        //disable player input while the swap is happening
        view.isUserInteractionEnabled = false
        
        if(level.isPossibleSwap(swap))
        {
            //tell the level to perform the swap
            level.performSwap(swap: swap)
            
            //then tell the scene to animate the swap (updating the view)
            scene.animate(swap, completion: handleMatches)
            
            //reenable input on swap completion
            self.view.isUserInteractionEnabled = true
        }
        else
        {
            //alternate way of writing this could be: scene.animateInvalidSwap(swap) { }
            scene.animateInvalidSwap(swap, completion: {
                
                self.view.isUserInteractionEnabled = true
            })
            
        }
        
    }
    
    //event for handling when matches occur | note: Swift requires using 'self' inside closures
    func handleMatches() -> ()
    {
        let chains = level.removeMatches()
        if(chains.count == 0)
        {
            beginNextTurn()
            return
        }
        
        scene.animateMatchedCookies(for: chains)
        {
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns: columns)
            {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns, completion: {
                    
                    self.handleMatches()
                })
            }
            
        }
    }
    
    func beginNextTurn()
    {
        level.detectPossibleSwaps()
        view.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure the view
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        //create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        //instantiates a Level
        level = Level(filename: "store/levels/Level_1") //Note, that json files do not work in the Assets.xcassets file so you need to reference them directly from the directory
        scene.level = level
        scene.addTiles()
        
        //assigns the handleSwipe() function to GameScene's swipeHandler property. Now whenever GameScene calls swipeHandler(swap), it actually calls a function in GameViewController | this works in Swift because functions and closures can be used interchangeably
        scene.swipeHandler = handleSwipe
        
        //present scene
        skView.presentScene(scene)
        
        beginGame()
        
        /*
         //content pre-built into the 'Game' template
         
         // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
         // including entities and graphs.
         if let scene = GKScene(fileNamed: "GameScene") {
         
         // Get the SKScene from the loaded GKScene
         if let sceneNode = scene.rootNode as! GameScene? {
         
         // Copy gameplay related content over to the scene
         sceneNode.entities = scene.entities
         sceneNode.graphs = scene.graphs
         
         // Set the scale mode to scale to fit the window
         sceneNode.scaleMode = .aspectFill
         
         // Present the scene
         if let view = self.view as! SKView? {
         view.presentScene(sceneNode)
         
         view.ignoresSiblingOrder = true
         
         view.showsFPS = true
         view.showsNodeCount = true
         }
         }
         }
         */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
}


