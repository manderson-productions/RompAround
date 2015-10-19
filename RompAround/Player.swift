//
//  PlayerEntity.swift
//  RompAround
//
//  Created by Mark Anderson on 10/11/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import GameplayKit
import GameController

class Player: GKEntity {
    struct Constants {
        static let healthDefault = 3
        static let attackDefault = 1
        static let defenseDefault = 1
    }
    
    // MARK: Properties
    
    var hero: PlayerSprite!
    let diceHud = DiceHUD()
    var gold = 0

    var health: Int = Constants.healthDefault
    
    // These are not based on dice
    var attack: Int = Constants.attackDefault
    var defense: Int = Constants.defenseDefault

    func hasMoves() -> Bool {
        return diceHud.dice.moves > 0
    }
    
    func hasAttacks() -> Bool {
        return diceHud.dice.attack > 0
    }
    
    func hasMagicAttacks() -> Bool {
        return diceHud.dice.magic > 0
    }
    
    func hasMovesOrAttacks() -> Bool {
        return hasMoves() && (hasAttacks() || hasMagicAttacks())
    }
    
    func moveOrAttack(direction: Direction, inLevel: LevelScene) {
        let (shouldMove, enemy, loot) = hero.canMove(direction, inLevel: inLevel)
        
        if shouldMove {
            if let enemy = enemy {
                if diceHud.attackEnabled {
                    if !hasAttacks() { return }
                    diceHud.dice.attack--
                } else {
                    if !hasMagicAttacks() { return }
                    diceHud.dice.magic--
                }
                
                // is the enemy dead?
                if enemy.wasAttacked(hero, amount: attack, inLevel: inLevel) {
                    inLevel.replaceEnemyTileWithLootAtPosition(enemy.position.gridPoint(inLevel.levelData.squareSize.int32))
                }
            } else {
                if !hasMoves() { return }
                
                diceHud.dice.moves--

                if let loot = loot, lootToCalculate = loot.getLoot() {
                    if lootToCalculate is Gold {
                        gold += (lootToCalculate as! Gold).amount
                        print("Found gold")
                    } else if lootToCalculate is Card {
                        let card = lootToCalculate as! Card
                        attack += card.attack
                        defense += card.defense
                        health += card.health
                        print("Found Card")
                    } else {
                        fatalError("No Loot was matched to calculate!")
                    }
                }
            }
            hero.move(direction, enemy: enemy, loot: loot, inLevel: inLevel)
        }
        
        print("Moves Left: \(diceHud.dice.moves)---Attack Left: \(diceHud.dice.attack)---Magic Left: \(diceHud.dice.magic)")
        diceHud.setLabelData(gold, attack: attack, defense: defense, health: health)
    }
    
    var heroFaceLocation: CGPoint?
    var controller: GCController?
}
