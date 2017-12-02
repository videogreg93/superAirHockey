//
//  PlayModeScene.swift
//  clientLeger
//
//  Created by Marco on 2017-11-08.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit

class PlayModeScene : SKScene, SKPhysicsContactDelegate{
    
    var playMode : PlayMode
    var controller : PlayModeController?

    // Score related
    var lpScore : UILabel!
    var rpScore : UILabel!
    var rpName : UILabel!
    var lpName : UILabel!
    var lpScoreValue : Int = 0
    var rpScoreValue : Int = 0
    var canScoreGoal : Bool = true
    var goalLimit : Int = 2
    
    // Timer related
    var gameTimer : Timer = Timer()
    var timeLabel : UILabel!
    var seconds : Int = 0
    
    // Object related
    var editableItems : Set<GameObject>
    var borderWalls : [BorderWallObject]
    var goalSections : [GoalObject]
    var floorPath : [CGPoint]
    var arenaFloor : SKShapeNode
    var middleLine : SKSpriteNode
    
    // Player and puck related
    var leftPlayer : SKSpriteNode
    var rightPlayer : SKSpriteNode
    var puck : SKSpriteNode
    
    // Effect related
    var effectsEnabled : Bool = true
    
    // Physics related
    var frictionCoeff : CGFloat = 0.1
    var restitutionCoeff : CGFloat = 1
    var accellerationCoeff : CGFloat = 3
    var playersCanMove : Bool = false;
    
    var isSinglePlayer : Bool = true
    var isTestMode : Bool = false
    
    var isInPause: Bool = false
    
