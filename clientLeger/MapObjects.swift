//
//  MapObjects.swift
//  clientLeger
//
//  Created by Marco on 2017-11-08.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit

struct MapObjects {
    var borderWalls : [BorderWallObject] = []
    var goalSections : [GoalObject] = []
    var arenaFloor : SKShapeNode = SKShapeNode()
    var gameObjects : Set<GameObject> = []
    var floorPath : [CGPoint] = []
    var frictionCoeff : CGFloat = 0.1
    var restitutionCoeff : CGFloat = 1
    var accellerationCoeff : CGFloat = 3
}
