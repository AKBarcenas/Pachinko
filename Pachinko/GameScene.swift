//
//  GameScene.swift
//  Pachinko
//
//  Created by Alex on 1/2/16.
//  Copyright (c) 2016 Alex Barcenas. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // The label that displays the user's current score.
    var scoreLabel: SKLabelNode!
    
    // The user's current score.
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // The label the user allows the user to edit.
    var editLabel: SKLabelNode!
    
    // Whether or not editing is allowed for the user.
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            }
            
            else {
                editLabel.text = "Edit"
            }
        }
    }
    
    /*
     * Function Name: didMoveToView
     * Parameters: view - the view that called this method.
     * Purpose: This method sets up the intial state of the game for the user.
     * Return Value: None
     */
    
    override func didMoveToView(view: SKView) {
        // Sets up the background.
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        background.zPosition = -1
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        physicsWorld.contactDelegate = self
        
        // Sets up the bouncers.
        makeBouncerAt(CGPoint(x: 0, y: 0))
        makeBouncerAt(CGPoint(x: 256, y: 0))
        makeBouncerAt(CGPoint(x: 512, y: 0))
        makeBouncerAt(CGPoint(x: 768, y: 0))
        makeBouncerAt(CGPoint(x: 1024, y: 0))
        
        // Sets up the slots.
        makeSlotAt(CGPoint(x: 128, y: 0), isGood: true)
        makeSlotAt(CGPoint(x: 384, y: 0), isGood: false)
        makeSlotAt(CGPoint(x: 640, y: 0), isGood: true)
        makeSlotAt(CGPoint(x: 896, y:0), isGood: false)
        
        // Sets up the score label.
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        // Sets up the editing label.
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)

    }
    
    /*
    * Function Name: touchesBegan
    * Parameters: touches - the touches that are associated with the event.
    *   event - the event that represents what the touches mean.
    * Purpose: This method responds to the user's touch and does different things depending on where
    *   the user touched and whether or not editing mode is on or off.
    * Return Value: None
    */
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            
            let objects = nodesAtPoint(location) as [SKNode]
            
            // The editing label was touched.
            if objects.contains(editLabel) {
                editingMode = !editingMode
            }
            
            else {
                // Editing mode is currently on and randomly colored and sized boxes are made.
                if editingMode  {
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.position = location
                    
                    box.physicsBody = SKPhysicsBody(rectangleOfSize: box.size)
                    box.physicsBody!.dynamic = false
                    
                    addChild(box)
                }
                  
                // Editing mode is currently off and red balls are made.
                else  {
                    let ball = SKSpriteNode(imageNamed: "ballRed")
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    ball.physicsBody!.restitution = 0.4
                    ball.position = location
                    ball.name = "ball"
                    addChild(ball)
                }
            }
        }
    }
    
    /*
     * Function Name: makeBouncerAt
     * Parameters: position - the position that the bouncer will be made.
     * Purpose: This method creates a bouncer at the specified position that will collide with
     *   others things, but will not move as a result of collisions.
     * Return Value: None
     */
    
    func makeBouncerAt(position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody!.contactTestBitMask = bouncer.physicsBody!.collisionBitMask
        bouncer.physicsBody!.dynamic = false
        addChild(bouncer)
    }
    
    /*
     * Function Name: makeSlotAt
     * Parameters: position - the position that the slot will be made in.
     *   isGood - the type of slot that will be made.
     * Purpose: This method creates a specified slot at the specified position.
     * Return Value: None
     */
    
    func makeSlotAt(position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        // The slot is a good one.
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        }
        
        // The slot is a bad one.
        else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        // Positions the slot.
        slotBase.position = position
        slotGlow.position = position
        
        // Changes the physics of the slot.
        slotBase.physicsBody = SKPhysicsBody(rectangleOfSize: slotBase.size)
        slotBase.physicsBody!.dynamic = false
        
        // Adds the slot to the scene.
        addChild(slotBase)
        addChild(slotGlow)
        
        // Rotates the slot over time.
        let spin = SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 10)
        let spinForever = SKAction.repeatActionForever(spin)
        slotGlow.runAction(spinForever)

    }
    
    /*
     * Function Name: collisionBetweenBall
     * Parameters: ball - the ball that collided with something.
     *   object - the thing that the ball collided with.
     * Purpose: This method handles when a ball collides with another object. This method also
     *   updates the score if the ball collided with a slot.
     * Return Value: None
     */
    
    func collisionBetweenBall(ball: SKNode, object: SKNode) {
        // The ball collided with a good slot.
        if object.name == "good" {
            destroyBall(ball)
            ++score
        }
        
        // The ball collided with a bad slot.
        else if object.name == "bad" {
            destroyBall(ball)
            --score
        }
    }
    
    /*
     * Function Name: destroyBall
     * Parameters: ball - the ball that is being removed.
     * Purpose: This method removes the ball and has a fire animation signify that is has disappeared.
     * Return Value: None
     */
    
    func destroyBall(ball: SKNode) {
        // The fire particle animation has been found.
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    /*
     * Function Name: didBeginContact
     * Parameters: contact - the contact that occurred.
     * Purpose: This method determines which object is the ball when contact between two objects occurs.
     * Return Value: None
     */
    
    func didBeginContact(contact: SKPhysicsContact) {
        // Object A is the ball.
        if contact.bodyA.node!.name == "ball" {
            collisionBetweenBall(contact.bodyA.node!, object: contact.bodyB.node!)
        }
        
        // Object B is the ball.
        else if contact.bodyB.node!.name == "ball" {
            collisionBetweenBall(contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
