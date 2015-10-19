//
//  Extensions.swift
//  RompAround
//
//  Created by Mark Anderson on 10/11/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import GameplayKit
import SpriteKit

extension Array {
    mutating func push(element: Element) {
        self.insert(element, atIndex: 0)
    }
}

extension Int {
    var int32: Int32 {
        return Int32(self)
    }
}

extension Int32 {
    var int: Int {
        return Int(self)
    }
}

extension CGFloat {
    var double : Double {
        return Double(self)
    }
}

extension CGPoint {
    
    func gridPoint(squareSize:Int32) -> int2{
        let gx = Int32(round(x))/squareSize
        let gy = Int32(round(y))/squareSize
        return int2(gx,gy)
    }
    
    func halfWayPointTo(destination:CGPoint) -> CGPoint{
        return CGPoint(x: (x+destination.x) / 2.0, y: (y+destination.y) / 2.0)
    }
    
    func lengthOfLineTo(destination:CGPoint)->CGFloat{
        let dx = x-destination.x
        let dy = y-destination.y
        
        return sqrt(dx*dx+dy*dy)
    }
    
    func angleOfLineTo(destination end:CGPoint) -> CGFloat {
        
        let hypotenuse = self.lengthOfLineTo(end)
        
        if end.x > self.x {
            let opposite = self.y - end.y
            
            return asin(opposite/hypotenuse)
        } else {
            
            if end.y > self.y {
                let opposite = end.x - self.x
                
                return asin(opposite/hypotenuse) - CGFloat(M_PI / 2.0)
            } else {
                let adjactent = end.x - self.x
                return acos(adjactent/hypotenuse)
            }
        }
    }
    
    func pathForArrowTo(destination end:CGPoint) -> CGPath {
        let tailLength = Double(lengthOfLineTo(end) / 3.0)
        let flareOut =  M_PI / 4.0
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, self.x, self.y)
        CGPathAddLineToPoint(path, nil, end.x, end.y)
        
        let theta = Double(angleOfLineTo(destination: end))
        
        var arrowHead = CGPoint(x: end.x.double - cos(theta-flareOut) * tailLength, y: end.y.double + sin(theta-flareOut) * tailLength)
        CGPathAddLineToPoint(path,nil,arrowHead.x,arrowHead.y)
        CGPathMoveToPoint(path, nil, end.x, end.y)
        
        arrowHead = CGPoint(x: end.x.double - cos(theta+flareOut) * tailLength, y: end.y.double + sin(theta+flareOut) * tailLength)
        CGPathAddLineToPoint(path,nil,arrowHead.x,arrowHead.y)
        
        return path
    }
    
    func projectPoint(towardsPoint end:CGPoint, toDistance:CGFloat) -> CGPoint{
        let theta = Double(angleOfLineTo(destination: end))
        
        return CGPoint(x: x.double - cos(theta+M_PI) * toDistance.double, y: y.double + sin(theta+M_PI) * toDistance.double)
    }
}

@available(OSX 10.11, iOS 9, *)
extension GKGridGraph{
    func visualise(forLevel:LevelData) -> SKNode {
        let debugNode = SKNode()
        
        for y in 0..<forLevel.gridHeight {
            for x in 0..<forLevel.gridWidth {
                if let graphNode = nodeAtGridPosition(int2(Int32(x),Int32(y))){
                    let debugGraphNode = SKShapeNode(circleOfRadius: CGFloat(forLevel.squareSize/8))
                    
                    let nodePosition = CGPoint(x: x*forLevel.squareSize, y: y*forLevel.squareSize)
                    
                    debugGraphNode.position = nodePosition
                    debugGraphNode.strokeColor = SKColor.blackColor()
                    debugGraphNode.fillColor = SKColor.whiteColor()
                    debugGraphNode.zPosition = 10000
                    debugNode.addChild(debugGraphNode)
                    for connectedNode in graphNode.connectedNodes {
                        if let connectedNode = connectedNode as? GKGridGraphNode {
                            let destination = CGPoint(x: connectedNode.gridPosition.x.int*forLevel.squareSize, y: connectedNode.gridPosition.y.int*forLevel.squareSize)
                            
                            let length = CGFloat(forLevel.squareSize/2) - (CGFloat(forLevel.squareSize)/16.0)
                            
                            let linkSprite = SKShapeNode(path: nodePosition.pathForArrowTo(destination: nodePosition.projectPoint(towardsPoint: destination, toDistance: length)))
                            linkSprite.strokeColor = SKColor.blackColor()
                            
                            linkSprite.zPosition = 9999
                            debugNode.addChild(linkSprite)
                        }
                    }
                }
            }
        }
        
        
        return debugNode
    }
}

extension Dictionary {
    static func jsonDictionaryFromResourceName(resourceName: String) -> Dictionary? {
        let resourcePath = NSBundle.mainBundle().pathForResource(resourceName, ofType: ".json")!
        let data = NSData(contentsOfFile: resourcePath)!
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? Dictionary
        } catch {
            return nil
        }
    }
}

extension Range {
    var randomInt: Int {
        get {
            var offset = 0
            
            if (startIndex as! Int) < 0   // allow negative ranges
            {
                offset = abs(startIndex as! Int)
            }
            
            let mini = UInt32(startIndex as! Int + offset)
            let maxi = UInt32(endIndex   as! Int + offset)
            
            return Int(mini + arc4random_uniform(maxi - mini)) - offset
        }
    }
}

