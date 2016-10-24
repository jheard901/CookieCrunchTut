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
import AVFoundation

class GameViewController: UIViewController {
    
    var scene: GameScene!
    var level: Level!
    
    var currentLevelNum = 1
    var movesLeft = 0
    var score = 0
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelResultPanel: UIImageView!
    @IBOutlet weak var shuffleButton: UIButton!
    
    @IBAction func pressedShuffleButton(_: AnyObject)
    {
        shuffle()
        decrementMoves()
    }
    
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
    
    //called after every turn to update the text inside the labels
    func updateLabels()
    {
        targetLabel.text = String(format: "%ld", level.targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
    }
    
    //the initialization code sits in a closure, it loads the background music MP3 and sets it to loop forever. Because the variable is marked lazy, the code from the closure will not run until backgroundMusic is first accessed
    lazy var backgroundMusic: AVAudioPlayer? = {
        
        guard let url = Bundle.main.url(forResource: "store/sounds/Mining by Moonlight", withExtension: "mp3") else
        {
            return nil
        }
        
        do
        {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch { return nil }
        
    }()
    
    
    func beginGame()
    {
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        scene.animateBeginGame()
        {
            self.shuffleButton.isHidden = false
        }
        
        shuffle()
    }
    
    func shuffle()
    {
        scene.removeAllCookieSprites() //cleanup after a level is over
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
            for chain in chains
            {
                self.score += chain.score
            }
            self.updateLabels()
            
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
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        view.isUserInteractionEnabled = true
        decrementMoves()
    }
    
    //decrements the counter keeping track of the number of moves and updates the onscreen labels
    func decrementMoves()
    {
        movesLeft -= 1
        updateLabels()
        
        if (score >= level.targetScore)
        {
            levelResultPanel.image = UIImage(named: "LevelComplete")
            currentLevelNum = currentLevelNum < NumLevels ? currentLevelNum + 1 : 1
            showLevelResult()
        }
        else if (movesLeft == 0)
        {
            levelResultPanel.image = UIImage(named: "GameOver")
            showLevelResult()
        }
    }
    
    //unhides the image view, disables touches on the scene, and adds a tap gesture recognizer that will restart the game
    func showLevelResult()
    {
        shuffleButton.isHidden = true
        levelResultPanel.isHidden = false
        scene.isUserInteractionEnabled = false
        
        scene.animateLevelResult()
        {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideLevelResult))
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    //hides the level result panel and restarts the game
    func hideLevelResult()
    {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        levelResultPanel.isHidden = true
        scene.isUserInteractionEnabled = true
        
        setupLevel(levelNum: currentLevelNum)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setp view with the current level
        setupLevel(levelNum: currentLevelNum)
        
        //play bg music
        //backgroundMusic?.play()
    }
    
    func setupLevel(levelNum: Int)
    {
        //configure the view
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        //create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        //instantiates a Level
        level = Level(filename: "store/levels/Level_\(levelNum)") //Note, that json files do not work in the Assets.xcassets file so you need to reference them directly from the directory
        scene.level = level
        scene.addTiles()
        
        //assigns the handleSwipe() function to GameScene's swipeHandler property. Now whenever GameScene calls swipeHandler(swap), it actually calls a function in GameViewController | this works in Swift because functions and closures can be used interchangeably
        scene.swipeHandler = handleSwipe
        
        //hide UI elements at start
        levelResultPanel.isHidden = true
        shuffleButton.isHidden = true
        
        //present scene
        skView.presentScene(scene)
        
        beginGame()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
}


