//
//  Loot.swift
//  RompAround
//
//  Created by Mark Anderson on 10/18/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import Foundation
import SpriteKit

protocol Lootable {}

struct Gold: Lootable {
    let amount: Int
}

struct Card: Lootable {
    let info: String
    let attack: Int
    let defense: Int
    let health: Int
}