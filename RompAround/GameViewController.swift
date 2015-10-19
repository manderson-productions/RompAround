//
//  GameViewController.swift
//  RompAround
//
//  Created by Mark Anderson on 10/10/15.
//  Copyright (c) 2015 manderson-productions. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        
        let levelData = LevelData(level: .Zero, sceneSize: skView.frame.size)
        let scene = LevelScene(levelData: levelData, size: skView.frame.size)
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill

        skView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
