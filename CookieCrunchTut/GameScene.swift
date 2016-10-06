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

