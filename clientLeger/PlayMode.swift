//
//  PlayMode.swift
//  clientLeger
//
//  Created by Marco on 2017-11-08.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit

class PlayMode {
    
    var NAME : String = "PlayMode"
    var playScene : PlayModeScene!
    
    var teleportLocation : CGPoint = CGPoint(x:0, y:0)
    var teleportedFrom : PortalObject?
    var teleportPuck : Bool = false

    var lastInputLocationLeft : CGPoint?
    var lastDeltaLeft : CGPoint = CGPoint(x:0, y:0)
    
    var lastInputLocationRight : CGPoint?
    var lastDeltaRight : CGPoint = CGPoint(x:0, y:0)
    
    var resetPositions : Bool = false
    var singlePlayer : Bool = true
    
    init(){
        
    }
    
    public func onSingleTap(_ touches: Set<UITouch>) {
        for touch in touches{
            let adjustedCoords : CGPoint = touch.location(in: playScene)
            
            let isLeftPlayer : Bool = (adjustedCoords.x < 0)
            
            if (isLeftPlayer) {
                lastInputLocationLeft = adjustedCoords
            }
            else {
                lastInputLocationRight = adjustedCoords
            }
        }
    }
    
    public func onSingleFingerSlide(_ touches: Set<UITouch>) {
        for touch in touches {
            let adjustedCoords : CGPoint = touch.location(in: playScene)
            if (playScene.playersCanMove) {
                handlePlayerMovement(adjustedCoords)
            }
        }
    }
    
    public func onTouchEnded(_ touches: Set<UITouch>) {
        for touch in touches {
            let adjustedCoords : CGPoint = touch.location(in: playScene)
            
            let isLeftPlayer : Bool = (adjustedCoords.x < 0)
            
            if (!isLeftPlayer && singlePlayer == false) {
                lastInputLocationRight = nil
                playScene.rightPlayer.physicsBody?.velocity = CGVector(dx:0, dy:0)
            }
            if isLeftPlayer {
                lastInputLocationLeft = nil
                playScene.leftPlayer.physicsBody?.velocity = CGVector(dx:0, dy:0)
            }
        }
    }
    
    public func handleAIMovement(){
        
        if (playScene.playersCanMove){
            let puckPosition = playScene.puck.position
            let goalX = abs(playScene.borderWalls[0].endPoint.x)
            var destination = CGPoint(x:puckPosition.x, y:puckPosition.y)
            
            if(puckPosition.x < 0){
                destination = CGPoint(x: goalX/2, y:0)
            }
            let delta = getDelta(destination, playScene.rightPlayer.position)
            let impulsePlayer = PlayModeUtils.normalizeAndAdjust(CGVector(dx: delta.x, dy: delta.y), PlayModeUtils.PLAYERMIMPULSEFACTOR)
            playScene.rightPlayer.physicsBody?.applyImpulse(impulsePlayer)
        }
    }
    
    public func handlePlayerMovement( _ adjustedCoords : CGPoint){
        
        let isRightPlayer : Bool = (adjustedCoords.x > 0)
        var player : SKSpriteNode;
        var lastInput : CGPoint;
        
        if (isRightPlayer && singlePlayer == false ){
            player = playScene.rightPlayer
            if let inputRight = lastInputLocationRight {
                lastInput = inputRight
                
                let delta : CGPoint = getDelta(adjustedCoords, lastInput)
                let impulsePlayer = PlayModeUtils.normalizeAndAdjust(CGVector(dx: delta.x, dy: delta.y), PlayModeUtils.PLAYERMIMPULSEFACTOR)
                player.physicsBody?.applyImpulse(impulsePlayer)
                
                lastDeltaRight = delta
                lastInputLocationRight = adjustedCoords
            }
            else {
                // Thats not pretty.... but it works
                return
            }
        }
            
        else if (!isRightPlayer){
            player = playScene.leftPlayer
            if let inputLeft = lastInputLocationLeft {
                lastInput = inputLeft
                
                let delta : CGPoint = getDelta(adjustedCoords, lastInput)
                let impulsePlayer = PlayModeUtils.normalizeAndAdjust(CGVector(dx: delta.x, dy: delta.y), PlayModeUtils.PLAYERMIMPULSEFACTOR)
                player.physicsBody?.applyImpulse(impulsePlayer)
                
                lastDeltaLeft = delta
                lastInputLocationLeft = adjustedCoords
            }
        }
    }
    
