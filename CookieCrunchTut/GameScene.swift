//
//  GameScene.swift
//  CookieCrunchTut
//
//  Created by User on 10/5/16.
//  Copyright © 2016 User. All rights reserved.
//

import SpriteKit
import GameplayKit




class GameScene: SKScene {
    
    
    //sound effects
    let swapSound = SKAction.playSoundFileNamed("store/sounds/Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("store/sounds/Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("store/sounds/Ka-Ching.wav", waitForCompletion: false)
    let fallingCookieSound = SKAction.playSoundFileNamed("store/sounds/Scrape.wav", waitForCompletion: false)
    let addCookieSound = SKAction.playSoundFileNamed("store/sounds/Drip.wav", waitForCompletion: false)
    
    //this is a closure as indicated by the '->' | it takes a Swap object as its parameter and does not return anything. The '?' indicates that swipeHandler is allowed to be nil (i.e. it's an optional). It's the scene's job to handle touches so if it recognizes that user made a swipe then it will call the closure that's stored in the swipeHandler (this is how it communicates back to the GameViewController that a swap needs to take place).
    var swipeHandler: ((Swap) -> ())?
    
    var selectionSprite = SKSpriteNode()
    
    //declaring variables with '?' means they are optionals and they should be initialized as nil when not in use
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    
    //marked as Level! with the '!' representing it will not initially have a value (ie in C++ this is a pointer!!!!)
    var level: Level!
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLayer = SKNode()
    
    
    override init(size: CGSize)
    {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //added the "Background" resource into the Asssets.xcassets file so I do not need to reference its file path relative to the project directory anymore!
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = size
        addChild(background)
        
        //to keep the SpriteKit node heirarchy organized, this class "GameScene" will use several layers - the base layer will be "gameLayer" which will serve as the container for all other layers
        addChild(gameLayer)
        //since the anchor point is set at (0.5, 0.5) - this is the center of the screen and origin of where objects will appear when added as nodes - then the cookie layer should be moved backwards by half its width and height so that it will also be centered on the screen
        let layerPosition = CGPoint(x: -TileWidth * CGFloat(NumColumns) / 2, y: -TileHeight * CGFloat(NumRows) / 2)
        tilesLayer.position = layerPosition //the tiles layer is added first so that it will appear behind the cookies | subsequent layers added to the gameLayer will always appear on top of layers added earlier if they have the same zPosition
        gameLayer.addChild(tilesLayer)
        cookiesLayer.position = layerPosition
        gameLayer.addChild(cookiesLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    //iterates through the set of cookies and addes a corresponding SKSpriteNode isntance to the cookie layer
    func addSpritesForCookies(cookies: Set<Cookie>)
    {
        for cookie in cookies
        {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.position = pointForColumn(column:cookie.column, row:cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
        }
    }
    
    //this converts a column and row number into a point that is relative to the cookiesLayer | it represents the center of a cookie's SKSpriteNode
    func pointForColumn(column: Int, row: Int) -> CGPoint
    {
        return CGPoint(x: CGFloat(column) * TileWidth + TileWidth/2, y: CGFloat(row) * TileHeight + TileHeight/2)
    }
    
    //takes a CGPoint relative to cookiesLayer and converts it into column and row numbers - the return value is a tuple with 3 values: a bool indicating success or failure, the column number, and the row number
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int)
    {
        if(point.x >= 0 && point.x < CGFloat(NumColumns) * TileWidth && point.y >= 0 && point.y < CGFloat(NumRows) * TileHeight)
        {
            return (true, Int(point.x / TileWidth), Int(point.y/TileHeight))
        }
        else
        {
            return (false, 0 , 0) //invalid location
        }
    }
    
    //adds tile sprites to appropiate grid locations
    func addTiles()
    {
        for row in 0..<NumRows
        {
            for column in 0..<NumColumns
            {
                if level.tileAt(column: column, row: row) != nil
                {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    tileNode.position = pointForColumn(column: column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    //do not include super in this override because you want program to only use your defintion
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        
        //converts the touch location - if any - to a point relative to the cookiesLayer
        guard let touch = touches.first else { return }
        let location = touch.location(in: cookiesLayer)
        
        //if touch is inside a square on the level grid
        let (success, column, row) = convertPoint(point: location)
        if(success)
        {
            //verify the touch is on a cookie, rather an empty square
            if let cookie = level.cookieAt(column: column, row: row)
            {
                //highlight that cookie
                showSelectionIndicatorForCookie(cookie: cookie)
                
                //store the location of where swipe began
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        
        //if swipeFromColumn is nil then the swipe is outside valid area of game already commited a cookie swap. This could be tracked in a separate Bool but using swipeFromColumn works because it is an optional
        guard swipeFromColumn != nil else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: cookiesLayer)
        
        let (success, column, row) = convertPoint(point: location)
        if (success)
        {
            //figures out the direction of the player's swipe be comparing the new column and row numbers to the previous ones. Diagonal swipes are not allowed since we are using 'else if' statements for specific conditions
            //To read the actual values from swipeFromColumn and swipeFromRow we have to use '!' because these are optional variables, and using '!' will unwrap them. Normally, optional binding would be used to read the value of an optional but we are guaranteed that swipeFromColumn is not nil because we checked it earlier
            var horzDelta = 0, vertDelta = 0
            if (column < swipeFromColumn!) //swipe left
            {
                horzDelta = -1
            }
            else if (column > swipeFromColumn!) //swipe right
            {
                horzDelta = 1
            }
            else if (row < swipeFromRow!) //swipe down
            {
                vertDelta = -1
            }
            else if (row > swipeFromRow!) //swipe up
            {
                vertDelta = 1
            }
            
            //method will only perform the swap if player swiped out of the old square
            if (horzDelta != 0 || vertDelta != 0)
            {
                trySwap(horizontal: horzDelta, vertical: vertDelta)
            }
            
            //By setting swipeFromColumn back to nil, the game will ignore the rest of this swipe motion
            swipeFromColumn = nil
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if(selectionSprite.parent != nil && swipeFromColumn != nil)
        {
            hideSelectionIndicator()
        }
        
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        touchesEnded(touches, with: event)
    }
    
    func trySwap(horizontal horzDelta: Int, vertical vertDelta: Int)
    {
        //calculate column and row numbers of the cookie to swap with
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        
        //it's possible that toRow or toColumn can be outside the grid when swiping from a cookie near edge of the grid; ignore these swipes
        guard toColumn >= 0 && toColumn < NumColumns else { return }
        guard toRow >= 0 && toRow < NumRows else { return }
        
        //make sure there is actually a cookie at the new position; you can't swap if there is no 2nd cookie (happens when user swipes into a gap with no tile)
        if let toCookie = level.cookieAt(column: toColumn, row: toRow), let fromCookie = level.cookieAt(column: swipeFromColumn!, row: swipeFromRow!)
        {
            //execute the swap
            if let handler = swipeHandler
            {
                let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
                handler(swap)
            }
        }
        
    }
    
    //animates the swap of two cookies
    func animate(_ swap: Swap, completion: @escaping () -> ())
    {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.3
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        spriteA.run(moveA, completion: completion)
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        spriteB.run(moveB)
        
        //play sound effect
        run(swapSound)
    }
    
    //animates invalid swaps (slides cookies to their new positions and then immediately flips them back)
    func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> ())
    {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.2
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        
        spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.run(SKAction.sequence([moveB, moveA]))
        
        //play sound effect
        run(invalidSwapSound)
    }
    
    //loop through all the chains and all the cookies in each chain, and then trigger the animations. Because the same Cookie could be part of two chains (one horizontal and one verticl), we need to make sure to add only 1 animation to the sprite, not two. That's why the action is added to the sprite under the key "removing"; if such an action already exists you shouldn't need to add a new animation to the sprite. When the shrinking animation is done, the sprite is removed from the cookie later. The waitForDuration() action at the end of the method ensures that the rest of the game will only continue after the animations finish
    func animateMatchedCookies(for chains: Set<Chain>, completion: @escaping ()->())
    {
        for chain in chains
        {
            for cookie in chain.cookies
            {
                if let sprite = cookie.sprite
                {
                    if sprite.action(forKey: "removing") == nil
                    {
                        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                        scaleAction.timingMode = .easeOut
                        sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey: "removing")
                    }
                }
            }
        }
        
        run(matchSound)
        run(SKAction.wait(forDuration: 0.3), completion: completion)
    }
    
    func animateFallingCookies(columns: [[Cookie]], completion: @escaping () -> ())
    {
        //only call the completion block after all the animations are finished. Because the number of falling cookies may very, we can't hardcode the total duration, but instead need to compute it
        var longestDuration: TimeInterval = 0
        
        for array in columns
        {
            for(idx, cookie) in array.enumerated()
            {
                let newPosition = pointForColumn(column: cookie.column, row: cookie.row)
                
                //the higher up the cookie is, the bigger the delay on the animation. That looks more dynamic than dropping all the cookies at the same time. This calculation works because fillHoles() guarantees that lower cookies are first in the array
                let delay = 0.05 + 0.15 * TimeInterval(idx)
                
                //the duration of the animation is based on how far the cookie has to fall (0.1 seconds per tile) | tweak these numbers to change the feel of the animation
                let sprite = cookie.sprite!
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                
                //calculate which animation is the longest. This is the time the game has to wait before it may continue
                longestDuration = max(longestDuration, duration + delay)
                
                //per the animation, which consists of a delay, a movement, and a sound effect
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.group([moveAction, fallingCookieSound])
                ]))
            }
        }
        
        //wait until all the cookies have fallen down before allowing the gameplay to continue
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func animateNewCookies(_ columns: [[Cookie]], completion: @escaping () -> ())
    {
        //the game is not allowed to continue until all the animations are complete, so we calculate the duration of the longest animation to use later
        var longestDuration: TimeInterval = 0
        
        for array in columns
        {
            //the new cookie sprite should start out just above the first tile in this column. An easy way to find the row number of this tile is to look at the row of the first cookie in the array, which is always the top-most one for this column
            let startRow = array[0].row + 1
            
            for (idx, cookie) in array.enumerated()
            {
                //create a new sprite for the cookie
                let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
                sprite.size = CGSize(width: TileWidth, height: TileHeight)
                sprite.position = pointForColumn(column: cookie.column, row: startRow)
                cookiesLayer.addChild(sprite)
                cookie.sprite = sprite
                
                //the higher the cookie, the longer we make the delay, so the cookies appear to fall after one another
                let delay = 0.1 + 0.2 * TimeInterval(array.count - idx - 1)
                
                //calculate the animation's duration based on how far the cookie has to fall
                let duration = TimeInterval(startRow - cookie.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                
                //animate the sprite falling down and fading in. This makes the cookies appear less abruptly out of thin air at the top of the grid
                let newPosition = pointForColumn(column: cookie.column, row: cookie.row)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.alpha = 0
                sprite.run(SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.05),
                        moveAction,
                        addCookieSound])
                ]))
            }
        }
        
        //wait until the animations are done before continuing the game
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    //gets the name of the highlight sprite imahe from the Cookie object and puts the corresponding texture on the selection sprite. Simply setting the texture on the sprite doesn;t give it the correct size but using an SKAction does. The selectionSprite is also made visible by setting its alpha to 1, and is added as a child of the cookie sprite so that it moves along with it in the swap animation
    func showSelectionIndicatorForCookie(cookie: Cookie)
    {
        if(selectionSprite.parent != nil)
        {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = cookie.sprite
        {
            let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
            selectionSprite.size = CGSize(width: TileWidth, height: TileHeight)
            selectionSprite.run(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    
    //removes the selection sprite by fading it out
    func hideSelectionIndicator()
    {
        selectionSprite.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    /*
     //content pre-built into the 'Game' template
     
     var entities = [GKEntity]()
     var graphs = [String : GKGraph]()
     
     private var lastUpdateTime : TimeInterval = 0
     private var label : SKLabelNode?
     private var spinnyNode : SKShapeNode?
     
     override func sceneDidLoad() {
     
     self.lastUpdateTime = 0
     
     // Get label node from scene and store it for use later
     self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
     if let label = self.label {
     label.alpha = 0.0
     label.run(SKAction.fadeIn(withDuration: 2.0))
     }
     
     // Create shape node to use during mouse interaction
     let w = (self.size.width + self.size.height) * 0.05
     self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
     
     if let spinnyNode = self.spinnyNode {
     spinnyNode.lineWidth = 2.5
     
     spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
     spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
     SKAction.fadeOut(withDuration: 0.5),
     SKAction.removeFromParent()]))
     }
     }
     
     
     func touchDown(atPoint pos : CGPoint) {
     if let n = self.spinnyNode?.copy() as! SKShapeNode? {
     n.position = pos
     n.strokeColor = SKColor.green
     self.addChild(n)
     }
     }
     
     func touchMoved(toPoint pos : CGPoint) {
     if let n = self.spinnyNode?.copy() as! SKShapeNode? {
     n.position = pos
     n.strokeColor = SKColor.blue
     self.addChild(n)
     }
     }
     
     func touchUp(atPoint pos : CGPoint) {
     if let n = self.spinnyNode?.copy() as! SKShapeNode? {
     n.position = pos
     n.strokeColor = SKColor.red
     self.addChild(n)
     }
     }
     
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     if let label = self.label {
     label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
     }
     
     for t in touches { self.touchDown(atPoint: t.location(in: self)) }
     }
     
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
     }
     
     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
     for t in touches { self.touchUp(atPoint: t.location(in: self)) }
     }
     
     override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
     for t in touches { self.touchUp(atPoint: t.location(in: self)) }
     }
     
     
     override func update(_ currentTime: TimeInterval) {
     // Called before each frame is rendered
     
     // Initialize _lastUpdateTime if it has not already been
     if (self.lastUpdateTime == 0) {
     self.lastUpdateTime = currentTime
     }
     
     // Calculate time since last update
     let dt = currentTime - self.lastUpdateTime
     
     // Update entities
     for entity in self.entities {
     entity.update(deltaTime: dt)
     }
     
     self.lastUpdateTime = currentTime
     }
     */
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder) is not used in this app")
    }
    
    
}

