//
//  LevelScene.swift
//  RompAround
//
//  Created by Mark Anderson on 10/10/15.
//  Copyright © 2015 manderson-productions. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameController

class LevelScene: SKScene {
    
    // MARK: Category Bitmasks
    
    static let playerCategory: UInt32 = 0x1 << 0
    static let lootCategory: UInt32 = 0x1 << 1
    
    let debug = false
    
    var gridGraph: GKGridGraph = GKGridGraph()
    var levelData: LevelData!
    var layers = [SKNode]()
    let defaultPlayer = Player()
        
    enum WorldLayer : Int {
        case BelowCharacter = 0, Character, AboveCharacter, Debug
        
        var cgFloat: CGFloat {
            return CGFloat(self.rawValue)
        }
        static func count() -> Int {
            return WorldLayer.Debug.rawValue + 1
        }
        static func layerFromMapSquare(mapSquare: MapSquare) -> WorldLayer {
            switch mapSquare {
            case .Ground:
                return .BelowCharacter
            case .Wall:
                return .BelowCharacter
            case .Destructable:
                return .BelowCharacter
            case .Enemy:
                return .Character
            case .Player:
                return .Character
            case .Loot:
                return .Character
            case .Empty:
                return .BelowCharacter
            }
        }
    }
    
    init(levelData: LevelData, size: CGSize) {
        self.levelData = levelData
        self.gridGraph = GKGridGraph(fromGridStartingAt: int2(0,0), width: Int32(levelData.gridWidth), height: Int32(levelData.gridHeight), diagonalsAllowed: false)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(UInt64(4.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            self.configureGameControllers()
        })
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = .Right
        self.view?.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeLeft.direction = .Left
        self.view?.addGestureRecognizer(swipeLeft)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeUp.direction = .Up
        self.view?.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeDown.direction = .Down
        self.view?.addGestureRecognizer(swipeDown)
        
        begin()
    }
    
    func addNode(node: SKNode, atWorldLayer layer: WorldLayer) {
        let layerNode = layers[layer.rawValue]
        layerNode.addChild(node)
    }
    
    func childNode(nodeName: String, atWorldLayer layer: WorldLayer) -> SKNode? {
        let layerNode = layers[layer.rawValue]
        return layerNode.childNodeWithName(nodeName)
    }

    func enemyNodesInLevel() -> [EnemySprite] {
        let enemies = layers[WorldLayer.Character.rawValue].children.filter({ $0.name == MapSquare.Enemy.name }) as! [EnemySprite]
        return enemies
    }
    
    func lootNodesInLevel() -> [LootSprite] {
        let loot = layers[WorldLayer.Character.rawValue].children.filter({ $0.name == MapSquare.Loot.name }) as! [LootSprite]
        return loot
    }
    
    func processTilesWithBlock(block:(levelData:LevelData, tile:MapSquare, gridX:Int, gridY:Int) -> Void){
        for gridY in 0..<levelData.gridHeight {
            for gridX in 0..<levelData.gridWidth {
                block(levelData: levelData, tile: levelData[gridX,gridY], gridX: gridX, gridY: gridY)
            }
        }
    }
    
    func addLevelTiles() {
        processTilesWithBlock { [weak self](levelData, tile, gridX, gridY) -> Void in
            //Create a sprite for the square
            if let sprite = tile.spriteForSquare(inLevel: levelData, atGridX:gridX, gridY:gridY) {
                if let layerNode = self?.layers[WorldLayer.layerFromMapSquare(tile).rawValue] {
                    if tile == .Player {
                        // assign the default player to the player
                        if let strongself = self {
                            strongself.defaultPlayer.hero = sprite.childNodeWithName("\(MapSquare.Player)") as! PlayerSprite
                            strongself.defaultPlayer.diceHud.hud.position = CGPoint(x: strongself.size.width - 200, y: 0.0)
                            strongself.addNode(strongself.defaultPlayer.diceHud.hud, atWorldLayer: LevelScene.WorldLayer.AboveCharacter)
                            print("Hero Added: \(strongself.defaultPlayer.hero)")
                        }
                    }

                    for child in sprite.children {
                        child.removeFromParent()
                        child.position = sprite.position
                        layerNode.addChild(child)
                    }
                    layerNode.addChild(sprite)
                }
            }
            switch tile {
            case .Wall, .Empty:
                let nodeToRemove = self?.gridGraph.nodeAtGridPosition(int2(gridX.int32, gridY.int32))
                self?.gridGraph.removeNodes([nodeToRemove!])
            default:
                break
            }
        }
    }
    
