//
//  AcceleratorObject.swift
//  clientLeger
//
//  Created by Marco on 2017-10-26.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit
import AEXML

class AcceleratorObject: GameObject {
    let speedBoost : CGFloat = 1.5
    let SPRITEFILENAME : String = "boost"   // find new sprite !!!
    public static let NAME : String = "GO_Accelerator"
    
    @nonobjc
    init?() {
        super.init(SPRITEFILENAME)!
        name = AcceleratorObject.NAME;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func isSelectionEnabled() -> Bool {
        return true;
    }
    
    override func saveObjectToXml(_ parent: AEXMLElement) -> AEXMLElement? {
        // Default scale on client lourd is 4
        let scale = (GameObject.convertScaleLegerToLourd(self.xScale)).description;
        // Setting default rotation for now
        let R0S = GameObject.convertR0SLegerToLourds(zRotation).description;
        let R0T = GameObject.convertR0TLegerToLourds(zRotation).description;
        let R1S = GameObject.convertR1SLegerToLourds(zRotation).description;
        let R1T = GameObject.convertR1TLegerToLourds(zRotation).description;
        // position
        let x = position.x.description;
        let y = position.y.description;
        let attributes = ["type": "accelerateur", "id": self.id.description,
                          "e_0_s":scale, "e_1_t": scale, "e_2_p":scale,
                          "r_0_s": R0S, "r_0_t": R0T, "r_1_s": R1S, "r_1_t": R1T,
                          "p_3_s":x, "p_3_t":y,
                          "p_0_x":"1", "p_0_r":"1", "p_0_s":"1", "r_3_w":"1", "r_3_a":"1", "r_3_q":"1" // dont know
            ];
        return (parent.addChild(name: "accelerateur", attributes: attributes))
    }
}
