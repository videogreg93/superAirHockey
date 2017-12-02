//
//  ScaleMode.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-23.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class ScaleMode : EditMode {
    var editScene: EditionModeScene;
    var isSliding = false;
    var newObjectsDelta: CGPoint;
    var lastScaleInput: CGFloat;
    
    let growSpeed : CGFloat = 0.05;
    
    let PORTALNAME: String = "Portal Object"
    
    init(_ scene: EditionModeScene) {
        editScene = scene;
        newObjectsDelta = CGPoint();
        
        lastScaleInput = 0;
        super.init();
        self.name = "ScaleMode"
    }
    
    override func pinchRecognized(_ pinch: UIPinchGestureRecognizer) {
        let selectedItems = editScene.selectedItems
        if(pinch.state == .began ){
            lastScaleInput = pinch.scale
            // Backup des scales individuelles pour chacun des items au cas ou c'est refuse ?
            EditionModeUtils.setupBackup(selectedItems)
        }
        else if (pinch.state == .ended){
            if (EditionModeUtils.canPlaceAllItems(selectedItems, editScene)){
                EditionModeUtils.resetBackup(selectedItems)
            }
            else{
                EditionModeUtils.restoreBackup(selectedItems)
            }
        }
        else if (pinch.state == .failed || pinch.state == .cancelled){
            lastScaleInput = 0
            EditionModeUtils.resetBackup(selectedItems)
        }
        else{
            scaleAllSelectedObjects(pinch.scale)
        }
    }
    
    func scaleAllSelectedObjects(_ currentScale : CGFloat){
        let delta : CGFloat = (currentScale - lastScaleInput)
        var grow : CGFloat = growSpeed
        if (delta < 0 ) {
            grow = -grow
        }
        
        for gameObject in editScene.selectedItems {
            gameObject.scale(grow)
            // Tell people online what I did!
            //SocketIOManager.sharedInstance.moveObjectOnline(mapName: OnlineEditionModeController.mapName,
                           //                                 gameObject: gameObject);
        }
        
        
    }
}
