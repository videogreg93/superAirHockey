//
//  BorderWallObject.swift
//  clientLeger
//
//  Created by Marco on 2017-10-28.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit
import AEXML

class BorderWallObject: WallObject {
    
    //let SPRITEFILENAME : String = "borderWall"    Doesn't exist yet
    public let NAME_Border : String = "GO_BorderWall";
    public let SPRITENAME: String = "exteriorWalls";
    let BORDERWALLWIDTH : CGFloat = 8

    
    @nonobjc
    override init?() {
        super.init(SPRITENAME)
        size.width = BORDERWALLWIDTH
        name = NAME_Border
    }
    
    override init?(_ fileName: String){
        super.init(fileName)
        size.width = BORDERWALLWIDTH
        name = NAME_Border
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func isSelectionEnabled() -> Bool {
        return false;
    }
    
    override func saveObjectToXml(_ parent: AEXMLElement) -> AEXMLElement? {
        print("We dont save BorderWallObjects");
        return nil;
    }
    
}