    override init() {
        playMode = PlayMode();
        
        editableItems = Set<GameObject>()
        borderWalls = [BorderWallObject]()
        goalSections  = [GoalObject]()
        arenaFloor = SKShapeNode()
        floorPath = []
        
        leftPlayer = SKSpriteNode()
        rightPlayer = SKSpriteNode()
        puck = SKSpriteNode()
        middleLine = SKSpriteNode()

        super.init()
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx:0,dy:0)
        reloadMap()
    }
    
    required init?(coder aDecoder: NSCoder) {
        playMode = PlayMode();
        editableItems = Set<GameObject>()
        borderWalls = [BorderWallObject]()
        goalSections  = [GoalObject]()
        arenaFloor = SKShapeNode()
        floorPath = []
        
        leftPlayer = SKSpriteNode()
        rightPlayer = SKSpriteNode()
        puck = SKSpriteNode()
        middleLine = SKSpriteNode()
        
        super.init(coder: aDecoder)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx:0,dy:0)
        reloadMap()
    }
    
    override func update(_ currentTime: TimeInterval) {
        //super.update(currentTime)
        playMode.update(currentTime)
        
    }
    
    func runTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer(){
        if(!isInPause){
            seconds += 1
            if (timeLabel != nil){
                timeLabel.text = timeString(TimeInterval(seconds))
            }
        }
    }
    
    func resetTimer() {
        if (timeLabel != nil){
            gameTimer.invalidate()
            seconds = 0
            timeLabel.text = timeString(TimeInterval(seconds))
        }
    }
    
    func timeString(_ time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func togglePause(){
        if (isInPause){
            gameTimer.fire()
        }
        else{
            gameTimer.invalidate()
        }
        isInPause = !isInPause
        self.isPaused = isInPause
    }
    
    
    public func reloadMap(){
        gameTimer.invalidate()
        playersCanMove = false;
        removeAllChildren()
        addArena()
        addGameObjects()
        //removeAllActions();
        leftPlayer = PlayModeUtils.initPlayer(borderWalls,true, frictionCoeff, restitutionCoeff)
        rightPlayer = PlayModeUtils.initPlayer(borderWalls,false, frictionCoeff, restitutionCoeff)
        puck = PlayModeUtils.initPuck(frictionCoeff, restitutionCoeff)
        middleLine = PlayModeUtils.initMiddleLine(borderWalls)
        
        addChild(leftPlayer)
        addChild(rightPlayer)
        addChild(puck)
        addChild(middleLine)
        restart()
    }
    
    public func addArena(){
        addChild(arenaFloor)
        addChild(PlayModeUtils.initFloor(floorPath, frictionCoeff))
        
        for borderWall in borderWalls {
            //let paddleWall = GameObjectFactory.createBorderWallObjectFromPoints(borderWall.startPoint, borderWall.endPoint)
            //PlayModeUtils.setPaddleBorderWallPhysics(paddleWall)
            PlayModeUtils.setBorderWallPhysics(borderWall, frictionCoeff, restitutionCoeff)
            
            //addChild(paddleWall)
            addChild(borderWall)
        }
        
        for goalSegment in goalSections{
            PlayModeUtils.setGoalPhysics(goalSegment)
            addChild(goalSegment)
            if (effectsEnabled){
                PlayModeUtils.animateDarkClear(goalSegment)
                let lightNode : SKLightNode = PlayModeUtils.createLightNode()
                lightNode.zPosition = 5
                addChild(lightNode)
            }
        }
    }
    
    public func addGameObjects(){
        for editableItem in editableItems{
            if editableItem is PortalObject {
                let portal = editableItem as! PortalObject
                PlayModeUtils.setPortalPhysics(portal)
                portal.findAndSetLinkPortal(editableItems)
                portal.colorBlendFactor = 5
                portal.color = .clear
                animatePortal(portal)
            }
            else if editableItem is AcceleratorObject {
                PlayModeUtils.setAcceleratorPhysics(editableItem as! AcceleratorObject)
            }
            else if editableItem is WallObject {
                PlayModeUtils.setWallPhysics(editableItem as! WallObject, frictionCoeff, restitutionCoeff)
            }
            addChild(editableItem)
        }
    }
    
    func restart(){
        gameTimer.invalidate()
        puck.removeAllActions()
        puck.physicsBody?.velocity = CGVector(dx:0, dy:0)
        repositionToDefault()
        // Reset actions for animations
        resetActions()
        addAnimations()
        //puck.physicsBody?.applyImpulse(generateRandomImpulse())
        resetScore()
        resetTimer()
        self.isPaused = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.gameTimer.invalidate()
            self.playersCanMove = true
            self.runTimer()
        }
    }
    public func resetActions(){
        for node in children{
            node.removeAllActions()
        }
    }
    
    public func addAnimations(){
        PlayModeUtils.animateDarkClear(leftPlayer)
        PlayModeUtils.animateDarkClear(rightPlayer)
        
        for node in editableItems{
            if node is PortalObject {
                animatePortal(node as! PortalObject)
            }
        }
        
        for goal in goalSections {
            PlayModeUtils.animateDarkClear(goal)
        }
        
    }
    
    
    
    public func handleGoal(_ fromLeftPlayer : Bool){
        if (!canScoreGoal){
            playersCanMove = false
            SoundManager.playGoalPoint();
            if( fromLeftPlayer){
                lpScoreValue += 1
                lpScore.text = lpScoreValue.description
            }
            else {
                rpScoreValue += 1
                rpScore.text = rpScoreValue.description
            }
            
            if (!isTestMode){
                if lpScoreValue >= goalLimit {
                    winGame(true);
                }
                else if (rpScoreValue >= goalLimit) {
                    winGame(false);
                }
            }
            
            repositionToDefault()
            puck.physicsBody?.velocity = CGVector(dx:0, dy:0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.playersCanMove = true;
                self.canScoreGoal = true;
            }
        }
    }
    
    public func winGame (_ isLeftPlayerwinner : Bool) {
        SoundManager.playVictory();
        gameTimer.invalidate()
        self.isPaused = true
        
        var winnerName : String = rpName.text!
        if (isLeftPlayerwinner) {
            winnerName = lpName.text!
        }

        let alert = UIAlertController(title: ("Victoire de " + winnerName), message: "Voulez-vous recommencer une nouvelle partie ou retourner au menu principal ?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Quitter", style: UIAlertActionStyle.default, handler: {action in
            self.controller?.goBackFromOtherPlace()
        }))
        alert.addAction(UIAlertAction(title: "Recommencer", style: UIAlertActionStyle.cancel, handler: {action in
            self.restart()
        }))
        
        // show the alert
        controller?.present(alert, animated: true, completion: nil)
        
        print("Winner is " + winnerName)
    }
    
    func resetScore(){
        if (lpScore != nil && rpScore != nil){
            lpScoreValue = 0
            rpScoreValue = 0
            lpScore.text = lpScoreValue.description
            rpScore.text = rpScoreValue.description
        }
    }
    
    func repositionToDefault(){
        if (borderWalls.count > 1){
            puck.position = CGPoint(x:0,y:0)
            let halfwayPoint : CGFloat = (abs(borderWalls[0].endPoint.x))/2
            leftPlayer.position = CGPoint(x:-halfwayPoint, y:0)
            rightPlayer.position = CGPoint(x:halfwayPoint, y:0)
        }
    }
    
    func generateRandomImpulse() -> CGVector{
        // Not quite for now :(
        return CGVector(dx: 1000*2, dy: 1000*2)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        playMode.didBegin(contact)
    }
    
    func setPhysicsModifiers(_ friction : CGFloat, _ restitution : CGFloat, _ acceleration : CGFloat) {
        frictionCoeff = friction
        restitutionCoeff =  restitution
        accellerationCoeff = acceleration
    }
    
    func animatePortal(_ portal : PortalObject){
        
        let makeDarker = SKAction.colorize(with: UIColor.red, colorBlendFactor: 0.2, duration: 2)
        let makePaler = SKAction.colorize(with: UIColor.blue, colorBlendFactor: 0.2, duration: 2)
        let shrink = SKAction.scale(to: portal.xScale - 0.07, duration: 2)
        let grow = SKAction.scale(to: portal.xScale + 0.07, duration: 2)
        
        let colorSequence = SKAction.sequence([makeDarker,makePaler])
        let scaleSequence = SKAction.sequence([shrink,grow])
        
        portal.run(SKAction.repeatForever(colorSequence))
        portal.run(SKAction.repeatForever(scaleSequence))
        
    }
    
}
