//
//  GoalObject.swift
//  clientLeger
//
//  Created by Marco on 2017-11-02.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit
import AEXML

class GoalObject: WallObject {
    
    public let NAME_GOAL : String = "GO_ButWall";
    public let SPRITENAME: String = "goal";
    let GOALWIDTH : CGFloat = 9;
    
    var reverseEndpoints : Bool = false
    
    @nonobjc
    override init?() {
        super.init(SPRITENAME)
        size.width = GOALWIDTH
        name = NAME_GOAL
    }
    
    override init?(_ fileName: String){
        super.init(fileName)
        size.width = GOALWIDTH
        name = NAME_GOAL
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func isSelectionEnabled() -> Bool {
        return false;
    }
    
    // Dont save this object to xml
    override func saveObjectToXml(_ parent: AEXMLElement) -> AEXMLElement? {
        print("We dont save GoalObjects");
        return nil;
    }
    
}