    private func adjustVelocity(){
        if let velocity = playScene.puck.physicsBody?.velocity{
            
            let newVelocity = PlayModeUtils.capSpeed(velocity, PlayModeUtils.MAXPUCKSPEED );
            playScene.puck.physicsBody?.velocity = newVelocity;
        }
        
    }
    
    
    public  func update(_ currentTime: TimeInterval){
        if (singlePlayer){
            handleAIMovement()
        }
        adjustVelocity()
        teleportPuckHandler()
        if (resetPositions){
            playScene.repositionToDefault();
            resetPositions = false
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let puck : SKPhysicsBody
        let other : SKPhysicsBody
        
        if ( contact.bodyA.contactTestBitMask == PlayModeUtils.BALLCONTACTMASK){
            puck = contact.bodyA
            other = contact.bodyB
        }
        else if (contact.bodyB.contactTestBitMask == PlayModeUtils.BALLCONTACTMASK){
            puck = contact.bodyB
            other = contact.bodyA
        }
            // Puck not involved... we don't care yet
        else {
            return
        }
        let otherContactBitMask =  other.contactTestBitMask
        
        switch otherContactBitMask{
        case PlayModeUtils.LGOALCONTACTMASK:
            if (playScene.canScoreGoal){
                playScene.canScoreGoal = false
                playScene.handleGoal(false)
                resetPositions = true
            }
            break
            
        case PlayModeUtils.RGOALCONTACTMASK:
            if (playScene.canScoreGoal){
                playScene.canScoreGoal = false
                playScene.handleGoal(true)
                resetPositions = true
            }
            break
            
        case PlayModeUtils.PLAYERCONTACTMASK:
            SoundManager.playPuckHitWall();
            puck.applyImpulse(other.velocity)
            addParticuleEmitter("sparks.sks", 0.1, contact.contactPoint)
            break
            
        case PlayModeUtils.ACCELERATORCONTACTMASK:
            SoundManager.playAccelSound();
            let impulse : CGVector = PlayModeUtils.normalizeAndAdjust(puck.velocity, playScene.accellerationCoeff)
            puck.applyImpulse(impulse)
            addParticuleEmitter("acceleratorTouch.sks", 0.5 ,  (other.node?.position)!,  puck.node)
            break
            
        case PlayModeUtils.PORTALCONTACTMASK:
            SoundManager.playPortalSound();
            if let currentPortal = other.node as? PortalObject {
                if let linkedPortal = currentPortal.linkedPortal {
                    // Needs to be defered since the physics cancel out the repositionning. The actual set happens in the update method
                    if(!(teleportedFrom === currentPortal || teleportedFrom === linkedPortal)){
                        teleportedFrom = currentPortal
                        teleportLocation = linkedPortal.position
                        teleportPuck = true
                    }
                }
            }
            break
            

        case PlayModeUtils.PORTALGRAVFIELDCONTACTMASK:
            print("Gravity Applying")
            if let field = other.node{
                let delta : CGPoint = CGPoint(x:(contact.contactPoint.x - field.position.x), y:(contact.contactPoint.x - field.position.x))
                puck.applyImpulse(CGVector (dx:delta.x * PlayModeUtils.GRAVITYSTRENGTH, dy: delta.y * PlayModeUtils.GRAVITYSTRENGTH))
            }
            break
            
        case PlayModeUtils.ACCELERATORCONTACTMASK:
            let impulse : CGVector = PlayModeUtils.normalizeAndAdjust(puck.velocity, playScene.accellerationCoeff)
            puck.applyImpulse(impulse)
            addParticuleEmitter("acceleratorTouch.sks", 0.5 ,  (other.node?.position)!,  puck.node)
            break
            
        case PlayModeUtils.BORDERWALLCONTACTMASK:
            SoundManager.playPuckHitWall();
            addParticuleEmitter("sparks.sks", 0.1, contact.contactPoint)
            break
            
        case  PlayModeUtils.REGULARWALLCONTACTMASK :
            SoundManager.playPuckHitWall();
            addParticuleEmitter("sparks.sks", 0.1, contact.contactPoint)
            break
            
        default:
            break
        }
    }
    
    private func teleportPuckHandler(){
        if (teleportPuck){
            playScene.puck.position = teleportLocation
            teleportPuck = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.teleportedFrom = nil
            }
        }
    }
    
    
    
    private func addParticuleEmitter(_ fileName : String, _ duration : TimeInterval ,_ contactPoint: CGPoint, _ target : SKNode? = nil){
        if(playScene.effectsEnabled){
            
            let effectNode =  SKEmitterNode(fileNamed: fileName)
            
            if let particule = effectNode{
                
                particule.position = contactPoint
                particule.zPosition = 5
                
                if let followNode = target {
                    particule.targetNode = followNode
                }
                
                let addAction = SKAction.run {
                    self.playScene.addChild(particule)
                }
                let waitAction = SKAction.wait(forDuration: duration)
                
                let removeAction = SKAction.run{
                    particule.removeFromParent()
                }
                
                let sequence = SKAction.sequence([addAction,waitAction,removeAction])
                
                playScene.run(sequence)
            }
        }
    }
    
    public func getDelta(_ point1 : CGPoint, _ point2 : CGPoint) -> CGPoint {
        return CGPoint(x:point1.x - point2.x, y:point1.y - point2.y)
    }
}
