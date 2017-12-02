//
//  GameObjectFactory.swift
//  clientLeger
//
//  Created by Marco on 2017-10-26.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit
import AEXML

//Still Need to check if it can be placed before adding to the scene, this ignores the boundaries
class GameObjectFactory {
    
    public static func createPortalObject(_ x : CGFloat, _ y : CGFloat , _ firstPortal: Bool = true) -> PortalObject{
        // TODO adjust link and first portal thingy
        let portal : PortalObject = PortalObject(firstPortal)
        portal.firstPortal = firstPortal
        portal.position = CGPoint(x:x,y:y)
        return portal;
    }
    
    public static func createPortalObject(_ x : CGFloat, _ y : CGFloat , _ firstPortal: Bool = true, _ angle: CGFloat, _ scale: CGFloat) -> PortalObject{
        // TODO adjust link and first portal thingy
        let portal : PortalObject = PortalObject(firstPortal)
        portal.firstPortal = firstPortal
        portal.position = CGPoint(x:x,y:y)
        portal.zRotation = angle;
        portal.xScale = scale;
        portal.yScale = scale;
        return portal;
    }
    
    public static func createPortalObject(_ xmlElem: AEXMLElement) -> PortalObject{
        // TODO adjust link and first portal thingy
        let portal : PortalObject = PortalObject(true)
        GameObject.idCount -= 1;
        // convert scale back from client lourd spec
        var scale: CGFloat = NumberFormatter().number(from: xmlElem.attributes["e_0_s"]!) as! CGFloat;
        scale = GameObject.convertScaleLourdToLeger(scale);
        print("Scale: " + scale.description);
        let x: CGFloat = NumberFormatter().number(from: xmlElem.attributes["p_3_s"]!) as! CGFloat;
        let y: CGFloat = NumberFormatter().number(from: xmlElem.attributes["p_3_t"]!) as! CGFloat;
        print("Position: (" + x.description + "," + y.description + ")" );
        // Not yet aure about the rotation
        var rotation: CGFloat = NumberFormatter().number(from: xmlElem.attributes["r_0_s"]!) as! CGFloat;
        rotation = GameObject.convertR0SLourdsToLeger(rotation);
        print("Rotation: " + rotation.description);
        let id: Int = Int(xmlElem.attributes["id"]!)!;
        let friendId: Int = Int(xmlElem.attributes["frereId"]!)!;
        // Now we set the correct values
        portal.xScale = scale;
        portal.yScale = scale;
        portal.position = CGPoint(x:x,y:y)
        portal.zRotation = rotation;
        portal.id = id;
        portal.linkedPortalId = friendId;
        return portal;
    }
    
    public static func createAcceleratorObject(_ x : CGFloat, _ y : CGFloat) -> AcceleratorObject{
        let accelerator : AcceleratorObject = AcceleratorObject()!
        accelerator.position = CGPoint(x:x,y:y)
        return accelerator
    }
    
    public static func createAcceleratorObject(_ xmlElem: AEXMLElement) -> AcceleratorObject{
        let accelerator : AcceleratorObject = AcceleratorObject()!
        GameObject.idCount -= 1;
        var scale: CGFloat = NumberFormatter().number(from: xmlElem.attributes["e_0_s"]!) as! CGFloat;
        scale = GameObject.convertScaleLourdToLeger(scale);
        print("Scale: " + scale.description);
        let x: CGFloat = NumberFormatter().number(from: xmlElem.attributes["p_3_s"]!) as! CGFloat;
        let y: CGFloat = NumberFormatter().number(from: xmlElem.attributes["p_3_t"]!) as! CGFloat;
        print("Position: (" + x.description + "," + y.description + ")" );
        // Not yet aure about the rotation
        var rotation: CGFloat = NumberFormatter().number(from: xmlElem.attributes["r_0_s"]!) as! CGFloat;
        rotation = GameObject.convertR0SLourdsToLeger(rotation);
        print("Rotation: " + rotation.description);
        let id: Int = Int(xmlElem.attributes["id"]!)!;
        // Now we set the correct values
        accelerator.xScale = scale;
        accelerator.yScale = scale;
        accelerator.position = CGPoint(x:x,y:y)
        accelerator.zRotation = rotation;
        accelerator.id = id;
        return accelerator
    }
    
    public static func createWallObject(_ x : CGFloat, _ y : CGFloat) -> WallObject{
        let wall : WallObject = WallObject()!
        wall.position = CGPoint(x:x, y:y)
        return wall
    }
    
