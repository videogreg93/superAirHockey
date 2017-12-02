//
//  PlayModeUtils.swift
//  clientLeger
//
//  Created by Marco on 2017-11-08.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit

class PlayModeUtils {
    
    // Contact Masks
    static let BALLCONTACTMASK : UInt32 = 1023;
    static let PLAYERCONTACTMASK : UInt32 = 1;
    static let LINECONTACTMASK : UInt32 = 2;
    static let REGULARWALLCONTACTMASK : UInt32 = 128
    static let BORDERWALLCONTACTMASK : UInt32 = 64
    static let ACCELERATORCONTACTMASK : UInt32 = 16;
    static let PORTALGRAVFIELDCONTACTMASK : UInt32 = 256;
    static let PORTALCONTACTMASK : UInt32 = 32;
    static let LGOALCONTACTMASK : UInt32 = 4;
    static let RGOALCONTACTMASK : UInt32 = 8;
    
    // Gravity
    static let GRAVITYFIELDMASK : UInt32 = 1
    static let NOGRAVITYFIELDMASK : UInt32 = 0
    
    // Collision Masks
    static let BALLCOLLISIONMASK : UInt32 = 0b00001111
    static let LEFTPLAYERCOLLISIONMASK : UInt32 = 0b01000001
    static let LINECOLLISIONMASK : UInt32 = 0b01110000
    static let REGULARWALLCOLLISIONMASK : UInt32 = 0b00000010
    static let BORDERWALLCOLLISIONMASK : UInt32 = 0b00000001
    static let ACCELERATORCOLLISIONMASK : UInt32 = 0
    static let PORTALCOLLISIONMASK : UInt32 = 0
    static let GOALCOLLISIONMASK : UInt32 = 0
    
    // Physics related
    static let PUCKMASS : CGFloat = 1
    static let PLAYERMASS : CGFloat = 1000
    static let PLAYERMIMPULSEFACTOR : CGFloat = 10000
    static let GRAVITYSTRENGTH : CGFloat = 0.5
    static let MAXPUCKSPEED : CGFloat = 400
    
    public static func initPuck(_ friction : CGFloat = 0.1, _ restitution : CGFloat = 1) -> SKSpriteNode {
        let puckTexture = SKTexture(imageNamed: "puck");
        
        let tempPuck = SKSpriteNode(texture: puckTexture, color: UIColor.clear, size: puckTexture.size())
        tempPuck.name = "puck"
        tempPuck.xScale = 0.45
        tempPuck.yScale = 0.45
        tempPuck.zPosition = 2
        tempPuck.position = CGPoint(x:0, y:0)
        
        tempPuck.physicsBody = SKPhysicsBody(circleOfRadius: tempPuck.size.width/2)
        tempPuck.physicsBody?.affectedByGravity = false
        tempPuck.physicsBody?.allowsRotation = false
        tempPuck.physicsBody?.restitution = 1
        tempPuck.physicsBody?.mass = PUCKMASS
        tempPuck.physicsBody?.isDynamic = true
        tempPuck.physicsBody?.linearDamping = friction
        tempPuck.physicsBody?.angularDamping = 0
        tempPuck.physicsBody?.categoryBitMask = BALLCOLLISIONMASK
        tempPuck.physicsBody?.collisionBitMask = BALLCOLLISIONMASK
        tempPuck.physicsBody?.contactTestBitMask = BALLCONTACTMASK
        tempPuck.physicsBody?.fieldBitMask = GRAVITYFIELDMASK
        
        return tempPuck
    }
    
