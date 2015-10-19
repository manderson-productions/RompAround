//
//  CardSprite.swift
//  RompAround
//
//  Created by Mark Anderson on 10/11/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import SpriteKit

class CardSprite: SKSpriteNode {
    let attack: Int
    let health: Int
    let info: String
    let type: PowerupType
    
    init(attack: Int, health: Int, info: String, color: SKColor = SKColor.yellowColor(), size: CGSize) {
        self.attack = attack
        self.health = health
        self.info = info
        self.type = .Card
        super.init(texture: nil, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