    public static func createWallObject(_ xmlElem: AEXMLElement) -> WallObject{
        let wall : WallObject = WallObject()!
        GameObject.idCount -= 1;
        var scaleX: CGFloat = 1;
        if let possibleScale = NumberFormatter().number(from: (xmlElem.attributes["e_0_s"])!) as? CGFloat {
            scaleX = possibleScale;
        }
        scaleX = GameObject.convertScaleLourdToLeger(scaleX);
        var scaleY: CGFloat = NumberFormatter().number(from: xmlElem.attributes["e_1_t"]!) as! CGFloat;
        scaleY = GameObject.convertScaleLourdToLeger(scaleY);
        let height: CGFloat = NumberFormatter().number(from: xmlElem.attributes["e_2_p"]!) as! CGFloat;
        let x: CGFloat = NumberFormatter().number(from: xmlElem.attributes["p_3_s"]!) as! CGFloat;
        let y: CGFloat = NumberFormatter().number(from: xmlElem.attributes["p_3_t"]!) as! CGFloat;
        print("Position: (" + x.description + "," + y.description + ")" );
        // Not yet aure about the rotation
        var rotation: CGFloat = NumberFormatter().number(from: xmlElem.attributes["r_0_s"]!) as! CGFloat;
        rotation = GameObject.convertR0SLourdsToLeger(rotation);
        print("Rotation: " + rotation.description);
        let id: Int = Int(xmlElem.attributes["id"]!)!;
        // Now we set the correct values
        wall.xScale = scaleX;
        wall.yScale = scaleY;
        wall.size.height = height;
        wall.position = CGPoint(x:x,y:y)
        wall.zRotation = rotation;
        wall.id = id;
        return wall;
    }
    
    // Probably in the future ?
    public static func createWallObject(_ x : CGFloat, _ y : CGFloat, _ rotationAngle : CGFloat, _ height :CGFloat) -> WallObject{
        let wall : WallObject = WallObject()!
        wall.position = CGPoint(x:x,y:y)
        wall.zRotation = rotationAngle
        wall.size.height = height;
        return wall
    }
    
    public static func createWallObjectFromPoints(_ startPoint : CGPoint, _ endPoint : CGPoint) -> WallObject{
        let wallNode : WallObject = WallObject()!
        wallNode.startPoint = startPoint
        EditionModeUtils.adjustWallNodePosition(wallNode, endPoint)
        return wallNode
    }
    
    public static func createBorderWallObjectFromPoints(_ startPoint : CGPoint, _ endPoint : CGPoint) -> BorderWallObject{
        let wallNode : BorderWallObject = BorderWallObject()!
        wallNode.startPoint = startPoint
        EditionModeUtils.adjustWallNodePosition(wallNode, endPoint)
        return wallNode
    }
    
    public static func createGoalFromBorderWall(_ borderWall : BorderWallObject , _ reverseDirection : Bool  = false) -> GoalObject{
        let goal : GoalObject = GoalObject()!
        goal.reverseEndpoints = reverseDirection
        EditionModeUtils.adjustGoalFromBorderWall(borderWall, goal)
        return goal
    }
    
    public static func copyGoal(_ goalObject : GoalObject, _ keepOldId : Bool = false) -> GoalObject{
        let goal : GoalObject = GoalObject()!
        if keepOldId {
            goal.id = goalObject.id
        }
        goal.reverseEndpoints = goalObject.reverseEndpoints
        goal.startPoint = goalObject.startPoint
        goal.endPoint = goalObject.endPoint
        EditionModeUtils.adjustGoalOnItsOwn(goal)
        return goal
    }
    
    public static func copyPotal(_ oldPortal : PortalObject, _ keepOldId : Bool = false) -> PortalObject{
        let newPortal = createPortalObject(oldPortal.position.x, oldPortal.position.y, oldPortal.firstPortal)
        if keepOldId {
            newPortal.id = oldPortal.id
        }
        newPortal.size = oldPortal.size
        newPortal.zRotation = oldPortal.zRotation
        newPortal.linkedPortalId = oldPortal.linkedPortalId
        return newPortal
    }
    
    public static func copyAccelerator(_ oldAccelerator : AcceleratorObject, _ keepOldId : Bool = false) -> AcceleratorObject{
        let newAccelerator = createAcceleratorObject(oldAccelerator.position.x, oldAccelerator.position.y)
        if keepOldId {
            newAccelerator.id = oldAccelerator.id
        }
        newAccelerator.size = oldAccelerator.size
        newAccelerator.zRotation = oldAccelerator.zRotation
        return newAccelerator
    }
    
    
    
    

    
    
}
