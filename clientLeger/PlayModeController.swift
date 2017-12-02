//
//  PlayModeController.swift
//  clientLeger
//
//  Created by Marco on 2017-11-08.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class PlayModeController : UIViewController, SKSceneDelegate{
    
    var playMode : PlayMode;
    var mapObjectStruct : MapObjects!
    
    @IBOutlet weak var lpNameLabel: UILabel!
    @IBOutlet weak var rpNameLabel: UILabel!
    @IBOutlet weak var lpScoreLabel: UILabel!
    @IBOutlet weak var rpScoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var playScene : SKView!
    
    public static var goalsToWin = 3;
    var cameraNode : SKCameraNode?
    
    init() {
        playMode = PlayMode();
        super.init(nibName: "", bundle: nil)
        self.view.isMultipleTouchEnabled = true;
    }
    
    required init?(coder aDecoder: NSCoder) {
        playMode = PlayMode();
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let scene = playScene {
            scene.preferredFramesPerSecond = 30
            scene.showsFPS = true
            scene.showsNodeCount = true
        }
        setScene(mapObjectStruct)
        if (User.isAuthenticated) {
            lpNameLabel.text = User.getUsername();
        }
        print("Entering play mode");
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playMode.onSingleTap(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playMode.onTouchEnded(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        playMode.onSingleFingerSlide(touches)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        print("exiting play mode");
        if let scene = playScene.scene as? PlayModeScene {
            scene.removeAllChildren();
        }
        dismiss(animated: true, completion: nil)
    }
    
    func goBackFromOtherPlace() {
        print("exiting play mode");
        playScene.scene?.removeAllChildren();
        dismiss(animated: true, completion: nil)
        playScene.scene?.removeAllChildren()
        playScene.isPaused = true
    }
    
    @IBAction func togglePausePress(_ sender: UIButton) {
        if let playSceneThatExists : PlayModeScene = playScene.scene as? PlayModeScene{
            playSceneThatExists.togglePause()
        }
    }
    
    @IBAction func restartMap(_ sender: UIButton) {
        if let playSceneThatExists : PlayModeScene = playScene.scene as? PlayModeScene{
            playSceneThatExists.reloadMap()
        }
    }
    
    @IBAction func zoomPlusPress(_ sender: UIButton) {
        if let playSceneThatExists : PlayModeScene = playScene.scene as? PlayModeScene{
            if let camera = playSceneThatExists.camera{
                if (camera.xScale  > 0.5){
                    camera.setScale(camera.xScale - 0.25)
                }
            }
            else {
                let camera = SKCameraNode();
                camera.setScale(camera.xScale - 0.25)
                playSceneThatExists.addChild(camera)
                playSceneThatExists.camera = camera
            }
        }
    }
    
    @IBAction func zoomMinusPress(_ sender: UIButton) {
        if let playSceneThatExists : PlayModeScene = playScene.scene as? PlayModeScene{
            if let camera = playSceneThatExists.camera{
                if (camera.xScale < 1.75){
                    camera.setScale(camera.xScale + 0.25)
                }
            }
            else {
                let camera = SKCameraNode();
                camera.setScale(camera.xScale + 0.25)
                playSceneThatExists.addChild(camera)
                playSceneThatExists.camera = camera
            }
        }
    }
    
    func setScene(_ mapObjects : MapObjects){
        if let playSceneThatExists : PlayModeScene = playScene.scene as? PlayModeScene {
            playSceneThatExists.lpScore = lpScoreLabel
            playSceneThatExists.rpScore = rpScoreLabel
            playSceneThatExists.rpName = rpNameLabel
            playSceneThatExists.lpName = lpNameLabel
            playSceneThatExists.timeLabel = timeLabel
            playSceneThatExists.controller = self
            playSceneThatExists.frictionCoeff = mapObjects.frictionCoeff
            playSceneThatExists.restitutionCoeff = mapObjects.restitutionCoeff
            playMode.playScene = playSceneThatExists
            playSceneThatExists.playMode = playMode
            playSceneThatExists.goalLimit = PlayModeController.goalsToWin
            playSceneThatExists.arenaFloor = mapObjects.arenaFloor
            playSceneThatExists.borderWalls = mapObjects.borderWalls
            playSceneThatExists.goalSections = mapObjects.goalSections
            playSceneThatExists.editableItems = mapObjects.gameObjects
            
            playSceneThatExists.reloadMap()
        }
        else {
            print("‼️ You just tried to set Scene on a playScene that doesnt exist, get yourselft together !")
        }
    }
}
