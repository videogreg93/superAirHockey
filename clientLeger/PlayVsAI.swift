//
//  PlayVsAI.swift
//  clientLeger
//
//  Created by Marco on 2017-11-08.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit

class PlayVsAI : PlayMode {
    
    let AISpeed : TimeInterval = 1
    
    var lastInputLocationLeft : CGPoint?
    var lastDeltaLeft : CGPoint = CGPoint(x:0, y:0)
    
    var lastInputLocationRight : CGPoint?
    var lastDeltaRight : CGPoint = CGPoint(x:0, y:0)

    
    override init() {
        super.init()
        singlePlayer = true;
        NAME = "Play VS AI Mode"
    }

    public override func onSingleTap(_ touches: Set<UITouch>) {
        
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
    
    public override func onSingleFingerSlide(_ touches: Set<UITouch>) {
        
        for touch in touches {
            let adjustedCoords : CGPoint = touch.location(in: playScene)

            handlePlayerMovement(adjustedCoords);
        }
    }
    
    public override func onTouchEnded(_ touches: Set<UITouch>) {
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
            print("Speed " + newVelocity.debugDescription );
        }
        
    }
    
    
    public override func update(_ currentTime: TimeInterval){
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
    
    override func didBegin(_ contact: SKPhysicsContact) {
        
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
                    SoundManager.playGoalPoint();
                    playScene.canScoreGoal = false
                    playScene.handleGoal(false)
                    resetPositions = true
                }
                break
            
            case PlayModeUtils.RGOALCONTACTMASK:
                if (playScene.canScoreGoal){
                    SoundManager.playGoalPoint();
                    playScene.canScoreGoal = false
                    playScene.handleGoal(true)
                    resetPositions = true
                }
                break
            
            case PlayModeUtils.PLAYERCONTACTMASK:
                SoundManager.playPuckHitWall();
                puck.applyImpulse(other.velocity)
                break
            
            case PlayModeUtils.ACCELERATORCONTACTMASK:
                SoundManager.playAccelSound();
                let impulse : CGVector = PlayModeUtils.normalizeAndAdjust(puck.velocity, PlayModeUtils.ACCELERATORBOOST)
                puck.applyImpulse(impulse)
                addParticuleEmitterk("acceleratorTouch.sks", 0.5 ,  (other.node?.position)!,  puck.node)
                break
            
            case PlayModeUtils.PORTALCONTACTMASK:
                if let currentPortal = other.node as? PortalObject {
                    if let linkedPortal = currentPortal.linkedPortal {
                        // Needs to be defered since the physics cancel out the repositionning. The actual set happens in the update method
                        if(!(teleportedFrom === currentPortal || teleportedFrom === linkedPortal)){
                            SoundManager.playPortalSound();
                            teleportedFrom = currentPortal
                            teleportLocation = linkedPortal.position
                            teleportPuck = true
                        }
                    }
                }
                break
            
            case PlayModeUtils.BORDERWALLCONTACTMASK:
                SoundManager.playPuckHitWall();
                addParticuleEmitterk("sparks.sks", 0.1, contact.contactPoint)
                break
            
            case  PlayModeUtils.REGULARWALLCONTACTMASK :
                SoundManager.playPuckHitWall();
                addParticuleEmitterk("sparks.sks", 0.1, contact.contactPoint)
                break;
            
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
    
    
    
    private func addParticuleEmitterk(_ fileName : String, _ duration : TimeInterval ,_ contactPoint: CGPoint, _ target : SKNode? = nil){
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

}
