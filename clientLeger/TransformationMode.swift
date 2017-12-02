//
//  TransformationMode.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-27.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class TransformationMode: EditMode {
    var editScene: EditionModeScene;
    var transformModes: Array<EditMode> = Array();
    var currentLocation : CGPoint = CGPoint()
    var previousLocation : CGPoint = CGPoint()
    
    let unreachableLocation : CGPoint = CGPoint(x: 9999999, y:999999)
    
    init(_ scene: EditionModeScene) {
        editScene = scene;
        transformModes.append(MoveMode(editScene));
        transformModes.append(RotationMode(editScene));
        transformModes.append(ScaleMode(editScene));

        super.init();
        self.name = "transformationMode"
    }
    
    override func onSingleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        currentLocation = convertScreenCoordinatesToScene(editScene, xCord, yCord);
        currentLocation = CGPoint()
        for mode in transformModes {
            mode.onSingleTap(xCord, yCord);
        }
    }
    
    override func onSingleFingerSlide(_ newX: CGFloat, _ newY: CGFloat) {
        for mode in transformModes {
            mode.onSingleFingerSlide(newX, newY);
        }
    }
    
    override func onTouchEnded(_ newX: CGFloat, _ newY: CGFloat) {
        for mode in transformModes {
            mode.onTouchEnded(newX, newY);
        }
    }
    
    override func pinchRecognized(_ pinch: UIPinchGestureRecognizer) {
        for mode in transformModes {
            mode.pinchRecognized(pinch);
        }
    }
    
    override func rotationRecognized(_ rotation: UIRotationGestureRecognizer) {
        for mode in transformModes {
            mode.rotationRecognized(rotation);
        }
    }
    
    override func panRecognized(_ sender: UIPanGestureRecognizer) {
        for mode in transformModes {
            mode.panRecognized(sender);
        }
    }
    
}
