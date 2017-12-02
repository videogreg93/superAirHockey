//
//  PortalObject.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-05.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit
import AEXML

class PortalObject: GameObject {
    var linkedPortal: PortalObject?;
    public var linkedPortalId: Int = 0;
    let FIRSTPORTALFILENAME: String = "bluePortal"
    let SECONDPORTALFILENAME: String = "bluePortal"
    public static let NAME: String = "GO_PORTAL"
    var firstPortal: Bool;
    
     @nonobjc
     init(_ isFirstPortal:Bool) {
        firstPortal = isFirstPortal;
        //linkedPortal = PortalObject(true);
        if (isFirstPortal) {
            super.init(FIRSTPORTALFILENAME)!;
        } else {
            super.init(SECONDPORTALFILENAME)!;
        }
        name = PortalObject.NAME;
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setLinkPortal(_ portal:PortalObject) {
        linkedPortal = portal;
        linkedPortalId = portal.id
    }
    
    override func copy() -> Any {
        let temp: PortalObject = PortalObject(firstPortal);
        temp.linkedPortalId = linkedPortalId
        return temp;
    }
    
    override func isSelectionEnabled() -> Bool {
        return true;
    }
    
    override func saveObjectToXml(_ parent: AEXMLElement) -> AEXMLElement? {
        //var attributes = ["coefFriction": "0.0020000001", "coefRebond" : "0.0099999998", "accel": "2"];
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
        // frere id
        //let frereId: String = (linkedPortal?.id.description)!;
        let frereId: String = linkedPortalId.description;
        let attributes = ["type": "portail", "id": self.id.description,
                          "e_0_s":scale, "e_1_t": scale, "e_2_p":scale,
                          "r_0_s": R0S, "r_0_t": R0T, "r_1_s": R1S, "r_1_t": R1T,
                          "p_3_s":x, "p_3_t":y,
                          "p_0_x":"1", "p_0_r":"1", "p_0_s":"1", "r_3_w":"1", "r_3_a":"1", "r_3_q":"1", // dont know
                          "frereId": frereId];
        return (parent.addChild(name: "portail", attributes: attributes));
    }
    
    func findAndSetLinkPortal(_ possibleObjects :Set<GameObject>){
        for object in possibleObjects{
            if (object.isKind(of: PortalObject.self) && object.id == linkedPortalId) {
                linkedPortal = object as? PortalObject
                return
            }
        }
    }
    
}
