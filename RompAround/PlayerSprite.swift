//
//  PlayerSprite.swift
//  RompAround
//
//  Created by Mark Anderson on 10/11/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayerSprite : SKSpriteNode, UpdateableLevelEntity, MoveableEntity {
    var pendingMoves = [(direction: Direction, enemy: EnemySprite?, loot: LootSprite?)]()
//    var pendingAttacks = [(direction: Direction, enemy: EnemySprite)]()

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func update(currentTime:NSTimeInterval, inLevel:LevelScene) {
        if !hasActions() {
            if let (move, enemy, loot) = pendingMoves.popLast() {
                let previousPositionInWorld = position
                let currentPositionInGrid = previousPositionInWorld.gridPoint(inLevel.levelData.squareSize.int32)
                let dx = Int32(currentPositionInGrid.x) + move.x
                let dy = Int32(currentPositionInGrid.y) + move.y
                if let nextPosition = inLevel.gridGraph.nodeAtGridPosition(int2(x: dx, y: dy)) {
                    if let enemy = enemy {
                        runAction(SKAction.sequence(
                            [SKAction.moveTo(CGPoint(x: CGFloat(nextPosition.gridPosition.x.int * inLevel.levelData.squareSize), y: CGFloat(nextPosition.gridPosition.y.int * inLevel.levelData.squareSize)), duration: 0.1),
                                SKAction.moveTo(previousPositionInWorld, duration: 0.1)]))
                        enemy.runAction(SKAction.sequence([SKAction.scaleTo(0.3, duration: 0.1), SKAction.scaleTo(1.0, duration: 0.1)]))
                        return
                    } else if let loot = loot {
                        loot.runAction(SKAction.sequence([SKAction.scaleTo(0.1, duration: 0.1), SKAction.removeFromParent()]))
                    }
                    runAction(SKAction.moveTo(CGPoint(x: CGFloat(nextPosition.gridPosition.x.int * inLevel.levelData.squareSize), y: CGFloat(nextPosition.gridPosition.y.int * inLevel.levelData.squareSize)), duration: 0.1))
                }
            }
        }
    }
    
    func canMove(direction: Direction, inLevel: LevelScene) -> (canMove: Bool, enemy: EnemySprite?, loot: LootSprite?) {
        let currentPosition = position.gridPoint(inLevel.levelData.squareSize.int32)
        let dx = Int32(currentPosition.x) + direction.x
        let dy = Int32(currentPosition.y) + direction.y
        if let targetPosition = inLevel.gridGraph.nodeAtGridPosition(int2(x: dx, y: dy)) {
            for enemy in inLevel.enemyNodesInLevel() {
                let enemyPosition = enemy.position.gridPoint(inLevel.levelData.squareSize.int32)
                if enemyPosition.x == targetPosition.gridPosition.x && enemyPosition.y == targetPosition.gridPosition.y {
                    return (true, enemy, nil)
                }
            }
            for loot in inLevel.lootNodesInLevel() {
                let lootPosition = loot.position.gridPoint(inLevel.levelData.squareSize.int32)
                if lootPosition.x == targetPosition.gridPosition.x && lootPosition.y == targetPosition.gridPosition.y {
                    return (true, nil, loot)
                }
            }
            // found a target position but no enemy or loot
            return (true, nil, nil)
        }
        // cannot move, attack, or collect loot
        return (false, nil, nil)
    }
    
    func move(direction: Direction, enemy: EnemySprite?, loot: LootSprite?, inLevel: LevelScene) {
        //print("Moving: \(direction)")
        pendingMoves.push((direction, enemy, loot))
    }
    
    func wasAttacked(by: SKSpriteNode, amount: Int, inLevel: LevelScene) -> Bool {
        return false
    }
}