    func addWorldNode() -> SKNode {
        let world = SKNode()
        world.name = "World"
        world.position = CGPoint(x: levelData.squareSize / 2, y: levelData.squareSize / 2)
        addChild(world)
        return world
    }
    
    func addWorldLayerNodes(parentNode: SKNode) {
        for i in 0..<WorldLayer.count() {
            let layerEnum = WorldLayer(rawValue: i)!
            let layerNode = SKNode()
            layerNode.name = "\(layerEnum)"
            layerNode.zPosition = layerEnum.cgFloat
            layers.append(layerNode)
            parentNode.addChild(layerNode)
        }
    }

    func replaceEnemyTileWithLootAtPosition(enemyPosition: int2) {
        var tile = levelData![enemyPosition.x.int, enemyPosition.y.int]
        tile = MapSquare.Loot
        if let sprite = tile.spriteForSquare(inLevel: self.levelData, atGridX: enemyPosition.x.int, gridY: enemyPosition.y.int) {
            let layerNode = layers[WorldLayer.layerFromMapSquare(tile).rawValue]
            for child in sprite.children {
                child.removeFromParent()
                child.position = sprite.position
                layerNode.addChild(child)
            }
            layerNode.addChild(sprite)
        }
    }
//    func addPlayer() {
//        processTilesWithBlock { [weak self] (levelData, tile, gridX, gridY) -> Void in
//            if tile == .Player {
//                let playerNode = PlayerSprite(color: tile.color, size: CGSize(width: levelData.squareSize, height: levelData.squareSize))
//                self?.addNode(playerNode, atWorldLayer: .Character)
//            }
//        }
//    }
    
//    func addLoot() {
//        var validTilesForLoot = [int2]()
//        processTilesWithBlock { (levelData, tile, gridX, gridY) -> Void in
//            if tile == .Ground {
//                validTilesForLoot.append(int2(x: gridX.int32, y: gridY.int32))
//            }
//        }
//        
//        let map = levelData.level.mapJSON()
//        if let powerupsArray = map["powerups"] as? [[String: AnyObject]] {
//            for powerup in powerupsArray {
//                
//                let powerupNode: SKSpriteNode
//                
//                let randomValidTile: int2 = validTilesForLoot[Int(arc4random_uniform(UInt32(validTilesForLoot.count)))]
//                
//                let powerupType = PowerupType(rawValue: powerup["type"] as! String)!
//                switch powerupType {
//                case .Card:
//                    powerupNode = CardSprite(attack: powerup["attack"] as! Int, health: powerup["health"] as! Int, info: powerup["info"] as! String, size: CGSize(width: levelData.squareSize, height: levelData.squareSize))
//                }
//                
//                addNode(powerupNode, atWorldLayer: .Character)
//            }
//        }
//    }
    
    private func begin() {
        removeAllChildren()

        let worldNode = addWorldNode()
        addWorldLayerNodes(worldNode)
        addLevelTiles()
    }
    
        override func update(currentTime: NSTimeInterval) {
            
            for layer in layers {
                layer.enumerateChildNodesWithName("//*", usingBlock: { (child, stop) -> Void in
                    if let updateable = child as? UpdateableLevelEntity {
                        updateable.update(currentTime, inLevel: self)
                    }
                })
            }
        }
    
    // MARK: Controller Stuff
    
