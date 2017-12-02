//
//  MorphPointObject.swift
//  clientLeger
//
//  Created by Marco on 2017-10-28.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit
import AEXML

class MorphPointObject: GameObject {
    
    let SPRITEFILENAME : String = "pinkPortal"
    public let NAME : String = "B_MorphPoint";
    let defaultSize : CGSize = CGSize (width: 10, height: 10)
    var index : Int
    
    @nonobjc
    init?() {
        let texture = SKTexture(imageNamed: SPRITEFILENAME)
        index = 0
        super.init(texture, UIColor.red, defaultSize)
        name = NAME
        zPosition = 3
        xScale = 2
        yScale = 2
        isHidden = true
    }
    
    init?(_ startingPosition : CGPoint,_ arrayIndex: Int) {
        let texture = SKTexture(imageNamed: SPRITEFILENAME)
        index=arrayIndex
        super.init(texture, UIColor.red, defaultSize)
        position = startingPosition
        zPosition = 3
        xScale = 2
        yScale = 2
        isHidden = true

        name = NAME
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func saveObjectToXml(_ parent: AEXMLElement) -> AEXMLElement? {
        print("We dont save morph points");
        return nil;
    }
    
}
