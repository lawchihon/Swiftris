//
//  GameScene.swift
//  Swiftris
//
//  Created by John Law on 10/11/15.
//  Copyright (c) 2015 Chi Hon Law. All rights reserved.
//

import SpriteKit

// we simply define the point size of each block sprite - in our case 20.0 x 20.0 - the lower of the available resolution options for each block image. We also declare a layer position which will give us an offset from the edge of the screen.
let BlockSize:CGFloat = 20.0

// we define a new constant TickLengthLevelOne. This variable will represent the slowest speed at which our shapes will travel. We've set it to 600 milliseconds, which means that every 6/10ths of a second, our shape should descend by one row.
let TickLengthLevelOne = NSTimeInterval(600)

class GameScene: SKScene {

    // we've introduced a couple of SKNodes which can be thought of as superimposed layers of activity within our scene. The gameLayer sits above the background visuals and the shapeLayer sits atop that.
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x: 6, y: -6)
    
    // tickLengthMillis and lastTick look similar to declarations we've seen before: one being the GameScene's current tick length – set to TickLengthLevelOne by default – and the other will track the last time we experienced a tick, an NSDate object.
    //
    // However, tick:(() -> ())? looks horrifying… tick is what's known as a closure in Swift. A closure is essentially a block of code that performs a function, and Swift refers to functions as closures. In defining tick, its type is (() -> ())? which means that it's a closure which takes no parameters and returns nothing. Its question mark indicates that it is optional and therefore may be nil.
    var tick:(() -> ())?
    var tickLengthMillis = TickLengthLevelOne
    var lastTick:NSDate?

    var textureCache = Dictionary<String, SKTexture>()
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // we'll put our new member variables to work. If lastTick is missing, we are in a paused state, not reporting elapsed ticks to anyone, therefore we simply return. However, if lastTick is present we recover the time passed since the last execution of update by invoking timeIntervalSinceNow on our lastTick object. Functions on objects are invoked using dot syntax in Swift.
        if lastTick == nil {
            return
        }
        let timePassed = lastTick!.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis {
            lastTick = NSDate()
            tick?()
        }

    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)
        
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)

    }
    
    // we provide accessor methods to let external classes stop and start the ticking process, something we'll make use of later in order to keep pieces from falling at key moments.
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }

    // we've written GameScene's most important function, pointForColumn(Int, Int). This function returns the precise coordinate on the screen for where a block sprite belongs based on its row and column position. The math here looks funky but just know that each sprite will be anchored at its center, therefore we need to find its center coordinate before placing it in our shapeLayer object.
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x: CGFloat = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y: CGFloat = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPointMake(x, y)
    }
    
    func addPreviewShapeToScene(shape:Shape, completion:() -> ()) {
        for (_, block) in shape.blocks.enumerate() {
            // we've created a method which will add a shape for the first time to the scene as a preview shape. We use a dictionary to store copies of re-usable SKTexture objects since each shape will require multiple copies of the same image.
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture)
            // #5
            sprite.position = pointForColumn(block.column, row:block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            // #6
            let moveAction = SKAction.moveTo(pointForColumn(block.column, row: block.row), duration: NSTimeInterval(0.2))
            moveAction.timingMode = .EaseOut
            let fadeInAction = SKAction.fadeAlphaTo(0.7, duration: 0.4)
            fadeInAction.timingMode = .EaseOut
            sprite.runAction(SKAction.group([moveAction, fadeInAction]))
        }
        runAction(SKAction.waitForDuration(0.4), completion: completion)
    }
    
    func movePreviewShape(shape:Shape, completion:() -> ()) {
        for (_, block) in shape.blocks.enumerate() {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.2)
            moveToAction.timingMode = .EaseOut
            sprite.runAction(
                SKAction.group([moveToAction, SKAction.fadeAlphaTo(1.0, duration: 0.2)]))
        }
        runAction(SKAction.waitForDuration(0.2), completion: completion)
    }
    
    func redrawShape(shape:Shape, completion:() -> ()) {
        for (_, block) in shape.blocks.enumerate() {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.05)
            moveToAction.timingMode = .EaseOut
            sprite.runAction(moveToAction)
        }
        runAction(SKAction.waitForDuration(0.05), completion: completion)
    }
}
