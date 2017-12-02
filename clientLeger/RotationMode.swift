//
//  RotationMode.swift
//  clientLeger
//
//  Created by Marco on 2017-10-25.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import SpriteKit

class RotationMode: EditMode {
    
    var editScene: EditionModeScene;
    let rotationSpeed : CGFloat = 0.1;
    let pi2 : CGFloat = 2*CGFloat.pi
    var lastRotationInput : CGFloat;
    var isSingleRotation : Bool;
    var centerOfSelection : CGPoint;
    var selectedItems : Set<GameObject>;
    
    init(_ scene: EditionModeScene) {
        editScene = scene;
        lastRotationInput = 0
        selectedItems = editScene.selectedItems
        isSingleRotation = true;
        centerOfSelection = EditionModeUtils.getCenterOfMass(selectedItems)
        super.init();
        self.name = "EM_ROTATION"
    }
    
    override func rotationRecognized(_ rotation: UIRotationGestureRecognizer) {
        let selectedItems = editScene.selectedItems
        if(rotation.state == .began ){
            lastRotationInput = rotation.rotation
            EditionModeUtils.setupBackup(selectedItems)
            
            isSingleRotation = (selectedItems.count == 1)
            centerOfSelection = EditionModeUtils.getCenterOfMass(selectedItems)
        }
            
        else if (rotation.state == .ended){
            lastRotationInput = 0
            if (EditionModeUtils.canPlaceAllItems(selectedItems, editScene)){
                EditionModeUtils.resetBackup(selectedItems)
            }
            else{
                EditionModeUtils.restoreBackup(selectedItems)
            }
        }
        else if( rotation.state == .failed || rotation.state == .cancelled){
            lastRotationInput = 0
            EditionModeUtils.restoreBackup(selectedItems)
        }
        else{
            rotateAllSelectedObjects(rotation.rotation)
            lastRotationInput = rotation.rotation
        }
    }
    
    func rotateAllSelectedObjects(_ currentRotation : CGFloat){
        let rotationAngle : CGFloat = -(currentRotation - lastRotationInput)
        
        if (isSingleRotation){
            handleSingleNodeRotation(rotationAngle)
        }
        else {
            handleMultiNodeRotation(rotationAngle)
        }
    }
    
    private func handleSingleNodeRotation(_ rotationAngle: CGFloat){
        for gameObject in selectedItems {
            gameObject.zRotation = (gameObject.zRotation + rotationAngle).truncatingRemainder(dividingBy: pi2)
            //SocketIOManager.sharedInstance.moveObjectOnline(mapName: OnlineEditionModeController.mapName,
                          //                                  gameObject: gameObject);
        }
    }
    
    private func handleMultiNodeRotation(_ rotationAngle: CGFloat){
        
        var deltaX : CGFloat
        var deltaY : CGFloat
        var sinValue : CGFloat
        var cosValue : CGFloat
        
        for gameObject in editScene.selectedItems {
            
            deltaX = gameObject.position.x - centerOfSelection.x
            deltaY = gameObject.position.y - centerOfSelection.y
            sinValue = sin(rotationAngle)
            cosValue = cos(rotationAngle)
            
            gameObject.zRotation = (gameObject.zRotation + rotationAngle).truncatingRemainder(dividingBy: pi2)
            gameObject.position.x = (centerOfSelection.x + deltaX*cosValue - deltaY*sinValue)
            gameObject.position.y = (centerOfSelection.y + deltaX*sinValue + deltaY*cosValue)
            //SocketIOManager.sharedInstance.moveObjectOnline(mapName: OnlineEditionModeController.mapName,
                                                 //           gameObject: gameObject);
        }
    }
}
