//
//  CameraMode.swift
//  clientLeger
//
//  Created by Marco on 2017-10-09.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class CameraMode: EditMode {
    
    var editScene: EditionModeScene;
    let zoomSpeed: CGFloat = 0.03;
    var lastScaleInput: CGFloat = 1;
    
    init(_ scene: EditionModeScene) {
        editScene = scene;
        lastScaleInput = 1;
        super.init();
        self.name = "CameraMode"
    }
    
    override func onSingleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        super.onSingleTap(xCord, yCord)
    }
    
    override func onDoubleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        self.resetDefaultPosition();
    }
    
    override func onSingleFingerSlide(_ newX: CGFloat, _ newY: CGFloat) {
        super.onSingleFingerSlide(newX, newY)
        super.updateLatestDirection(newX, newY)
        
        let cameraSpeed :CGFloat = 15;
       
        // Move camera itself
        if let camera = editScene.camera{
            camera.position = CGPoint (x: camera.position.x + (cameraSpeed*lastDirection.x) * camera.xScale, y: camera.position.y - (cameraSpeed*lastDirection.y) * camera.yScale);
        }
        updateLatestContactPoint(newX,newY)
    }
    
    override func onTouchEnded(_ newX: CGFloat, _ newY: CGFloat) {
        super.onTouchEnded(newX, newY);
    }
    
    override func pinchRecognized(_ pinch: UIPinchGestureRecognizer) {
        if(pinch.state == .began && lastScaleInput == 1){
            lastScaleInput = pinch.scale
        }
        else{
            if let camera = editScene.camera{
                var adjustedZoomSpeed = zoomSpeed
                if ((lastScaleInput - pinch.scale) < 0){
                     adjustedZoomSpeed *= -1
                }
                if ((camera.xScale + adjustedZoomSpeed) > 0.25 && (camera.xScale + adjustedZoomSpeed) < 1.7){
                    camera.setScale(camera.xScale + adjustedZoomSpeed)
                }
            }
            lastScaleInput = pinch.scale
        }
    }
    /*
    override func rotationRecognized(_ rotation: UIRotationGestureRecognizer) {
        if let camera = editScene.camera{
            camera.zRotation = rotation.rotation
        }
    }
    */
    func resetDefaultPosition(){
        if let camera = editScene.camera{
            // Might have to adjust the coords instead... not sure ?
            camera.position = CGPoint (x: 0, y: 0);
            camera.zRotation = 0;
            camera.xScale = 1;
            camera.yScale = 1;
            lastScaleInput = 1;
        }
    }
}
