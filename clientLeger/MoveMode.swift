//
//  MoveMode.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-23.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class MoveMode: EditMode {
    var editScene: EditionModeScene;
    var isMovingObjects: Bool;
    var newObjectsDelta: CGPoint;
    // to calculate new object positions when sliding
    var centerOfMass: CGPoint = CGPoint();
    var distanceValues: Array<CGPoint> = Array();
    var originalObjectPositions: Array<CGPoint> = Array();
    
    init(_ scene: EditionModeScene) {
        editScene = scene;
        isMovingObjects = false;
        newObjectsDelta = CGPoint();
        super.init();
        self.name = "MoveMode"
    }
    
    override func onSingleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        super.onSingleTap(xCord, yCord);
        let selectedObjects = editScene.selectedItems;
        // calculate the center of mass;
        centerOfMass = EditionModeUtils.getCenterOfMass(selectedObjects);
        // Clear arrays
        distanceValues = Array();
        originalObjectPositions = Array();
        for object in selectedObjects {
            var distancePoint: CGPoint = CGPoint();
            distancePoint.x = object.position.x - centerOfMass.x;
            distancePoint.y = object.position.y - centerOfMass.y;
            distanceValues.append(distancePoint);
            // Save originial positions in case we must reset
            originalObjectPositions.append(object.position);
        }
        
        
    }
    
    override func onSingleFingerSlide(_ newX: CGFloat, _ newY: CGFloat) {
        let newPoint: CGPoint = convertScreenCoordinatesToScene(editScene, newX, newY);
        let selectedObjects = editScene.selectedItems;
        var i = 0;
        for object in selectedObjects { // for loops are weird in swift....
            object.position.x = newPoint.x + distanceValues[i].x;
            object.position.y = newPoint.y + distanceValues[i].y;
            i += 1;
        }
        
    }
    
    override func onTouchEnded(_ newX: CGFloat, _ newY: CGFloat) {
        // If the objects are in an illegal position, reset them all
        let selectedObjects = editScene.selectedItems;
        if (!EditionModeUtils.canPlaceAllItems(selectedObjects, editScene)) {
            // Reset the objects
            print("Object out of bounds: reseting them");
            var i = 0;
            for object in selectedObjects {
                object.position = originalObjectPositions[i];
                i += 1;
            }
        } else {
            // Alert other users of what I've done
            for object in selectedObjects {
                SocketIOManager.sharedInstance.moveObjectOnline(mapName: OnlineEditionModeController.mapName,
                                                                gameObject: object);
            }
            
        }
    }
    
}
