//
//  EditionModeUtils.swift
//  clientLeger
//
//  Created by Marco on 2017-10-08.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import AEXML

class EditionModeUtils {
    
    // Morph points
    static let MP_LEFTBOTTOM : Int = 0
    static let MP_LEFTMID : Int = 1
    static let MP_LEFTTOP : Int = 2
    static let MP_CENTERTOP : Int = 3
    static let MP_RIGHTTOP : Int = 4
    static let MP_RIGHTMID : Int = 5
    static let MP_RIGHTBOTTOM : Int = 6
    static let MP_CENTERBOTTOM : Int = 7
    // Goal parts
    static let GP_LEFTBOTTOM : Int = 0
    static let GP_LEFTTOP : Int = 1
    static let GP_RIGHTOTTOM : Int =  2
    static let GP_RIGHTTOP : Int = 3
    // Arena
    static let ARENAGEOMETRYSIZE : Int = 10
    static let GOALHEIGHT : CGFloat = 35
    static let DEFAULTARENASIZE : Float = 300
    
    static func updateSelectionFromPoint(editScene:EditionModeScene, pointCoord:CGPoint){
        for node in editScene.editableItems{
            if (node.contains(pointCoord) && node.isSelectionEnabled()){
                SocketIOManager.sharedInstance.askForSelection(node.id, OnlineEditionModeController.mapName) { () -> Void in
                   editScene.selectedItems.insert(node);
                }
            }
        }
        // Delay action if online, maybe this is a hack...
        if (SocketIOManager.sharedInstance.isConnected()) {
            let mainQueue = DispatchQueue.main;
            let deadLine = DispatchTime.now() + .milliseconds(400);
            mainQueue.asyncAfter(deadline: deadLine) {
                addSelectedVisualEffectTemp(editScene: editScene);
            }
        } else {
            addSelectedVisualEffectTemp(editScene: editScene);
        }
        
        
    }
    
    // Function called when online, when another user selects an object
    // We need to change the node as if selected but we mustnt be able to select it
    static func updateSelectionFromNodeId(editScene:EditionModeScene, id:Int) {
        for node in editScene.editableItems{
            if (node.id == id){
                node.addGlow();
                // TODO: THIS ISNT CORRECT, PLACEHOLDER FOR NOW
            }
        }
    }
    
    // When the server tells us that a user has deselected a node
    static func removeSelectionFromNodeId(editScene:EditionModeScene, id:Int) {
        for node in editScene.editableItems{
            if (node.id == id){
                node.removeGlow();
                // TODO: THIS ISNT CORRECT, PLACEHOLDER FOR NOW
            }
        }
    }
    
    static func updateNodeFromId(editScene:EditionModeScene, id:Int, posX:CGFloat,posY:CGFloat,angle:CGFloat,scale:CGFloat) {
        for node in editScene.editableItems{
            if (node.id == id){
                node.position.x = posX;
                node.position.y = posY;
                node.zRotation = angle;
                node.xScale = scale;
                node.yScale = scale;
                print("From online, updated node with id: " + String(id));
            }
        }
    }
    
    static func updateSelectionFromBox(editScene:EditionModeScene, selectionBox:SKSpriteNode){
        for node in editScene.editableItems{
            if (node.intersects(selectionBox) && node.isSelectionEnabled()){
                SocketIOManager.sharedInstance.askForSelection(node.id, OnlineEditionModeController.mapName) { () -> Void in
                    editScene.selectedItems.insert(node);
                }
            }
        }
        // Delay action if online, maybe this is a hack...
        if (SocketIOManager.sharedInstance.isConnected()) {
            let mainQueue = DispatchQueue.main;
            let deadLine = DispatchTime.now() + .milliseconds(400);
            mainQueue.asyncAfter(deadline: deadLine) {
                addSelectedVisualEffectTemp(editScene: editScene);
            }
        } else {
            addSelectedVisualEffectTemp(editScene: editScene);
        }
    }
    
    static func getNodeFromId(editScene:EditionModeScene,id: Int) ->  GameObject? {
        for node in editScene.editableItems {
            if (node.id == id) {
                return node;
            }
        }
        return nil;
    }
    
