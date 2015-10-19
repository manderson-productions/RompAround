//
//  Enemy.swift
//  RompAround
//
//  Created by Mark Anderson on 10/10/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import SpriteKit

enum EnemyType: String {
    case Goblin
    
    func color() -> SKColor {
        switch self {
        case .Goblin:
            return SKColor.yellowColor()
        }
    }
}

class EnemySprite: SKSpriteNode, UpdateableLevelEntity, MoveableEntity {
    
    let type: EnemyType
    
    struct Constants {
        static let healthDefault = 3
        static let attackDefault = 1
        static let defenseDefault = 1
        static let movementDefault = 4
    }
    
    // MARK: Properties
    
    var health: Int
    var attack: Int
    var defense: Int
    var movement: Int
    
    var dice = Dice(moves: 0, attack: 0, magic: 0)
    
    func hasMoves() -> Bool {
        return dice.moves > 0
    }
    
    func hasAttacks() -> Bool {
        return dice.attack > 0
    }
    
    func hasMagicAttacks() -> Bool {
        return dice.magic > 0
    }
    
    func hasMovesOrAttacks() -> Bool {
        return hasMoves() && (hasAttacks() || hasMagicAttacks())
    }
    
    func moveOrAttack(direction: Direction, inLevel: LevelScene) {
        print("Moves Left: \(dice.moves)---Attack Left: \(dice.attack)---Magic Left: \(dice.magic)")
    }
    
    init(type: EnemyType, health: Int?, attack: Int?, defense: Int?, movement: Int?, size: CGSize) {
        self.type = type
        self.health = health ?? Constants.healthDefault
        self.attack = attack ?? Constants.attackDefault
        self.defense = defense ?? Constants.defenseDefault
        self.movement = movement ?? Constants.movementDefault
        super.init(texture: nil, color: type.color(), size: size)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: UpdateableEntity
    
    func update(currentTime: NSTimeInterval, inLevel: LevelScene) {
        // TODO: Implement
    }
    
    // MARK: MoveableEntity
    
    func move(direction: Direction, enemy: EnemySprite?, loot: LootSprite?, inLevel: LevelScene) {
        // TODO: Implement
    }

    func wasAttacked(by: SKSpriteNode, amount: Int, inLevel: LevelScene) -> Bool {
        print("Attacked by: \(by) for amount: \(amount)")
        health -= amount
        if health <= 0 {
            health = 0
            runAction(
                SKAction.sequence([SKAction.group([SKAction.fadeOutWithDuration(0.3), SKAction.scaleTo(0.3, duration: 0.3)]),
                    SKAction.runBlock({ [weak self](Void) -> Void in
                        self?.removeFromParent()
                        })
                    ]))
            return true
        }
        print("Enemy Health left: \(health)")
        return false
    }
}