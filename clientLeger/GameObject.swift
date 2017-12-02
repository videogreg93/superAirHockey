//
//  GameObject.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-05.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

/*
 
Abtract class to model the different objects that
appear in gameplay
 
*/

import Foundation
import SpriteKit
import AEXML

class GameObject: SKSpriteNode  {
    static var idCount: Int = 0;
    var backupPosition : CGPoint
    var backupZAngle : CGFloat
    var backupScale : CGPoint
    var id: Int;
    
    init?(_ fileName: String) {
        let texture = SKTexture(imageNamed: fileName);
        backupPosition = CGPoint(x:0,y:0)
        backupZAngle = 0
        backupScale = CGPoint(x:1,y:1)
        GameObject.idCount += 1;
        id = GameObject.idCount;
        print("gameObject Count (init 1) = " + GameObject.idCount.description);
        print("Creating object named " + fileName);
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        zPosition = 2;
        name = "Game Object";
       
    }
    
    init (_ texture: SKTexture, _ color: UIColor, _ size: CGSize ) {
        backupPosition = CGPoint(x:0,y:0)
        backupZAngle = 0
         backupScale = CGPoint(x:1,y:1)
        GameObject.idCount += 1;
        id = GameObject.idCount;
        print("gameObject Count (init 2) = " + GameObject.idCount.description);
        super.init(texture: texture, color: UIColor.clear, size: texture.size());
        zPosition = 2;
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        backupPosition = CGPoint(x:0,y:0)
        backupZAngle = 0
        backupScale = CGPoint(x:0,y:0)
        GameObject.idCount += 1;
        print("gameObject Count (init 3) = " + GameObject.idCount.description);
        id = GameObject.idCount;
        super.init(coder: aDecoder)
        zPosition = 2;
        
    }
    
    override func copy() -> Any {
        print("gameObject copy");
        return self;
    }
    
    func addGlow(radius: Float = 25){
        let glowNode = SKEffectNode()
        glowNode.shouldRasterize = true
        addChild(glowNode)
        let glowyChildNode = SKSpriteNode(texture: texture)
        glowNode.addChild(glowyChildNode)
        glowNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": radius])
    }
    
    func scale ( _ growSpeed : CGFloat){
        
        var newXScale : CGFloat = xScale + growSpeed
        var newYScale : CGFloat = yScale + growSpeed
        
        if (newXScale < 0.1){
            newXScale = 0.1
        }
        if (newYScale < 0.1){
            newYScale = 0.1
        }
        
        xScale = newXScale
        yScale = newYScale

    }
    
    func removeGlow(){
        // Only remove the fx nodes ?
        removeAllChildren()
    }
    
    func setUpBackup(){
        self.backupPosition = CGPoint(x:position.x, y:position.y)
        self.backupZAngle = zRotation
        self.backupScale = CGPoint(x:xScale, y:yScale)
    }
    
    func restoreBackup(){
        self.position = backupPosition
        self.zRotation = backupZAngle
        self.xScale = backupScale.x
        self.yScale = backupScale.y
    }
    
    func resetBackup(){
        self.backupPosition = CGPoint(x:0,y:0)
        self.backupZAngle = 0
        self.backupScale = CGPoint(x:1,y:1)
    }
    // MARK: map saving functions
    
    func saveObjectToXml(_ parent: AEXMLElement) -> AEXMLElement? {
        print("saveObjectToXml not overriden for this object!");
        return nil;
    }
    
    //MARK: Utils
    
    //3.690599 + 0.04145188*e^(+2.010105*x)
    static func convertScaleLegerToLourd(_ scale: CGFloat) -> CGFloat {
        var temp: Float = Float(scale);
        temp = powf(Float(M_E), 2.010105 * temp);
        temp = temp * 0.04145188;
        temp += 3.690599;
        return CGFloat(temp);
    }
    
    // 0.497486 log(24.1244 (x - 3.6906))
    static func convertScaleLourdToLeger(_ scale: CGFloat) -> CGFloat {
        var temp: Float = Float(scale);
        temp -= 3.6906;
        temp *= 24.1244;
        temp = 0.497486 * log(temp);
        return CGFloat(temp);
    }
    //MARK: Rotation conversion
    static func convertR0SLegerToLourds(_ rotation: CGFloat) -> CGFloat {
        // convert to degrees
        let degrees = (Float(rotation) * (180/(Float(M_PI))));
        var temp = -0.009246421*degrees;
        temp += 0.8916789;
        return CGFloat(temp);
    }
    
    static func convertR0SLourdsToLeger(_ rotation: CGFloat) -> CGFloat {
        var degree = -99.4173 * rotation;
        degree += 97.55726;
        // convert to radians
        print("Converted degrees: " + degree.description);
        var radians = (Float(degree) * (Float(M_PI)/180));
        return CGFloat(radians);
    }
    
    static func convertR0TLegerToLourds(_ rotation: CGFloat) -> CGFloat {
        // convert to degrees
        let degrees = (Float(rotation) * (180/(Float(M_PI))));
        var temp = -0.007145731*degrees;
        temp += 1.213207;
        return CGFloat(temp);
    }
    
    static func convertR0TLourdsToLeger(_ rotation: CGFloat) -> CGFloat {
        var degree = -110.3108 * rotation;
        degree += 160.9337;
        // convert to radians
        print("Converted degrees: " + degree.description);
        var radians = (Float(degree) * (Float(M_PI)/180));
        return CGFloat(radians);
    }
    
    static func convertR1SLegerToLourds(_ rotation: CGFloat) -> CGFloat {
        // convert to degrees
        let degrees = (Float(rotation) * (180/(Float(M_PI))));
        var temp = 0.007145731*degrees;
        temp -= 1.213207;
        return CGFloat(temp);
    }
    
    static func convertR1SLourdsToLeger(_ rotation: CGFloat) -> CGFloat {
        var degree = 110.3108 * rotation;
        degree += 160.9337;
        // convert to radians
        print("Converted degrees: " + degree.description);
        var radians = (Float(degree) * (Float(M_PI)/180));
        return CGFloat(radians);
    }
    
    static func convertR1TLegerToLourds(_ rotation: CGFloat) -> CGFloat {
        // convert to degrees
        let degrees = (Float(rotation) * (180/(Float(M_PI))));
        var temp = -0.002460185*degrees;
        temp += 0.4833829;
        return CGFloat(temp);
    }
    
    static func convertR1TLourdsToLeger(_ rotation: CGFloat) -> CGFloat {
        var degree = -69.75172 * rotation;
        degree += 139.7517;
        // convert to radians
        print("Converted degrees: " + degree.description);
        var radians = (Float(degree) * (Float(M_PI)/180));
        return CGFloat(radians);
    }
    
    static func resetGameIdCount() {
        GameObject.idCount = 13;
    }
    
    
}