    static func wallWithPositionAlreadyExists(editScene:EditionModeScene,startX:CGFloat,startY:CGFloat,endX:CGFloat,endY:CGFloat) -> Bool {
        print("There are currently " + editScene.editableItems.count.description + " items to check");
        for node in editScene.editableItems{
            if (node is WallObject) {
                let wall: WallObject = node as! WallObject;
                if (Int(wall.startPoint.x) == Int(startX) && Int(wall.startPoint.y) == Int(startY) &&
                    Int(wall.endPoint.x)   == Int(endX)   && Int(wall.endPoint.y)   == Int(endY)) {
                    return true;
                } else {
                    print("still not equal");
                }
            }
        }
        return false;
    }
    
    static func addSelectedVisualEffectTemp(editScene:EditionModeScene){
        for node in editScene.selectedItems{
            node.addGlow()
            print("Selected Item at (" + node.position.x.description + "," + node.position.y.description + ") has been selected");
        }
    }
    
    static func removeSelectedVisualEffectTemp(editScene:EditionModeScene){
        for node in editScene.selectedItems{
            node.removeGlow();
            print("Selected Item at (" + node.position.x.description + "," + node.position.y.description + ") has been removed from the selection");
        }
    }
    
    static func clearSelection(editScene:EditionModeScene){
        //TODO swap Temp to normal once sprites are there
        SocketIOManager.sharedInstance.deselectObjects(OnlineEditionModeController.mapName) { () -> Void in
            removeSelectedVisualEffectTemp(editScene:editScene)
            editScene.selectedItems.removeAll();
        }
        
    }
    
    public static func getCenterOfMass(_ selectedItems: Set<GameObject>) -> CGPoint {
        var centerOfMass: CGPoint = CGPoint();
        centerOfMass.x = 0;
        centerOfMass.y = 0;
        for object in selectedItems {
            centerOfMass.x += object.position.x;
            centerOfMass.y += object.position.y;
        }
        let count: CGFloat = CGFloat(selectedItems.count);
        centerOfMass.x = centerOfMass.x/count;
        centerOfMass.y = centerOfMass.y/count;
        
        print("Center of selection is at (" + centerOfMass.x.description + "," + centerOfMass.y.description + ") from " + count.description + " objects");
        return centerOfMass;
    }
    
    
    public static func isOutsideBoundaries(_ selectedItem: GameObject, _ editScene : EditionModeScene) -> Bool {
        
        let floor : SKShapeNode =  editScene.arenaFloor
        
        // On the floor
        if (floor.path?.contains(selectedItem.position))!{
            //Doesnt touch the walls
            print(selectedItem.debugDescription)
            for boundaryWall in editScene.borderWalls {
                if (selectedItem.intersects(boundaryWall)) {
                    print(selectedItem.debugDescription)
                    return true;
                }
            }
            return false;
        }
        else {
            return true;
        }
    }
    
    public static func isOutsideBoundaries(_ selectedItems: Set<GameObject>, _ editScene : EditionModeScene) -> Bool {
        // TODO boundaries are hard coded now, must be changed later on
        for object in selectedItems {
            if (EditionModeUtils.isOutsideBoundaries(object, editScene)){
                return true
            }
        }
        return false;
    }
    
    public static func isOutsideBoundaries(_ selectedItems: Array<GameObject>) -> Bool {
        // TODO boundaries are hard coded now, must be changed later on
        let xMin: CGFloat = CGFloat(-130);
        let xMax: CGFloat = CGFloat(150);
        let yMin: CGFloat = CGFloat(-140);
        let yMax: CGFloat = CGFloat(135);
        for object in selectedItems {
            let x = object.position.x;
            let y = object.position.y;
            if (x <= xMin || x >= xMax || y <= yMin || y >= yMax) {
                return true;
            }
        }
        return false;
    }
    
    public static func isCollidingWithGameObjects(_ testItem : GameObject, _ editableItems: Set<GameObject>) -> Bool {
        for object in editableItems {
            if (testItem !== object && testItem.intersects(object)){
                return true;
            }
        }
        return false;
    }
    
    public static func isCollectionCollidingWithGameObjects(_ testItems : Set<GameObject>, _ editableItems: Set<GameObject>) -> Bool {
        for item in testItems{
            if (isCollidingWithGameObjects(item, testItems)){
                return true;
            }
        }
        return false;
    }
    
    public static func canPlaceItem(_ testItem : GameObject, _ editScene : EditionModeScene) -> Bool {
        
        let editableItems = editScene.editableItems
        if (EditionModeUtils.isOutsideBoundaries(testItem, editScene)){
            print("‼️Cannot place Item, Object is out of boundaries");
            return false;
        }
        /* Keeping it close just in case...
        else if (isCollidingWithGameObjects(testItem, editableItems)){
            print("‼️Cannot place Item, Object colliding with another");
            return false;
        }
         */
        //.
        return true;
    }
    
