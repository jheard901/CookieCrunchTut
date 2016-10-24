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
    
    let cropLayer = SKCropNode()
    let maskLayer = SKNode()
    
    //declaring variables with '?' means they are optionals and they should be initialized as nil when not in use
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    
    private var precisePoint: CGPoint?
    
    //marked as Level! with the '!' representing it will not initially have a value (ie in C++ this is a pointer!!!!)
    var level: Level!
    
    let TileWidth: CGFloat = 40.0 //32.0 original size | need to swap this value depending on the device that runs the game (ie 6s, 6s plus, or se)
    let TileHeight: CGFloat = 45.0 //36.0 original size
    
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
        gameLayer.isHidden = true
        //since the anchor point is set at (0.5, 0.5) - this is the center of the screen and origin of where objects will appear when added as nodes - then the cookie layer should be moved backwards by half its width and height so that it will also be centered on the screen
        let layerPosition = CGPoint(x: -TileWidth * CGFloat(NumColumns) / 2, y: -TileHeight * CGFloat(NumRows) / 2)
        tilesLayer.position = layerPosition //the tiles layer is added first so that it will appear behind the cookies | subsequent layers added to the gameLayer will always appear on top of layers added earlier if they have the same zPosition
        gameLayer.addChild(tilesLayer)
        
        //cropLayer (an SKCropNode) is a special kind of node that only draws its children where the mask contains pixels
        gameLayer.addChild(cropLayer)
        maskLayer.position = layerPosition
        cropLayer.maskNode = maskLayer
        
        cookiesLayer.position = layerPosition
        cropLayer.addChild(cookiesLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
        precisePoint = nil
        
        //pre-load the font for score
        let _ = SKLabelNode(fontNamed: "GillSans-BoldItalic")
    }
    
    //iterates through the set of cookies and addes a corresponding SKSpriteNode instance to the cookie layer
    func addSpritesForCookies(cookies: Set<Cookie>)
    {
        for cookie in cookies
        {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.position = pointForColumn(column:cookie.column, row:cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
            
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.25, withRange: 0.5),
                SKAction.group([SKAction.fadeIn(withDuration: 0.25), SKAction.scale(to: 1.0, duration: 0.25)])
            ]))
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
                    let tileNode = SKSpriteNode(imageNamed: "MaskTile")
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    tileNode.position = pointForColumn(column: column, row: row)
                    maskLayer.addChild(tileNode)
                }
            }
        }
        
        //draws a patten of border pieces in between the level tiles. Imagine dividing each tile into four quadrants; the four boolean variables indicate what kind of borders the tile has. eg in a square level, the tile in the lower-right corner would need a bg to cover the top-left only (see Tile_1.png). A tile with all neighboring tiles would get a full background (see Tile_15.png).
        for row in 0...NumRows
        {
            for column in 0...NumColumns
            {
                let topLeft = (column > 0) && (row < NumRows) && level.tileAt(column: column - 1, row: row) != nil
                let bottomLeft = (column > 0) && (row > 0) && level.tileAt(column: column - 1, row: row - 1) != nil
                let topRight = (column < NumColumns) && (row < NumRows) && level.tileAt(column: column, row: row) != nil
                let bottomRight = (column < NumColumns) && (row > 0) && level.tileAt(column: column, row: row - 1) != nil
                
                //the tiles are named from 0 to 15, according to the bitmask that is made by combined these four values
                let value = Int(topLeft.hashValue) | Int(topRight.hashValue) << 1 | Int(bottomLeft.hashValue) << 2 | Int(bottomRight.hashValue) << 3
                
                //values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn
                if(value != 0 && value != 6 && value != 9)
                {
                    let name = String(format: "Tile_%ld", value)
                    let tileNode = SKSpriteNode(imageNamed: name)
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    var point = pointForColumn(column: column, row: row)
                    point.x -= TileWidth / 2
                    point.y -= TileHeight / 2
                    tileNode.position = point
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func removeAllCookieSprites()
    {
        cookiesLayer.removeAllChildren()
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
                
                precisePoint = CGPoint(x: location.x, y: location.y)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
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
            
        }
        
        if(selectionSprite.parent != nil && swipeFromColumn != nil)
        {
            hideSelectionIndicator()
            swipeFromColumn = nil
            swipeFromRow = nil
        }
        else
        {
            swipeFromColumn = nil
            swipeFromRow = nil
        }
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
            animateScore(for: chain)
            
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
    
    //creates a new SKLabelNode with the score and places it in the center of the chain; the numbers float up a few pixels before disappearing
    func animateScore(for chain: Chain)
    {
        //figure out what the midpoint of the chain is
        let firstSprite = chain.firstCookie().sprite!
        let lastSprite = chain.lastCookie().sprite!
        let nX = (firstSprite.position.x + lastSprite.position.x) / 2
        let nY = (firstSprite.position.y + lastSprite.position.y) / 2 - 8
        let centerPosition = CGPoint(x: nX, y: nY)
        
        //add a lavel for the score that slowly floats up
        let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        scoreLabel.fontSize = 16
        scoreLabel.text = String(format: "%ld", chain.score)
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        cookiesLayer.addChild(scoreLabel)
        
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 3) , duration: 0.7)
        moveAction.timingMode = .easeOut
        scoreLabel.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
    
    //animates the entire gameLayer out of the way
    func animateLevelResult(_ completion: @escaping () -> ())
    {
        let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .easeIn
        gameLayer.run(action, completion: completion)
    }
    
    //slides the gameLater back in from the top of the screen
    func animateBeginGame(_ completion: @escaping () -> ())
    {
        gameLayer.isHidden = false
        gameLayer.position = CGPoint(x: 0, y: size.height)
        let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .easeOut
        gameLayer.run(action, completion: completion)
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
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder) is not used in this app")
    }
    
    
}

