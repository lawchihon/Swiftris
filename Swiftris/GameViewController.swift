//
//  GameViewController.swift
//  Swiftris
//
//  Created by John Law on 10/11/15.
//  Copyright (c) 2015 Chi Hon Law. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {

    var scene: GameScene!
    var swiftris:Swiftris!

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    // keep track of the last point on the screen at which a shape movement occurred or where a pan begins
    var panPointReference:CGPoint?

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
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        scene.tickLengthMillis = TickLengthLevelOne

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
        
        scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            swiftris.beginGame()
        }
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        levelLabel.text = "\(swiftris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("levelup.mp3")
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        // stop the ticks, redraw the shape at its new location and then let it drop. This will in turn call back to GameViewController and report that the shape has landed
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        
        scene.playSound("drop.mp3")
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        // recover the two arrays from Swiftris
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // detect any such new lines. If none are found, the next shape is brought in.
                self.gameShapeDidLand(swiftris)
            }
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    // all that is necessary to do after a shape has moved is to redraw its representative sprites at their new locations.
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }
    
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        // recover a point which defines the translation of the gesture relative to where it began. This is not an absolute coordinate, just a measure of the distance that the user's finger has traveled
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            // check whether or not the x translation has crossed our threshold - 90% of BlockSize - before proceeding
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                // check the velocity of the gesture
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        swiftris.dropShape()
    }
    
    // GameViewController will implement an optional delegate method found in UIGestureRecognizerDelegate which will allow each gesture recognizer to work in tandem with the others. However, at times a gesture recognizer may collide with another
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // The code performs several optional cast conditionals. These if conditionals attempt to cast the generic UIGestureRecognizer parameters as the specific types of recognizers we expect to be notified of. If the cast succeeds, the code block is executed
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let _ = gestureRecognizer as? UISwipeGestureRecognizer {
            if let _ = otherGestureRecognizer as? UIPanGestureRecognizer {
                return true
            }
        } else if let _ = gestureRecognizer as? UIPanGestureRecognizer {
            if let _ = otherGestureRecognizer as? UITapGestureRecognizer {
                return true
            }
        }
        return false
    }

}