    func configureGameControllers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "gameControllerDidConnect:", name: GCControllerDidConnectNotification, object: nil)
        notificationCenter.addObserver(self, selector: "gameControllerDidDisconnect:", name: GCControllerDidDisconnectNotification, object: nil)
        
        configureConnectedGameControllers()
        
        GCController.startWirelessControllerDiscoveryWithCompletionHandler(nil)
    }
    
    func configureConnectedGameControllers() {
        // TODO: Horrendous fucking bug with the Extended Gamepad showing up because of the simulator
        let gameControllers = GCController.controllers().filter { $0.vendorName == "Remote" }
        
        print("game controllers: \(gameControllers)")
        for controller in gameControllers {
            let playerIndex = controller.playerIndex
            if playerIndex == GCControllerPlayerIndex.IndexUnset {
                continue
            }
            
            assignPresetController(controller, toIndex: playerIndex.rawValue)
        }
        
        for controller in gameControllers {
            let playerIndex = controller.playerIndex
            if playerIndex != GCControllerPlayerIndex.IndexUnset {
                continue
            }
            
            assignUnknownController(controller)
        }
    }
    
    func gameControllerDidConnect(notification: NSNotification) {
        let controller = notification.object as! GCController
        let playerIndex = controller.playerIndex
        if playerIndex == GCControllerPlayerIndex.IndexUnset {
            assignUnknownController(controller)
        }
        else {
            assignPresetController(controller, toIndex: playerIndex.rawValue)
        }
    }
    
    func gameControllerDidDisconnect(notification: NSNotification) {
        let controller = notification.object as! GCController
        if defaultPlayer.controller == controller {
            defaultPlayer.controller = nil
        }
    }
    
    func assignUnknownController(controller: GCController) {
        if defaultPlayer.controller == nil {
            controller.playerIndex = GCControllerPlayerIndex(rawValue: 0)!
            configureController(controller, forPlayer: defaultPlayer)
        }
    }
    
    func assignPresetController(controller: GCController, toIndex index: Int) {
        if defaultPlayer.controller != nil && defaultPlayer.controller != controller {
            assignUnknownController(controller)
            return
        }
        
        configureController(controller, forPlayer: defaultPlayer)
    }
    
    func configureController(controller: GCController, forPlayer player: Player) {
        
//        let directionPadMoveHandler: GCControllerDirectionPadValueChangedHandler = { dpad, x, y in
//            let length = hypotf(x, y)
//            if length > 0.0 {
//                print("\(trunc(dpad.up.value)) \(trunc(dpad.down.value)) \(trunc(dpad.left.value)) \(trunc(dpad.right.value))")
//                // move the character
////                player.hero.move(Direction.directionFromSwipe(dpad.up.value, down: dpad.down.value, left: dpad.left.value, right: dpad.right.value), inLevel: self)
//            }
//        }
        
        player.controller = controller

        let fireButtonHandler: GCControllerButtonValueChangedHandler = { [weak self] button, value, pressed in
            if let strongself = self {
                if pressed {
                    // we can still roll the dice if there are attacks/magic, the player will just forfeit his turn
                    if !strongself.defaultPlayer.hasMoves() {
                        strongself.defaultPlayer.diceHud.rollDice()
                    } else {
                        // player has moves left, this toggles the attacks/magic
                        strongself.defaultPlayer.diceHud.toggleAttackType()
                    }
                    print("Action Button Pressed")
                } else {
                    print("Action Button UNPRESSED")
                }
            }
        }
        
        print("GAMEPAD: \(controller.description)")
        controller.microGamepad?.buttonA.valueChangedHandler = fireButtonHandler
        controller.microGamepad?.buttonX.valueChangedHandler = fireButtonHandler
    }
    
    func swiped(gesture: UISwipeGestureRecognizer) {
        let moveOrAttackDirection: Direction
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.Up:
            moveOrAttackDirection = Direction(x: 0, y: 1)
        case UISwipeGestureRecognizerDirection.Down:
            moveOrAttackDirection = Direction(x: 0, y: -1)
        case UISwipeGestureRecognizerDirection.Left:
            moveOrAttackDirection = Direction(x: -1, y: 0)
        case UISwipeGestureRecognizerDirection.Right:
            moveOrAttackDirection = Direction(x: 1, y: 0)
        default:
            moveOrAttackDirection = Direction(x: 0, y: 0)
            print("BLAHAHAHAH")
        }
        defaultPlayer.moveOrAttack(moveOrAttackDirection, inLevel: self)
    }
}