//
//  MapSquare.swift
//  RompAround
//
//  Created by Mark Anderson on 10/10/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import SpriteKit

enum MapSquare: Int {
    case Ground = 0
    case Wall = 1
    case Destructable = 2
    case Enemy = 3
    case Player = 4
    case Loot = 5
    case Empty = 6
    
    var name: String {
        return "\(self)"
    }
}

extension MapSquare {
    var color: SKColor {
        switch self {
        case .Ground:
            return SKColor.grayColor()
        case .Wall:
            return SKColor.darkGrayColor()
        case .Destructable:
            return SKColor.purpleColor()
        case .Enemy:
            return SKColor.orangeColor()
        case .Player:
            return SKColor.redColor()
        case .Loot:
            return SKColor.blueColor()
        case .Empty:
            return SKColor.blackColor()
        }
    }
    
    // TODO: We don't necessarily need the level, gridx and gridY but may in the future
    func entryAction(forSprite sprite:SKSpriteNode, inLevel level:LevelData, atGridX gridX:Int, gridY:Int) -> SKAction? {
        let duration = 0.1
        sprite.alpha = 0
        switch self {
        case .Player, .Enemy:
            sprite.setScale(4.0)
            return SKAction.sequence([SKAction.waitForDuration(0.2), SKAction.group([SKAction.scaleTo(1.0, duration: duration), SKAction.fadeAlphaTo(1.0, duration: duration)])])
        default:
            return SKAction.fadeAlphaTo(1.0, duration: duration)
        }
    }
    
    func spriteForSquare(inLevel level:LevelData, atGridX gridX:Int=0, gridY:Int=0) -> SKSpriteNode? {
        if self == .Empty {
            return nil
        }
        
        let sprite: SKSpriteNode
        
        switch self {
        case .Player:
            sprite = PlayerSprite(color: color, size: CGSize(width: level.squareSize, height: level.squareSize))
        case .Enemy:
            sprite = EnemySprite(type: .Goblin, health: nil, attack: nil, defense: nil, movement: nil, size: CGSize(width: level.squareSize, height: level.squareSize))
        case .Loot:
            sprite = LootSprite(color: color, size: CGSize(width: level.squareSize, height: level.squareSize))
        default:
            sprite = SKSpriteNode(color: color, size: CGSize(width: level.squareSize, height: level.squareSize))
        }
        
        switch self {
        case .Empty, .Ground, .Wall, .Destructable:
            sprite.zPosition = LevelScene.WorldLayer.BelowCharacter.cgFloat
        case .Player, .Loot, .Enemy:
            sprite.zPosition = LevelScene.WorldLayer.Character.cgFloat
        }

        sprite.position = CGPoint(x: gridX * level.squareSize, y:  gridY * level.squareSize)
        sprite.name = name
        
        //Any special entry animation?
        if let initialAction = entryAction(forSprite: sprite, inLevel: level, atGridX: gridX, gridY: gridY){
            sprite.runAction(initialAction)
        }
        
        //If we are something that should be overlayed over the ground then create a ground sprite
        //and yourself as a child
        switch self{
        case .Empty, .Ground, .Wall:
            return sprite
        default:
            let groundSprite = MapSquare.Ground.spriteForSquare(inLevel: level, atGridX: gridX, gridY: gridY)
            
            sprite.position = CGPointZero
            
            groundSprite?.addChild(sprite)
            
            return groundSprite
        }
    }
}