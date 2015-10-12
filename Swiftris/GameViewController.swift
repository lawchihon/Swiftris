//
//  GameViewController.swift
//  Swiftris
//
//  Created by John Law on 10/11/15.
//  Copyright (c) 2015 Chi Hon Law. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, SwiftrisDelegate {

    var scene: GameScene!
    var swiftris:Swiftris!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // we've set a closure for the tick property of GameScene.swift.
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.delegate = self
        swiftris.beginGame()

        // Present the scene.
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // lower the falling shape by one row and then asks GameScene to redraw the shape at its new location.
    func didTick() {
        // we substituted our previous efforts with Swiftris' letShapeFall() function, precisely what we need at each tick.
        swiftris.letShapeFall()
    }
    
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        if let fallingShape = newShapes.fallingShape {
            self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.scene.movePreviewShape(fallingShape) {
                // we introduced a boolean which allows us to shut down interaction with the view. Regardless of what the user does to the device at this point, they will not be able to manipulate Switris in any way. This is useful during intermediate states when blocks are being animated, shifted around or calculated. Otherwise, a well-timed user interaction may cause an unpredictable game state to occur.
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
            }
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = false
        scene.stopTicking()
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        nextShape()
    }
    
    // all that is necessary to do after a shape has moved is to redraw its representative sprites at their new locations.
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }

}
