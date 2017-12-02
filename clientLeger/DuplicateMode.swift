//
//  DuplicateMode.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-24.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class DuplicateMode : EditMode {
    var editScene: EditionModeScene;

    
    init(_ scene: EditionModeScene) {
        editScene = scene;
        super.init();
        self.name = "DuplicateMode"
        
        
    }
    
    override func onSingleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        var selectedObjects = editScene.selectedItems;
        // Make sure that all portal links are selected
        for node in editScene.selectedItems {
            if (node is PortalObject) {
                if let portal: Optional = (node as! PortalObject) {
                    let linked = portal?.linkedPortal;
                    if (!selectedObjects.contains(linked!)) {
                        selectedObjects.insert(linked!);
                        print("Added a portal for duplication");
                    }
                }
            }
        }
        // Start by calculating center of mass
        var centerOfMass: CGPoint = CGPoint();
        centerOfMass = EditionModeUtils.getCenterOfMass(selectedObjects);
        // calculate the distance of each object from the center of mass
        var distanceValues: Array<CGPoint> = Array();
        for object in selectedObjects {
            var distancePoint: CGPoint = CGPoint();
            distancePoint.x = object.position.x - centerOfMass.x;
            distancePoint.y = object.position.y - centerOfMass.y;
            distanceValues.append(distancePoint);
        }
        // place objects accordingly
        var i = 0;
        let newPoint: CGPoint = convertScreenCoordinatesToScene(editScene, xCord, yCord);
        // Create a temp set in case the objects are out of bounds
        var duplicatedObjects: Set<GameObject> = Set();
        var alreadyDuplicatedPortals: Set<PortalObject> = Set();
        for object in selectedObjects {
            switch object.name {
                case PortalObject.NAME?:
                    let portalObject: PortalObject = (object as! PortalObject);
                    let friendObject: PortalObject = portalObject.linkedPortal!;
                    if (!alreadyDuplicatedPortals.contains(portalObject) && !alreadyDuplicatedPortals.contains(friendObject)) {
                        let firstDuplicate: PortalObject = PortalObject(portalObject.firstPortal);
                        firstDuplicate.position.x = newPoint.x + distanceValues[i].x;
                        firstDuplicate.position.y = newPoint.y + distanceValues[i].y;
                        duplicatedObjects.insert(firstDuplicate);
                        let secondDuplicate: PortalObject = PortalObject(friendObject.firstPortal);
                        secondDuplicate.position.x = newPoint.x + (friendObject.position.x - centerOfMass.x)
                        secondDuplicate.position.y = newPoint.y + (friendObject.position.y - centerOfMass.y)
                        duplicatedObjects.insert(secondDuplicate);
                        alreadyDuplicatedPortals.insert(portalObject);
                        alreadyDuplicatedPortals.insert(friendObject);
                        // set ids
                        firstDuplicate.linkedPortalId = secondDuplicate.id;
                        firstDuplicate.linkedPortal = secondDuplicate;
                        secondDuplicate.linkedPortalId = firstDuplicate.id;
                        secondDuplicate.linkedPortal = firstDuplicate;
                    }
                
                case AcceleratorObject.NAME?:
                    let temp: AcceleratorObject = AcceleratorObject()!;
                    temp.position.x = newPoint.x + distanceValues[i].x;
                    temp.position.y = newPoint.y + distanceValues[i].y;
                    duplicatedObjects.insert(temp);
                case WallObject.NAME?:
                    let temp: WallObject = GameObjectFactory.createWallObjectFromPoints((object as! WallObject).startPoint, (object as! WallObject).endPoint);
                    temp.position.x = newPoint.x + distanceValues[i].x;
                    temp.position.y = newPoint.y + distanceValues[i].y;
                    temp.zRotation = object.zRotation
                    duplicatedObjects.insert(temp);
            case .none:
                break;
            case .some(_):
                break;
            }
            i += 1;
        }
        // Add the new nodes to the scene if they aren't out of bounds
        if (EditionModeUtils.canPlaceAllItems(duplicatedObjects, editScene)) {
            if (SocketIOManager.sharedInstance.isConnected()) {
                var dontDuplicateAgain: Set<PortalObject> = Set();
                for object in duplicatedObjects {
                    switch object.name {
                    case PortalObject.NAME?:
                        let linked = (object as! PortalObject).linkedPortal;
                        if (!dontDuplicateAgain.contains(object as! PortalObject) && !dontDuplicateAgain.contains(linked!)) {
                            SocketIOManager.sharedInstance.dupPortailsOnline(mapName: OnlineEditionModeController.mapName, posX1: object.position.x, posY1: object.position.y,
                                                                             angle1: object.zRotation, scale1: object.xScale,
                                                                             posX2: (linked?.position.x)!, posY2: (linked?.position.y)!, angle2: (linked?.zRotation)!, scale2: (linked?.xScale)!);
                            dontDuplicateAgain.insert(object as! PortalObject);
                            dontDuplicateAgain.insert(linked!);
                        }
                        
                        
                    case AcceleratorObject.NAME?:
                        SocketIOManager.sharedInstance.dupAccelOnline(
                            mapName: OnlineEditionModeController.mapName, posX: object.position.x,
                            posY: object.position.y, angle: object.zRotation, scale: object.xScale);
                    case WallObject.NAME?:
                        SocketIOManager.sharedInstance.dupWallOnline(
                            mapName: OnlineEditionModeController.mapName, posX: object.position.x,
                            posY: object.position.y, angle: object.zRotation, scale: object.size.height);
                    case .none:
                        break;
                    case .some(_):
                        break;
                    }
                }
                // Reset gameIds so things dont break
                GameObject.idCount -= duplicatedObjects.count;
            } else {
                for object in duplicatedObjects {
                    editScene.addNode(object)
                }
            }
            
        } else {
            // reduce game id because we jsut created objects for no reason
            GameObject.idCount -= duplicatedObjects.count;
        }
    }
    
    
}
