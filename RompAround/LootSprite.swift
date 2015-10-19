//
//  LootSprite.swift
//  RompAround
//
//  Created by Mark Anderson on 10/15/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import Foundation
import SpriteKit

class LootSprite: SKSpriteNode {

    enum LootType: Int {
        case Gold, Card, Random
        
        static func getRandom() -> LootType {
            return LootType(rawValue: (0...LootType.Random.rawValue - 1).randomInt)!
        }
        
        init(var type: LootType) {
            if type == .Random { type = LootType.getRandom() }
            self = type
        }
    }
    
    func getLoot() -> Lootable? {
        
        let json: [String: AnyObject] = Dictionary.jsonDictionaryFromResourceName("Zero")!
        let lootArray = (json["loot"] as! [[String: AnyObject]])
        
        switch type {
        case .Gold:
            for gold in lootArray {
                if (gold["type"] as! String) == "\(LootType.Gold)" {
                    let minValue = gold["amount_min"] as! Int
                    let maxValue = gold["amount_max"] as! Int
                    let randomGoldAmount = (minValue...maxValue).randomInt
                    return Gold(amount: randomGoldAmount)
                }
            }
        case .Card:
            for card in lootArray {
                if (card["type"] as! String) == "\(LootType.Card)" {
                    return Card(info: (card["info"] as! String), attack: (card["attack"] as! Int), defense: (card["defense"] as! Int), health: (card["health"] as! Int))
                }
            }
        default:
            return nil
        }
        return nil
    }

    let type: LootType
    
    init(color: UIColor, size: CGSize, type: LootType = .Random) {
        self.type = LootType(type: type)
        super.init(texture: nil, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}