    public static func initPlayer(_ borderWalls : [BorderWallObject], _ isLeftPlayer : Bool, _ friction : CGFloat = 0.1, _ restitution : CGFloat = 1) -> SKSpriteNode {

        
        var tempPlayer : SKSpriteNode = SKSpriteNode()
        if(borderWalls.count > 1){
            var xOffset = abs (borderWalls[0].endPoint.x / 2)
            var name : String =  "rightPlayer"
            var textureImageName : String = "player2" ;
            
            if (isLeftPlayer){
                textureImageName = "player1" ;
                name = "leftPlayer"
                xOffset = -1 * xOffset
            }
            
            let playerTexture = SKTexture(imageNamed: textureImageName);
            tempPlayer = SKSpriteNode(texture: playerTexture, color: UIColor.clear, size: playerTexture.size())
            
            tempPlayer.name = name
            tempPlayer.position = CGPoint(x:xOffset, y:0)
            
            tempPlayer.xScale = 0.55
            tempPlayer.yScale = 0.55
            tempPlayer.zPosition = 3
            
            tempPlayer.physicsBody = SKPhysicsBody(circleOfRadius: tempPlayer.size.width/2)
            tempPlayer.physicsBody?.affectedByGravity = false
            tempPlayer.physicsBody?.allowsRotation = false
            tempPlayer.physicsBody?.restitution = 1
            tempPlayer.physicsBody?.friction = 0
            tempPlayer.physicsBody?.mass = PLAYERMASS
            tempPlayer.physicsBody?.isDynamic = true
            tempPlayer.physicsBody?.linearDamping = 2
            tempPlayer.physicsBody?.angularDamping = 0
            tempPlayer.physicsBody?.categoryBitMask = LEFTPLAYERCOLLISIONMASK
            tempPlayer.physicsBody?.collisionBitMask = LEFTPLAYERCOLLISIONMASK
            tempPlayer.physicsBody?.contactTestBitMask = PLAYERCONTACTMASK
            tempPlayer.physicsBody?.fieldBitMask = NOGRAVITYFIELDMASK
        }
        
        return tempPlayer
    }
    