    public static func canPlaceAllItems(_ testItems : Set<GameObject>, _ editScene : EditionModeScene) -> Bool{
        for item in testItems{
            if (!EditionModeUtils.canPlaceItem(item, editScene)){
                SoundManager.playCantPlaceThere();
                return false;
            }
        }
        return true;
    }
    
    public static func setupBackup(_ selectedItems : Set<GameObject>){
        for item in selectedItems{
            item.setUpBackup()
        }
    }
    
    public static func restoreBackup(_ selectedItems : Set<GameObject>){
        for item in selectedItems{
            item.restoreBackup()
        }
        print("‼️Objects reverted back to their previous State");
    }
    
    public static func resetBackup(_ selectedItems : Set<GameObject>){
        for item in selectedItems{
            item.resetBackup()
        }
    }
    
    // Bit unorthodox...
    public static func positionBetween(_ begin: CGPoint, _ end: CGPoint) -> CGPoint {
        let xDist = end.x - begin.x
        let yDist = end.y - begin.y
        return CGPoint(x:begin.x + (xDist/2), y:begin.y + (yDist/2))
    }
    
    public static func distanceBetween(_ begin: CGPoint, _ end: CGPoint) -> CGFloat {
        let xDist = end.x - begin.x
        let yDist = end.y - begin.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    public static func angleBetween(_ begin: CGPoint, _ end: CGPoint) -> CGFloat {
        let xDist : CGFloat = end.x - begin.x
        let yDist : CGFloat = end.y - begin.y
        
        let absX : CGFloat = abs(xDist)
        let absY : CGFloat = abs(yDist)
        
        var angleBeforeAdjustment  : CGFloat = atan(absY/absX)
        //print("Angle before adjustment = " + angleBeforeAdjustment.description);
        
        var quadrantAdjustment : CGFloat = 0
        
        if (xDist >= 0 && yDist >= 0){
            quadrantAdjustment = 0
        //    print("Quadrant 1 = +" + quadrantAdjustment.description);
        }
        else if (xDist <= 0 && yDist >= 0){
            angleBeforeAdjustment = atan(absX/absY)
            quadrantAdjustment = CGFloat.pi/2
        //    print("Quadrant 2 = +" + quadrantAdjustment.description);
        }
        else if (xDist <= 0 && yDist <= 0){
            quadrantAdjustment = CGFloat.pi
        //    print("Quadrant 3 = +" + quadrantAdjustment.description);
        }
        else if (xDist >= 0 && yDist <= 0){
            angleBeforeAdjustment = atan(absX/absY)
            quadrantAdjustment = 3*CGFloat.pi/2
        //    print("Quadrant 4 = +" + quadrantAdjustment.description);
        }
        
        return angleBeforeAdjustment + quadrantAdjustment
    }
    
    public static func adjustWallNodePosition(_ wallNode : WallObject, _ currentEndPoint : CGPoint){
        
        wallNode.position = EditionModeUtils.positionBetween(wallNode.startPoint, currentEndPoint)
        
        let angle = EditionModeUtils.angleBetween(wallNode.startPoint, currentEndPoint)
        wallNode.absoluteAngle = angle
        
        wallNode.size.height = EditionModeUtils.distanceBetween(wallNode.startPoint, currentEndPoint)
        
        wallNode.endPoint = currentEndPoint
        wallNode.adjustRotationFromAbsAngle()
    }
    
    public static func adjustWallNodePosition(_ wallNode : WallObject){
        
        wallNode.position = EditionModeUtils.positionBetween(wallNode.startPoint, wallNode.endPoint)
        
        let angle = EditionModeUtils.angleBetween(wallNode.startPoint, wallNode.endPoint)
        wallNode.absoluteAngle = angle
        
        wallNode.size.height = EditionModeUtils.distanceBetween(wallNode.startPoint, wallNode.endPoint)
        
        wallNode.adjustRotationFromAbsAngle()
    }
    
    public static func getArenaFloorDefaultValuesArray(_ size : Int = Int(DEFAULTARENASIZE)) -> [CGPoint]{
        let halfsize : Int = size/2
        var morphPointArray : [CGPoint] = [CGPoint]()
        morphPointArray.append(CGPoint(x:-halfsize,y:-halfsize))    //0
        morphPointArray.append(CGPoint(x:-halfsize,y:0))            //1
        morphPointArray.append(CGPoint(x:-halfsize,y:halfsize))     //2
        morphPointArray.append(CGPoint(x:0,y:halfsize))             //3
        morphPointArray.append(CGPoint(x:halfsize,y:halfsize))      //4
        morphPointArray.append(CGPoint(x:halfsize,y:0))             //5
        morphPointArray.append(CGPoint(x:halfsize,y:-halfsize))     //6
        morphPointArray.append(CGPoint(x:0,y:-halfsize))            //7
        return morphPointArray;
    }
    
    public static func getArenaFloorDefaultValuesArrayForClientLourd(_ size : Int = Int(DEFAULTARENASIZE)) -> [CGPoint]{
        let halfsize : Int = size/2
        // let halfsize: Int = 60;
        var morphPointArray : [CGPoint] = [CGPoint]()
        morphPointArray.append(CGPoint(x: -halfsize,y: -halfsize))    //0
        morphPointArray.append(CGPoint(x: -halfsize,y:0))            //1
        morphPointArray.append(CGPoint(x: -halfsize,y:halfsize))     //2
        morphPointArray.append(CGPoint(x:0,y: halfsize))             //3
        morphPointArray.append(CGPoint(x:halfsize,y:halfsize))      //4
        morphPointArray.append(CGPoint(x:halfsize,y:0))             //5
        morphPointArray.append(CGPoint(x:halfsize,y:-halfsize))     //6
        morphPointArray.append(CGPoint(x:0,y:-halfsize))            //7
        return morphPointArray;
    }
    
    public static func createMorphNodes(_ morphPointCoords:[CGPoint] = EditionModeUtils.getArenaFloorDefaultValuesArrayForClientLourd()) -> [MorphPointObject]{
        var morphNodes = [MorphPointObject]()
        
        // Fetch positions from scene and create points
        for i in 0...(morphPointCoords.count-1) {
            morphNodes.append(MorphPointObject(morphPointCoords[i], i)!)
        }
        return morphNodes
    }
    
    // AKA Trump mode !
    public static func createBorderWalls(_ morphPointCoords:[CGPoint] = EditionModeUtils.getArenaFloorDefaultValuesArray()) -> [BorderWallObject]{
        var borderWalls = [BorderWallObject]()
        for i in 0...(morphPointCoords.count-2){
            let newWall : BorderWallObject = GameObjectFactory.createBorderWallObjectFromPoints(morphPointCoords[i], morphPointCoords[i+1])
            borderWalls.append(newWall)
        }
        //Add closing wall..
        let closingWall : BorderWallObject = GameObjectFactory.createBorderWallObjectFromPoints(morphPointCoords[7], morphPointCoords[0])
        borderWalls.append(closingWall)
        
        return borderWalls
    }
    
    public static func createGoals(_ borderWallArray : [BorderWallObject]) -> [GoalObject]{
        var goalSections : [GoalObject] = [GoalObject]()
        // Bottom left wall, bwInd = 0, goal Index=  0, needs to be reversed
        goalSections.append(GameObjectFactory.createGoalFromBorderWall(borderWallArray[0], true))
        // Top left wall, bwInd = 1, goal Index=  1
        goalSections.append(GameObjectFactory.createGoalFromBorderWall(borderWallArray[1]))
        // Top right wall, bwInd = 4, goal Index =2, needs to be reversed
        goalSections.append(GameObjectFactory.createGoalFromBorderWall(borderWallArray[4], true))
        // Bottom right wall, bwInd = 5, goal Index = 3
        goalSections.append(GameObjectFactory.createGoalFromBorderWall(borderWallArray[5]))
        return goalSections
    }
    
    public static func adjustGoalFromBorderWall(_ borderWall : BorderWallObject , _ goal : GoalObject){
        
        if (!goal.reverseEndpoints){
            goal.startPoint = borderWall.startPoint
            goal.endPoint = borderWall.endPoint
        }
        else{
            goal.startPoint = borderWall.endPoint
            goal.endPoint = borderWall.startPoint
        }
        goal.absoluteAngle = EditionModeUtils.angleBetween(goal.startPoint, goal.endPoint)
        goal.adjustRotationFromAbsAngle()
        
        goal.size.height = EditionModeUtils.GOALHEIGHT
        goal.anchorPoint = CGPoint(x: 0.5 , y: 0)
        goal.position = goal.startPoint
    }
    
    public static func adjustGoalOnItsOwn(_ goal: GoalObject){
        goal.absoluteAngle = EditionModeUtils.angleBetween(goal.startPoint, goal.endPoint)
        goal.adjustRotationFromAbsAngle()
        
        goal.size.height = EditionModeUtils.GOALHEIGHT
        goal.anchorPoint = CGPoint(x: 0.5 , y: 0)
        goal.position = goal.startPoint
    }
    
    public static func updateMorphPointCoords(_ coords : CGPoint, _ index : Int, _ editScene: EditionModeScene){
        editScene.morphPoints[index].position = coords
        
        let startPointWallIndex : Int = index
        var endPointWallIndex : Int = (index - 1)
        if (endPointWallIndex == -1){
            endPointWallIndex = 7
        }
        
        editScene.borderWalls[startPointWallIndex].startPoint = coords
        editScene.borderWalls[endPointWallIndex].endPoint = coords
        EditionModeUtils.adjustWallNodePosition(editScene.borderWalls[startPointWallIndex])
        EditionModeUtils.adjustWallNodePosition(editScene.borderWalls[endPointWallIndex])
        
        editScene.refreshFloor()
    }
    
    public static func adjustGoals(_ editScene: EditionModeScene){
        EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[0], editScene.goalSections[0])
        EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[1], editScene.goalSections[1])
        EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[4], editScene.goalSections[2])
        EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[5], editScene.goalSections[3])
    }
    
    public static func showErrorMessage(_ message: String, _ controller: UIViewController, _ windowTitle : String = "Error") {
        let alertController = UIAlertController(title: windowTitle, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default);
        alertController.addAction(OKAction);
        controller.present(alertController, animated: true, completion: nil)
    }
    
    public static func loadMap(_ xmlDoc: AEXMLDocument) -> EditionModeScene {
        // Clear current map
        let scene: EditionModeScene = EditionModeScene();
        scene.clearScene();
        print("Loading this map:");
        print(xmlDoc.xml)
        let planche = xmlDoc.root["planche"];
        var pointArray = [CGPoint](repeating: CGPoint(), count:8); // NumberFormatter().number(from: xmlElem.attributes["e_0_s"]!) as! CGFloat;
        let coinInfDx = NumberFormatter().number(from: planche.attributes["coinInfDX"]!) as! CGFloat;
        let coinInfDy = NumberFormatter().number(from: planche.attributes["coinInfDY"]!) as! CGFloat;
        let axeHoriDx = NumberFormatter().number(from: planche.attributes["axeHoriDX"]!) as! CGFloat;
        let coinSupDx = NumberFormatter().number(from: planche.attributes["coinSupDX"]!) as! CGFloat;
        let coinSupDy = NumberFormatter().number(from: planche.attributes["coinSupDY"]!) as! CGFloat;
        let axeVertDy = NumberFormatter().number(from: planche.attributes["axeVertDY"]!) as! CGFloat;
        pointArray[0] = CGPoint(x: -coinInfDx, y: -coinInfDy);
        pointArray[6] = CGPoint(x: coinInfDx, y: -coinInfDy);
        pointArray[1] = CGPoint(x: -axeHoriDx, y: CGFloat(0));
        pointArray[5] = CGPoint(x: axeHoriDx, y: CGFloat(0));
        pointArray[2] = CGPoint(x: -coinSupDx, y: coinSupDy);
        pointArray[4] = CGPoint(x: coinSupDx, y: coinSupDy);
        pointArray[3] = CGPoint(x: CGFloat(0) , y: axeVertDy);
        pointArray[7] = CGPoint(x: CGFloat(0) , y: -axeVertDy);
        // set the scene morph points correctly
        for index in 0 ... pointArray.count-1 {
            EditionModeUtils.updateMorphPointCoords(pointArray[index], index, scene);
        }
        
        // update goal positions
        EditionModeUtils.adjustGoals(scene);
        
        for object in xmlDoc.root["planche"].children {
            print("Loading " + object.attributes["type"]!);
            switch object.attributes["type"] {
            case "portail"?:
                let portal = GameObjectFactory.createPortalObject(object);
                scene.addNode(portal);
            case "accelerateur"?:
                let accel = GameObjectFactory.createAcceleratorObject(object);
                scene.addNode(accel);
            case "mur"?:
                let mur = GameObjectFactory.createWallObject(object);
                scene.addNode(mur);
            default:
                print("Can't find suitable constructor for " + object.attributes["type"]!);
                //case .none: break
                // do nothing
                //case .some(_): break
                // do nothing
            }
        }
        return scene;
    }
    
}


