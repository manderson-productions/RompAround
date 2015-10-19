//
//  LevelData.swift
//  RompAround
//
//  Created by Mark Anderson on 10/10/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import UIKit

enum PowerupType: String {
    case Card
}

enum Level: String {
    case Zero, One, Two, Three, Four
    
    func mapJSON() -> [String: AnyObject] {
        return Dictionary.jsonDictionaryFromResourceName(self.rawValue)!
    }
}

struct LevelData {
    let level: Level
    let squareSize: Int
    let gridWidth: Int = 32
    let gridHeight: Int = 32
    var mapData = [MapSquare]()

    init(level: Level, sceneSize: CGSize) {
        self.level = level
        
        // calculate the size from the min width/height
        let constraint: CGFloat = min(sceneSize.width, sceneSize.height)
        self.squareSize = Int(round(constraint / CGFloat(gridWidth)))
        
        if let json: [String: AnyObject] = Dictionary.jsonDictionaryFromResourceName("empty_map_32") {
            let emptyMap: [Int] = json["map"] as! [Int]
            for gridY in 0..<gridHeight{
                for gridX in 0..<gridWidth{
                    guard let square = MapSquare(rawValue: emptyMap[mapDataOffset(gridX, gridY)]) else {
                        fatalError("Invalid map data: \(emptyMap[mapDataOffset(gridX, gridY)]) found at \(gridX),\(gridY)")
                    }
                    mapData.append(square)
                }
            }
        }
    }
    
    subscript (x:Int, y:Int) -> MapSquare {
        get{
            return mapData[mapDataOffset(x,y)]
        }
        set{
            mapData[mapDataOffset(x, y)] = newValue
        }
    }
    
    private func mapDataOffset(x:Int,_ y:Int) -> Int {
        return x + y * gridWidth
    }
}

