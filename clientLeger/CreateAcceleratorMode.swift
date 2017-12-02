//
//  CreateAcceleratorMode.swift
//  clientLeger
//
//  Created by Marco on 2017-10-26.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit

class CreateAcceleratorMode: EditMode {
    
    var editScene: EditionModeScene;
    
    init(_ scene: EditionModeScene) {
        editScene = scene;
        super.init();
        self.name = "CreateAcceleratorMode"
    }
    
    override func onSingleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        super.onSingleTap(xCord, yCord) // Calling super saves the touch in the lastTouch field
        
        let adjustedCoord : CGPoint = convertScreenCoordinatesToScene(editScene, xCord, yCord)
        
        let accelerator : AcceleratorObject = GameObjectFactory.createAcceleratorObject(adjustedCoord.x, adjustedCoord.y)
        if (EditionModeUtils.canPlaceItem(accelerator, editScene)){
            if (SocketIOManager.sharedInstance.isConnected()) {
                // Adjust Gameobject count cause we just created an object for no reason
                GameObject.idCount -= 1;
                SocketIOManager.sharedInstance.addAccelOnline(mapName: OnlineEditionModeController.mapName,
                                                              posX: adjustedCoord.x,posY:adjustedCoord.y);
            } else {
                SoundManager.playPlaceItem();
                editScene.addNode(accelerator)
            }
            
        } else {
            // Adjust Gameobject count cause we just created an object for no reason
            GameObject.idCount -= 1;
        }
    }
    
    
    
}
