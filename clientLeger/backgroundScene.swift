//
//  backgroundScene.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-11-22.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import UIKit
import SpriteKit

class backgroundScene: SKScene {
    var big1: SKSpriteNode;
    var big2: SKSpriteNode;
    
    var allNodes: Set<SKSpriteNode> = []
    
    override init() {
        big1 = SKSpriteNode();
        big2 = SKSpriteNode();
        super.init();
        onInit();
    }
    
    override init(size: CGSize) {
        big1 = SKSpriteNode();
        big2 = SKSpriteNode();
        super.init(size: size);
        onInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        big1 = SKSpriteNode();
        big2 = SKSpriteNode();
        super.init(coder: aDecoder)
        onInit();
    }
    
    func onInit() {
        big1 = self.childNode(withName: "big1") as! SKSpriteNode
        big2 = self.childNode(withName: "big2") as! SKSpriteNode
        
        allNodes.insert(big1);
        allNodes.insert(big2);
    }
    
    override func update(_ currentTime: TimeInterval) {
        big1.position.x += CGFloat(1);
        big2.position.x += CGFloat(1);
        
        
        
        for node in allNodes {
            if (node.position.x > 1024) {
                node.position.x -= (node.size.width * 2)
            }
        }
    }
}
