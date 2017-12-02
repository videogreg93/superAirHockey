//
//  CreateWallMode.swift
//  clientLeger
//
//  Created by Marco on 2017-10-26.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit

class CreateWallMode: EditMode {
    
    var editScene: EditionModeScene;
    var newWallNode : WallObject?
    
    init(_ scene: EditionModeScene) {
        editScene = scene;
        super.init();
        self.name = "CreateWallMode"
    }
    
    override func onSingleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        super.onSingleTap(xCord, yCord) // Calling super saves the touch in the lastTouch field
        
        let adjustedCoord : CGPoint = convertScreenCoordinatesToScene(editScene, xCord, yCord)
        
        if (newWallNode == nil){
            newWallNode = GameObjectFactory.createWallObject(adjustedCoord.x, adjustedCoord.y)
           
            if let wallNode : WallObject = newWallNode{
                wallNode.position = adjustedCoord;
                wallNode.startPoint = adjustedCoord;
                editScene.addNode(wallNode)
            }
        }
    }
    
    override func onSingleFingerSlide(_ xCord: CGFloat, _ yCord: CGFloat) {
        super.onSingleFingerSlide(xCord, yCord) // Calling super saves the touch in the lastTouch field
        let adjustedCoord : CGPoint = convertScreenCoordinatesToScene(editScene, xCord, yCord)
        
        if let wallNode : WallObject = newWallNode{
            EditionModeUtils.adjustWallNodePosition(wallNode, adjustedCoord)
        }

    }
    
    override func onTouchEnded(_ xCord: CGFloat, _ yCord: CGFloat) {
        super.onTouchEnded(xCord, yCord);
        let adjustedCoord : CGPoint = convertScreenCoordinatesToScene(editScene, xCord, yCord)
    
        if let wallNode : WallObject = newWallNode{
            wallNode.endPoint = adjustedCoord;
            if (!EditionModeUtils.canPlaceItem(wallNode, editScene)){
                editScene.removeNode(wallNode)
                GameObject.idCount -= 1;
            } else if (SocketIOManager.sharedInstance.isConnected()) {
                SocketIOManager.sharedInstance.addMurOnline(mapName: OnlineEditionModeController.mapName,
                                                            startX: wallNode.startPoint.x, startY: wallNode.startPoint.y,
                                                            endX: wallNode.endPoint.x, endY: wallNode.endPoint.y);
            } else {
                SoundManager.playPlaceItem();
            }
        }
        newWallNode = nil
    }
    
}
