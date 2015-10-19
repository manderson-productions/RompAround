//
//  DiceHUD.swift
//  RompAround
//
//  Created by Mark Anderson on 10/12/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

typealias Dice = (moves: Int, attack: Int, magic: Int)

class DiceHUD: GKEntity {
    let hud = SKNode()
    var numMovementDice = 2
    var numAttackDice = 1
    var numMagicAttackDice = 1
    let maxPossiblePerDie = 6
    
    var attackEnabled = true
    var magicEnabled = false
    
    var goldLabel = SKLabelNode()
    var healthLabel = SKLabelNode()
    var attackLabel = SKLabelNode()
    var defenseLabel = SKLabelNode()
    
    var dice = Dice(moves: 0, attack: 0, magic: 0)

    func toggleAttackType() {
        attackEnabled = !attackEnabled
        magicEnabled = !magicEnabled
        print("Attack Enabled: \(attackEnabled) Magic Enabled: \(magicEnabled)")
    }
    
    func rollDice() {
        var dice = Dice(moves: 0, attack: 0, magic: 0)
        for _ in 0..<numMovementDice {
            // dice possibilities are 1 - 6 for each
            dice.moves += (1...maxPossiblePerDie).randomInt
        }
        
        for _ in 0..<numAttackDice {
            // dice possibilities are 1 - 6 for each
            dice.attack += (1...maxPossiblePerDie).randomInt
        }
        for _ in 0..<numMagicAttackDice {
            // dice possibilities are 1 - 6 for each
            dice.magic += (1...maxPossiblePerDie).randomInt
        }
        print("Dice Rolled. Moves Left: \(dice.moves)---Attack Left: \(dice.attack)---Magic Left: \(dice.magic)")
        self.dice = dice
    }

    func setLabelData(gold: Int, attack: Int, defense: Int, health: Int) {
        goldLabel.text = "Gold: \(gold)"
        attackLabel.text = "Attack Power: \(attack)"
        defenseLabel.text = "Defense Amount: \(defense)"
        healthLabel.text = "Health: \(health)"
    }
    
    func setupLabels() {
        setLabelData(0, attack: 0, defense: 0, health: 0)
        hud.addChild(goldLabel)
        hud.addChild(healthLabel)
        hud.addChild(attackLabel)
        hud.addChild(defenseLabel)
        
        goldLabel.position = CGPoint.zero
        goldLabel.color = SKColor.orangeColor()
        healthLabel.position = CGPoint(x: 0.0, y: 50.0)
        healthLabel.color = SKColor.orangeColor()
        attackLabel.position = CGPoint(x: 0.0, y: 100.0)
        attackLabel.color = SKColor.orangeColor()
        defenseLabel.position = CGPoint(x: 0.0, y: 150.0)
        defenseLabel.color = SKColor.orangeColor()
    }

    override init() {
        hud.name = "DiceHUD"
        super.init()
        setupLabels()
    }
}
