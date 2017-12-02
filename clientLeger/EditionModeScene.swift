//
//  EditionModeScene.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-01.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import UIKit
import SpriteKit

class EditionModeScene: SKScene {
    
    //Arena related
    var morphPoints : [MorphPointObject]
    var editableItems : Set<GameObject> = []
    var borderWalls : [BorderWallObject]
    var goalSections : [GoalObject]
    
    //Floor related
    var arenaFloor : SKShapeNode
    var floorSize : Float = EditionModeUtils.DEFAULTARENASIZE
    
    //Selection Related
    var selectedItems : Set<GameObject> = []
    
    override init() {
        arenaFloor = SKShapeNode()
        morphPoints = [MorphPointObject]()
        borderWalls = [BorderWallObject]()
        goalSections = [GoalObject]()
        super.init()
        
        // Set morph points to same values as client lourd
       
        
        morphPoints = EditionModeUtils.createMorphNodes()
        
        for morphPoint in morphPoints {
            self.addChild(morphPoint)
        }
        
        borderWalls = EditionModeUtils.createBorderWalls(getPointArrayFromMorphPoints())
        for borderWall in borderWalls {
            self.addChild(borderWall)
        }
        goalSections = createGoals()
        
        arenaFloor = SKShapeNode(path: getPathFromMorphPoints())
        arenaFloor.lineWidth = 5
        arenaFloor.strokeColor = .white
        arenaFloor.fillColor = .lightGray
        self.addChild(arenaFloor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        morphPoints = [MorphPointObject]()
        arenaFloor = SKShapeNode()
        borderWalls = [BorderWallObject]()
        goalSections = [GoalObject]()
        super.init(coder: aDecoder)

        morphPoints = EditionModeUtils.createMorphNodes()
        for morphPoint in morphPoints {
            self.addChild(morphPoint)
        }
        
        borderWalls = EditionModeUtils.createBorderWalls(getPointArrayFromMorphPoints())
        for borderWall in borderWalls {
            self.addChild(borderWall)
        }
        
        goalSections = createGoals()
        for goal in goalSections{
            self.addChild(goal)
        }
        
        arenaFloor = SKShapeNode(path: getPathFromMorphPoints())
        arenaFloor.lineWidth = 5
        arenaFloor.strokeColor = .white
        arenaFloor.fillColor = UIColor(red:0.88, green:0.95, blue:0.96, alpha:1.0)
        self.addChild(arenaFloor)
    }
    
    override init(size: CGSize) {
        morphPoints = [MorphPointObject]()
        arenaFloor = SKShapeNode()
        borderWalls = [BorderWallObject]()
        goalSections = [GoalObject]()
        super.init(size: size);
        
        morphPoints = EditionModeUtils.createMorphNodes()
        for morphPoint in morphPoints {
            self.addChild(morphPoint)
        }
        
        borderWalls = EditionModeUtils.createBorderWalls(getPointArrayFromMorphPoints())
        for borderWall in borderWalls {
            self.addChild(borderWall)
        }
        
        goalSections = createGoals()
        for goal in goalSections{
            self.addChild(goal)
        }
        
        arenaFloor = SKShapeNode(path: getPathFromMorphPoints())
        arenaFloor.lineWidth = 5
        arenaFloor.strokeColor = .white
        arenaFloor.fillColor = UIColor(red:0.88, green:0.95, blue:0.96, alpha:1.0)
        self.addChild(arenaFloor)
    }
    
    // MARK public functions to add and get nodes
    
    public func addNode(_ node: GameObject) {
        self.addChild(node);
        editableItems.insert(node);
        // update current id count
        if (node.id > GameObject.idCount) {
            GameObject.idCount = node.id + 1;
        }
    }
    
    public func addSpriteNode(_ node: SKSpriteNode){
        self.addChild(node);
    }
    
    public func removeSpriteNode(_ node: SKSpriteNode){
        node.removeFromParent();
    }
    
    public func removeNode(_ node: GameObject) {
        selectedItems.remove(node);
        editableItems.remove(node);
        node.removeFromParent()
    }
    
    public func removeNodeWithId(_ id: Int) {
        for object in editableItems {
            if (object.id == id) {
                selectedItems.remove(object);
                editableItems.remove(object);
                object.removeFromParent();
            }
        }
        
    }
    
    public func deleteSelectedNodes() {
        // Make sure the linked portals are in the selection
        for object in selectedItems {
            if (object is PortalObject) {
                if let portal:Optional = (object as! PortalObject) {
                    if (!selectedItems.contains((portal?.linkedPortal)!)) {
                        selectedItems.insert((portal?.linkedPortal)!);
                    }
                }
            }
            
        }
        for object in selectedItems {
            if (SocketIOManager.sharedInstance.isConnected()){
                SocketIOManager.sharedInstance.deleteObjectOnline(mapName: OnlineEditionModeController.mapName, id: object.id.description);
            } else {
                selectedItems.remove(object);
                editableItems.remove(object);
                object.removeFromParent();
            }
        }
    }
    
    public func makeMorphPointsVisible(_ bool : Bool){
        for node in morphPoints {
            node.isHidden = !bool
        }
        if (SocketIOManager.sharedInstance.isConnected()) {
            SocketIOManager.sharedInstance.deselectMorphPoints();
        }
    }
    
    public func getPointArrayFromMorphPoints() -> [CGPoint]{
        var pointArray : [CGPoint] = [CGPoint]()
        for i in 0...(morphPoints.count-1) {
            pointArray.append(morphPoints[i].position)
        }
        return pointArray
    }
    
    public func clearScene() {
        for object in editableItems {
            object.removeFromParent();
        }
        selectedItems.removeAll();
        GameObject.resetGameIdCount();
        editableItems.removeAll();
    }

    private func getPathFromMorphPoints()->CGMutablePath{
        var pointArray : [CGPoint] = getPointArrayFromMorphPoints()
        pointArray.append(pointArray[0])
        
        let path = CGMutablePath()
        path.addLines(between: pointArray)
        path.closeSubpath()
        
        return path
    }
    
    public func refreshFloor(){
        arenaFloor.removeFromParent()
        arenaFloor = SKShapeNode(path: getPathFromMorphPoints())
        arenaFloor.lineWidth = 5
        arenaFloor.strokeColor = .white
        arenaFloor.fillColor = UIColor(red:0.88, green:0.95, blue:0.96, alpha:1.0)
        self.addChild(arenaFloor)
    }
    
    private func createGoals() -> [GoalObject]{
        return EditionModeUtils.createGoals(borderWalls)
    }
    
    
}
