//
//  EditMode.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-02.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import UIKit

class EditMode {
    var name: String
    var firstContactPoint: CGPoint
    var latestContactPoint: CGPoint
    var lastDirection : CGPoint
    
    init() {
        name = "DefaultEditMode"
        firstContactPoint = CGPoint()
        latestContactPoint = CGPoint()
        lastDirection = CGPoint()
    }
    
    // MARK Tap Handlers
    // These functions are to be overriden in child members
    // in order to handle the different inputs
    
    public func onSingleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        print("EditMode: onSingleTap();");
        firstContactPoint.x = xCord
        firstContactPoint.y = yCord
        print("firstContactPoint=(" + firstContactPoint.x.description + "," + firstContactPoint.y.description + ")")
    }
    
    public func onDoubleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        print("EditMode: onDoubleTap();");

    }
    public func onSingleFingerSlide(_ newX: CGFloat, _ newY: CGFloat){
        print("EditMode: onSingleFingerSlide();");
    }
    
    
    public func onSingleFingerSlide(_ newX: CGFloat, _ newY: CGFloat, _ touchesSet: Set<UITouch>) {
        onSingleFingerSlide(newX, newY)
        print("EditMode: onSingleFingerSlide();");
    }
    
    public func onTouchEnded(_ newX: CGFloat, _ newY: CGFloat) {
        print("EditMode: onTouchEnd();");
        print("firstContactPoint=(" + firstContactPoint.x.description + "," + firstContactPoint.y.description + ")")
        print("latestContactPoint=(" + latestContactPoint.x.description + "," + latestContactPoint.y.description + ")")
    }
    
    // TODO replace Any with actual variable type
    public func onTwoFingerSlide(_ newX: Any, _ newY: Any) {
        print("EditMode: onTwoFingerSlide()");
    }
    
    // TODO replace Any with actual variable type
    public func onThreeFingerRotate(_ deltaRotation: Any) {
        print("EditMode: onThreeGinerRotate()");
    }
    
    public func pinchRecognized(_ pinch: UIPinchGestureRecognizer){
        print("EditMode: Pinch recognized");
    }
    
    public func rotationRecognized(_ rotation: UIRotationGestureRecognizer){
        print("EditMode: Rotation recognized");
    }
    
    public func panRecognized(_ sender: UIPanGestureRecognizer){
        
    }
    
    // MARK getters
    
    func getName() -> String {
        return name;
    }
    
    // MARK Utils
    func onAssign() {
        print("You are now in " + name + " mode");
    }
    
    // Pas de protected dans Swift...
    public func getDelta(_ x: CGFloat,_ y: CGFloat) -> CGPoint {
        var temp: CGPoint = CGPoint()
        temp.x = x - firstContactPoint.x;
        temp.y = y - firstContactPoint.y
        
        return temp
    }
    // Called to give general x,y direction where the gesture is headed.
    public func updateLatestDirection(_ xUpdate:CGFloat, _ yUpdate:CGFloat) {
        let delta = CGPoint(x:(xUpdate-latestContactPoint.x), y:(yUpdate-latestContactPoint.y))
        
        if (delta.x > 0 ){
            lastDirection.x = -1
        }
        else if (delta.x < 0){
            lastDirection.x = 1
        }
        else{
            lastDirection.x = 0
        }
        
        if (delta.y > 0 ){
            lastDirection.y = -1
        }
        else if (delta.y < 0){
            lastDirection.y = 1
        }
        else{
            lastDirection.y = 0
        }
    }
    
    public func updateLatestContactPoint (_ xUpdate:CGFloat, _ yUpdate:CGFloat){
        latestContactPoint.x = xUpdate
        latestContactPoint.y = yUpdate
    }
    
    public func getPositionDiff (_ mostRecentX:CGFloat, _ mostRecentY:CGFloat) -> CGPoint{
        return CGPoint(x: (mostRecentX - latestContactPoint.x), y: (mostRecentY - latestContactPoint.y))
    }
    
    
    public func convertScreenCoordinatesToScene(_ editScene:EditionModeScene, _ x: CGFloat,_ y: CGFloat ) -> CGPoint {
        
        var point: CGPoint = CGPoint();
        point.x = x - editScene.size.width/2;
        point.y = (editScene.size.height/2 - y) + 94; //TODO Fix hack properly
        
        if let camera = editScene.camera{
            point.x = (point.x * camera.xScale) + camera.position.x;
            point.y = (point.y * camera.yScale) + camera.position.y; //TODO Fix hack properly
        }
        
        return point;
    }
    
    public func canChangeEditMode() -> Bool {
        return true;
    }
    
}
