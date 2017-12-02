//
//  WallObject.swift
//  clientLeger
//
//  Created by Marco on 2017-10-26.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import AEXML;
import SpriteKit

class WallObject: GameObject {
    
    var SPRITEFILENAME : String = "wallObject"   // find new sprite !!!
    let defaultHeight : CGFloat = 5;
    let defaultWidth : CGFloat = 5;
    public static let NAME : String = "GO_Wall"
    
    var startPoint : CGPoint
    var endPoint : CGPoint
    var absoluteAngle : CGFloat
    
    var backupStartPoint : CGPoint = CGPoint()
    var backupEndPoint : CGPoint = CGPoint()
    var backupAbsoluteAngle : CGFloat = 0
    
    @nonobjc
    init?() {
        startPoint = CGPoint(x:0,y:0)
        endPoint = CGPoint(x:0,y:0)
        absoluteAngle = 0
        super.init(SPRITEFILENAME)!
        name = WallObject.NAME;
        
        size.height = defaultHeight
        size.width = defaultWidth
    }
    
    override init?(_ fileName: String) {
        startPoint = CGPoint(x:0,y:0)
        endPoint = CGPoint(x:0,y:0)
        absoluteAngle = 0
        super.init(fileName)!
        name = WallObject.NAME;
        size.height = defaultHeight
        size.width = defaultWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func isSelectionEnabled() -> Bool {
        return true;
    }
    
    override func saveObjectToXml(_ parent: AEXMLElement) -> AEXMLElement? {
        // Default scale on client lourd is 4
        let scaleX = (GameObject.convertScaleLegerToLourd(self.xScale)).description;
        let scaleY = (GameObject.convertScaleLegerToLourd(self.yScale)).description;
        let height = self.size.height.description;
        // Setting default rotation for now
        //let firstRotation = zRotation.description;
        let R0S = GameObject.convertR0SLegerToLourds(zRotation).description;
        let R0T = GameObject.convertR0TLegerToLourds(zRotation).description;
        let R1S = GameObject.convertR1SLegerToLourds(zRotation).description;
        let R1T = GameObject.convertR1TLegerToLourds(zRotation).description;
        // position
        let x = position.x.description;
        let y = position.y.description;
        let attributes = ["type": "mur", "id": self.id.description,
                          "e_0_s":scaleX, "e_1_t": scaleY, "e_2_p":height,
                          "r_0_s": R0S, "r_0_t": R0T, "r_1_s": R1S, "r_1_t": R1T,
                          "p_3_s":x, "p_3_t":y,
                          "p_0_x":"1", "p_0_r":"1", "p_0_s":"1", "r_3_w":"1", "r_3_a":"1", "r_3_q":"1" // dont know
        ];
        return (parent.addChild(name: "mur", attributes: attributes))
    }

    public func adjustRotationFromAbsAngle(){
        zRotation = (3*CGFloat.pi/2 + absoluteAngle).truncatingRemainder(dividingBy: 2*CGFloat.pi)
    }
    
    override public func setUpBackup() {
        super.setUpBackup()
        backupEndPoint = endPoint
        backupStartPoint = startPoint
        backupAbsoluteAngle = absoluteAngle
    }
    
    override public func restoreBackup() {
        super.restoreBackup()
        endPoint = CGPoint(x:backupEndPoint.x, y:backupEndPoint.y)
        startPoint = CGPoint(x:backupStartPoint.x,y:backupStartPoint.y)
        absoluteAngle = backupAbsoluteAngle
    }
}
