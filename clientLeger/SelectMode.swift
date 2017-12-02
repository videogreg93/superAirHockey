//
//  SelectMode.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-02.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class SelectMode: EditMode {
    
    var editScene: EditionModeScene;
    var selectionBox: SKSpriteNode;
    
    init(_ scene: EditionModeScene) {
        editScene = scene;
        selectionBox = SKSpriteNode(color:SKColor.darkGray ,size: CGSize(width: 0, height: 0));
        selectionBox.alpha = 0.4
        selectionBox.name = "selectionBox";
        selectionBox.isHidden = true;
        
        super.init();
        self.name = "SelectMode"
    }
    
    override func onSingleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        super.onSingleTap(xCord, yCord) // Calling super saves the touch in the lastTouch field
        let adjustedPosition = convertScreenCoordinatesToScene(editScene, xCord, yCord);
        
        //Cleanup
        selectionBox.removeFromParent();
        if (!editScene.selectedItems.isEmpty){
            EditionModeUtils.clearSelection(editScene:editScene);
        }
        
        // Detect collision with nodes
        EditionModeUtils.updateSelectionFromPoint(editScene:editScene, pointCoord:adjustedPosition);
        
        
    
        
    }
    
    override func onSingleFingerSlide(_ newX: CGFloat, _ newY: CGFloat) {
        super.onSingleFingerSlide(newX, newY)
        let deltaPoint: CGPoint = getDelta(newX, newY)
        let adjustedClickPosition = convertScreenCoordinatesToScene(editScene, firstContactPoint.x, firstContactPoint.y);
        
        // Cleanup
        selectionBox.removeFromParent();
        if (!editScene.selectedItems.isEmpty){
            EditionModeUtils.clearSelection(editScene:editScene);
        }
        
        //place at proper location
        if let camera = editScene.camera{
            selectionBox.isHidden = false;
            selectionBox.zPosition = 1;
            let cameraScale = camera.xScale
            selectionBox.position = CGPoint(x:adjustedClickPosition.x + deltaPoint.x/2*cameraScale, y:adjustedClickPosition.y - deltaPoint.y/2*cameraScale);
            selectionBox.size = CGSize(width:deltaPoint.x*cameraScale, height:deltaPoint.y*cameraScale);
        
        editScene.addSpriteNode(selectionBox);
        }
    }
    
    override func onTouchEnded(_ newX: CGFloat, _ newY: CGFloat) {
        EditionModeUtils.updateSelectionFromBox(editScene: editScene, selectionBox: selectionBox);
        resetSelectionBox();
        super.onTouchEnded(newX, newY);
    }
    
    override func pinchRecognized(_ pinch: UIPinchGestureRecognizer) {
        resetSelectionBox();
    }
    
    override func rotationRecognized(_ rotation: UIRotationGestureRecognizer) {
        resetSelectionBox();
    }
    
    func deleteSelectedNodes(){
        for node in editScene.selectedItems{
            editScene.removeNode(node);
            // Add case for portal pairs... can't have the only 1 of them there iirc
        }
    }
    
    func resetSelectionBox(){
        selectionBox.isHidden = true;
        selectionBox.position = CGPoint(x:editScene.size.width, y:editScene.size.height);
        selectionBox.size = CGSize(width:0, height:0);
        selectionBox.removeFromParent();
    }
    
    
}
