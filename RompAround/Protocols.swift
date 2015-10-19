//
//  Protocols.swift
//  RompAround
//
//  Created by Mark Anderson on 10/11/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import UIKit
import SpriteKit

protocol UpdateableLevelEntity {
    func update(currentTime: NSTimeInterval, inLevel: LevelScene)
}

struct Direction {
    var x: Int32
    var y: Int32
    
    static func directionFromSwipe(up: Float, down: Float, left: Float, right: Float) -> Direction {
        if up > down {
            if up > left && up > right {
                return Direction(x: 0, y: 1)
            }
        } else {
            if down > left && down > right {
                return Direction(x: 0, y: -1)
            }
        }
        
        if right > left {
            return Direction(x: 1, y: 0)
        } else {
            return Direction(x: -1, y: 0)
        }
    }
}

protocol MoveableEntity {
    func move(direction: Direction, enemy: EnemySprite?, loot: LootSprite?, inLevel: LevelScene)
    func wasAttacked(by: SKSpriteNode, amount: Int, inLevel: LevelScene) -> Bool
}