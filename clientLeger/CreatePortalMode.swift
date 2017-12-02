//
//  CreatePortalMode.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-03.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class CreatePortalMode: EditMode {
    
    var editScene: EditionModeScene;
    public var createFirstPortal: Bool
    
    var tempPortalForLinking: PortalObject?;
    
    init(_ scene: EditionModeScene) {
        createFirstPortal = true;
        editScene = scene;
        super.init();
        self.name = "CreatePortalMode"
    }
    
    
    
    override func onSingleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        super.onSingleTap(xCord, yCord) // Calling super saves the touch in the lastTouch field
        let newPortal : PortalObject = PortalObject(createFirstPortal);
        if (createFirstPortal) {
            tempPortalForLinking = newPortal;
        } else {
            newPortal.setLinkPortal(tempPortalForLinking!);
            tempPortalForLinking?.setLinkPortal(newPortal);
        }
        // Get portal position
        var portalPosition: CGPoint = CGPoint();
        var temp: CGPoint = CGPoint();
        temp.x = xCord;
        temp.y = yCord;
        portalPosition = convertScreenCoordinatesToScene(editScene, xCord, yCord)
        if let portal: Optional = newPortal{
            portal?.position.x = portalPosition.x;
            portal?.position.y = portalPosition.y;
            portal?.zPosition = 2;
            
            print("CreatePortalMode: X = " + portalPosition.x.description);
            print("CreatePortalMode: Y = " + portalPosition.y.description);
            
            if (EditionModeUtils.canPlaceItem(portal!, editScene)){
                SoundManager.playPlaceItem();
                createFirstPortal = !createFirstPortal;
                if (!SocketIOManager.sharedInstance.isConnected()) {
                    editScene.addNode(portal!)
                } else {
                    if (!createFirstPortal) {
                        editScene.addNode(portal!);
                    }
                    if (createFirstPortal) {
                        editScene.removeNode(tempPortalForLinking!);
                        GameObject.idCount -= 2;
                        SocketIOManager.sharedInstance.addPortalOnline(mapName: OnlineEditionModeController.mapName,
                                                                       posX1: (tempPortalForLinking?.position.x)!, posY1: (tempPortalForLinking?.position.y)!,
                                                                       posX2: (portal?.position.x)!, posY2: (portal?.position.y)!);
                    }
                }
                
            }
        }
        else{
            print("‼️Create Portal Failed");
        }
    }
    
    override func canChangeEditMode() -> Bool {
        if (!createFirstPortal) {
            SoundManager.playCantPlaceThere();
        }
        return createFirstPortal;
    }
    

}