    public static func initFloor(_ floorPath : [CGPoint], _ friction : CGFloat = 0.1) -> SKSpriteNode{
        
        let maxRange : CGPoint = findMaxSpread(floorPath)
        let floorNode = SKSpriteNode(color:SKColor.white ,size: CGSize(width: maxRange.x, height: maxRange.y));
        floorNode.alpha = 0
        
        floorNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: floorNode.size.width, height: floorNode.size.height))
        floorNode.physicsBody?.affectedByGravity = false
        floorNode.physicsBody?.restitution = 1
        floorNode.physicsBody?.friction = friction
        floorNode.physicsBody?.isDynamic = true
        floorNode.physicsBody?.linearDamping = 0
        floorNode.physicsBody?.angularDamping = 0
        floorNode.physicsBody?.categoryBitMask = BORDERWALLCOLLISIONMASK
        floorNode.physicsBody?.contactTestBitMask = 0
        floorNode.physicsBody?.collisionBitMask = BORDERWALLCOLLISIONMASK
        floorNode.physicsBody?.fieldBitMask = NOGRAVITYFIELDMASK
        
        return floorNode
    }
    
    public static func attachGravityField(_ portalNode : PortalObject){
        
        // Homemade Sln
        if portalNode.childNode(withName: "gravityField") == nil {
            let circleNode = SKShapeNode(circleOfRadius: portalNode.size.width)
            circleNode.name = "gravityField"
            circleNode.fillColor = UIColor.clear
            circleNode.alpha = 0
            circleNode.zPosition = 1
            circleNode.physicsBody = SKPhysicsBody(circleOfRadius: portalNode.size.width)
            circleNode.physicsBody?.restitution = 1
            circleNode.physicsBody?.friction = 0
            circleNode.physicsBody?.isDynamic = false
            circleNode.physicsBody?.linearDamping = 0
            circleNode.physicsBody?.angularDamping = 0
            circleNode.physicsBody?.categoryBitMask = PORTALGRAVFIELDCONTACTMASK
            circleNode.physicsBody?.contactTestBitMask = PORTALGRAVFIELDCONTACTMASK
            circleNode.physicsBody?.collisionBitMask = 0b0
            circleNode.physicsBody?.fieldBitMask = NOGRAVITYFIELDMASK
            
            portalNode.addChild(circleNode)
        }
    }
    
    public static func findMaxSpread(_ floorPath : [CGPoint]) -> CGPoint{
        var currentMinMax : CGPoint = CGPoint(x:0, y:0)
        
        for point in floorPath {
            if (abs(point.x) > currentMinMax.x){
                currentMinMax.x = abs(point.x)
            }
            if (abs(point.y) > currentMinMax.y){
                currentMinMax.y = abs(point.y)
            }
        }
        
        return currentMinMax
    }
    
    public static func initMiddleLine(_ borderWalls : [BorderWallObject]) -> SKSpriteNode{
        
        if (borderWalls.count > 1){
            let topPoint : CGPoint = borderWalls[3].startPoint
            let bottomPoint : CGPoint = borderWalls[7].startPoint
            
            let height : CGFloat = topPoint.y + abs(bottomPoint.y)
            let width : CGFloat = 5
            
            let node = SKSpriteNode(color: SKColor.red, size: CGSize(width:width, height: height))
            node.zPosition = 1
            node.name = "middleLine"
            
            node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.size.width, height: node.size.height))
            node.physicsBody?.restitution = 0
            node.physicsBody?.friction = 0
            node.physicsBody?.isDynamic = false
            node.physicsBody?.linearDamping = 0
            node.physicsBody?.angularDamping = 0
            node.physicsBody?.categoryBitMask = LINECOLLISIONMASK
            node.physicsBody?.contactTestBitMask = LINECONTACTMASK
            node.physicsBody?.collisionBitMask = LINECOLLISIONMASK
            node.physicsBody?.fieldBitMask = NOGRAVITYFIELDMASK
         
            return node
        }
        else {
            return SKSpriteNode()
        }
    }
    
    public static func setBorderWallPhysics(_ borderWall : BorderWallObject, _ friction : CGFloat = 0.1, _ restitution : CGFloat = 1){
        borderWall.name = "borderWall"
        
        borderWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: borderWall.size.width, height: borderWall.size.height))
        borderWall.physicsBody?.affectedByGravity = false
        borderWall.physicsBody?.allowsRotation = false
        borderWall.physicsBody?.mass = PLAYERMASS
        borderWall.physicsBody?.restitution = 1
        borderWall.physicsBody?.friction = 0
        borderWall.physicsBody?.isDynamic = false
        borderWall.physicsBody?.linearDamping = 0
        borderWall.physicsBody?.angularDamping = 0
        borderWall.physicsBody?.categoryBitMask = BORDERWALLCOLLISIONMASK
        borderWall.physicsBody?.contactTestBitMask = BORDERWALLCONTACTMASK
        borderWall.physicsBody?.collisionBitMask = BORDERWALLCOLLISIONMASK
        borderWall.physicsBody?.fieldBitMask = NOGRAVITYFIELDMASK
        
    }
    
    public static func setGoalPhysics(_ goalSegment : GoalObject){
  
        goalSegment.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: goalSegment.size.width, height: goalSegment.size.height))
        goalSegment.physicsBody?.affectedByGravity = false
        goalSegment.physicsBody?.allowsRotation = false
        goalSegment.physicsBody?.restitution = 0
        goalSegment.physicsBody?.friction = 0
        goalSegment.physicsBody?.isDynamic = false
        goalSegment.physicsBody?.linearDamping = 0
        goalSegment.physicsBody?.angularDamping = 0
        goalSegment.physicsBody?.categoryBitMask = GOALCOLLISIONMASK
        goalSegment.physicsBody?.collisionBitMask = GOALCOLLISIONMASK
        if( goalSegment.position.x > 0){
            goalSegment.name = "rightGoal"
            goalSegment.physicsBody?.contactTestBitMask = RGOALCONTACTMASK
        }
        else {
            goalSegment.name = "leftGoal"
            goalSegment.physicsBody?.contactTestBitMask = LGOALCONTACTMASK
        }
        goalSegment.physicsBody?.fieldBitMask = NOGRAVITYFIELDMASK
        
    }
    
    public static func setPortalPhysics(_ portal : PortalObject){
        portal.physicsBody = SKPhysicsBody(circleOfRadius: portal.size.width/2)
        
        if (portal.firstPortal){
            portal.name = "firstPortal"
        }
        else {
            portal.name = "secondPortal"
        }
        
        portal.physicsBody?.affectedByGravity = false
        portal.physicsBody?.allowsRotation = false
        portal.physicsBody?.restitution = 0
        portal.physicsBody?.friction = 0
        portal.physicsBody?.isDynamic = false
        portal.physicsBody?.linearDamping = 0
        portal.physicsBody?.angularDamping = 0
        portal.physicsBody?.categoryBitMask = PORTALCONTACTMASK
        portal.physicsBody?.contactTestBitMask = PORTALCONTACTMASK
        portal.physicsBody?.collisionBitMask = 0b0
        portal.physicsBody?.fieldBitMask = NOGRAVITYFIELDMASK
        
        attachGravityField(portal)
    }
    
    public static func setAcceleratorPhysics(_ accelerator : AcceleratorObject){
        accelerator.physicsBody = SKPhysicsBody(circleOfRadius: accelerator.size.width/2)
        
        accelerator.name = "accelerator"
        
        accelerator.physicsBody?.affectedByGravity = false
        accelerator.physicsBody?.allowsRotation = false
        accelerator.physicsBody?.restitution = 0
        accelerator.physicsBody?.friction = 0
        accelerator.physicsBody?.isDynamic = false
        accelerator.physicsBody?.linearDamping = 0
        accelerator.physicsBody?.angularDamping = 0
        accelerator.physicsBody?.categoryBitMask = ACCELERATORCONTACTMASK
        accelerator.physicsBody?.contactTestBitMask = ACCELERATORCONTACTMASK
        accelerator.physicsBody?.collisionBitMask = ACCELERATORCOLLISIONMASK
        accelerator.physicsBody?.fieldBitMask = NOGRAVITYFIELDMASK
    }
    
    public static func setWallPhysics(_ wall : WallObject, _ friction : CGFloat = 0.1, _ restitution : CGFloat = 1){
        wall.name = "regularWall"
        wall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wall.size.width, height: wall.size.height))
        wall.physicsBody?.affectedByGravity = false
        wall.physicsBody?.allowsRotation = false
        wall.physicsBody?.restitution = 1
        wall.physicsBody?.friction = 0
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.linearDamping = 0
        wall.physicsBody?.angularDamping = 0
        wall.physicsBody?.categoryBitMask = REGULARWALLCOLLISIONMASK
        wall.physicsBody?.contactTestBitMask = REGULARWALLCONTACTMASK
        wall.physicsBody?.collisionBitMask = REGULARWALLCOLLISIONMASK
        wall.physicsBody?.fieldBitMask = NOGRAVITYFIELDMASK
    }
    
    
    public static func normalizeAndAdjust(_ velocity : CGVector, _ puckSpeed : CGFloat) -> CGVector{
        let length = sqrt(velocity.dx*velocity.dx + velocity.dy*velocity.dy)
        return CGVector(dx: puckSpeed * velocity.dx/length, dy: puckSpeed * velocity.dy/length)
    }
    
    public static func capSpeed(_ velocity : CGVector, _ speedLimit : CGFloat) -> CGVector{
        if (abs(velocity.dx) > speedLimit || abs(velocity.dy) > speedLimit){
            let length = sqrt(velocity.dx*velocity.dx + velocity.dy*velocity.dy)
            return CGVector(dx: speedLimit * velocity.dx/length, dy: speedLimit * velocity.dy/length)
        }
        else {
            return velocity
        }
    }
    
    public static func createLightNode() -> SKLightNode{
        let light = SKLightNode()
        light.falloff = 1
        light.lightColor = UIColor.red
        return light
    }
    
    public static func animatePuck(_ node : SKSpriteNode){
        animateDarkClear(node);
        node.colorBlendFactor = 0.2
    }
    
    static func animateDarkClear(_ node : SKSpriteNode) {
        
        node.colorBlendFactor = 0.5
        let makeDarker = SKAction.colorize(with: UIColor.lightGray, colorBlendFactor: 0.5, duration: 2)
        let makePaler = SKAction.colorize(with: UIColor.darkGray, colorBlendFactor: 0.5, duration: 2)
        
        let colorSequence = SKAction.sequence([makeDarker,makePaler])
        
        node.run(SKAction.repeatForever(colorSequence))
    }
    
}
