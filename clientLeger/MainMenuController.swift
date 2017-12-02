//
//  MainMenuController.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-27.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import UIKit
import FileBrowser
import AEXML
import SpriteKit
import Alamofire

class MainMenuController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var modeEditionOnline: UIButton!
    
    
    @IBOutlet weak var disconnectButton: UIButton!
    var playVsAi: Bool = true;
    var scene: EditionModeScene?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (User.isAuthenticated) {
            modeEditionOnline.isEnabled = true;
            welcomeLabel.text = welcomeLabel.text! + User.getUsername() + "!";
        } else {
            welcomeLabel.text = "";
            modeEditionOnline.isEnabled = false;
        }
        if (User.getUsername().isEmpty) {
            disconnectButton.titleLabel?.text = "Connection";
        } else {
            disconnectButton.titleLabel?.text = "Déconnection";
        }
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        if (!SocketIOManager.sharedInstance.isConnected()) {
            User.logout();
            SocketIOManager.sharedInstance.closeConnection();
            self.performSegue(withIdentifier: "logOut", sender: nil)
        } else {
            Alamofire.request("https://log3900.herokuapp.com/user/signout/" + User.getUsername()).validate().responseJSON { response in
                User.logout();
                SocketIOManager.sharedInstance.closeConnection();
                self.performSegue(withIdentifier: "logOut", sender: nil)
            }
        }
        
    }
    
     @IBAction func PlayVsAi(_ sender: UIButton) {
        let fileBrowser = FileBrowser( allowEditing: true, showCancelButton: true);
        self.present(fileBrowser, animated: true, completion: nil)
        fileBrowser.didSelectFile = { (file: FBFile) -> Void in
            print(file.displayName)
            self.scene = self.getMapFile(file.displayName);
            self.playVsAi = true;
            // delay the segue
            let mainQueue = DispatchQueue.main;
            let deadLine = DispatchTime.now() + .milliseconds(600);
            mainQueue.asyncAfter(deadline: deadLine) {
                self.performSegue(withIdentifier: "PlayVsAI", sender: self);
            }
            
        }
    }
    
    @IBAction func PlayVsHuman(_ sender: UIButton) {
        let fileBrowser = FileBrowser( allowEditing: true, showCancelButton: true);
        self.present(fileBrowser, animated: true, completion: nil)
        fileBrowser.didSelectFile = { (file: FBFile) -> Void in
            print(file.displayName)
            self.scene = self.getMapFile(file.displayName);
            self.playVsAi = false;
            // delay the segue
            let mainQueue = DispatchQueue.main;
            let deadLine = DispatchTime.now() + .milliseconds(600);
            mainQueue.asyncAfter(deadline: deadLine) {
                self.performSegue(withIdentifier: "PlayVsAI", sender: self);
            }
            
        }
    }
    
    func getMapFile(_ mapName: String) -> EditionModeScene {
        let fileManage = FileManager.default
        if let dir : NSString = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first as! NSString) {
            do {
                let documentDirectory = try fileManage.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(mapName)
                let path: String = fileURL.absoluteString;
                //let path = Bundle.main.path(forResource: mapName, ofType: "xml");
                print("loading from " + path);
                guard
                    let data = try? Data(contentsOf: fileURL)
                    else {
                        return EditionModeScene();
                }
                do {
                    let xmlDoc = try AEXMLDocument(xml: data)
                    // load the map into the scene
                    return EditionModeUtils.loadMap(xmlDoc);
                }
                    
                catch {
                    print("\(error)")
                }
            } catch {
                print(error);
            }
        }
        
        return EditionModeScene();
    }
    
    @IBAction func quitGame(_ sender: UIButton) {
        if (SocketIOManager.sharedInstance.isConnected()) {
            SocketIOManager.sharedInstance.closeConnection();
            Alamofire.request("https://log3900.herokuapp.com/user/signout/" + User.getUsername()).validate().responseJSON { response in
                //User.logout();
                //SocketIOManager.sharedInstance.closeConnection();
                //self.performSegue(withIdentifier: "logOut", sender: nil)
            }
        }
        exit(0);
    }
    

    
    func prepareTransferStruct(_ scene: EditionModeScene) -> MapObjects{
        let floorCopy = scene.arenaFloor.copy() as! SKShapeNode;
        
        let floorPoints = scene.getPointArrayFromMorphPoints()
        
        var borderWalls : [BorderWallObject] = [BorderWallObject]()
        var goalSections : [GoalObject] = [GoalObject]()
        
        var editableItems : Set<GameObject> = []
        
        
        for editableItem in scene.editableItems {
            var newObject : GameObject?
            
            if editableItem is PortalObject {
                let currentPortal = editableItem as! PortalObject
                newObject = GameObjectFactory.copyPotal(currentPortal, true)
            }
            else if editableItem is AcceleratorObject {
                let currentAccelerator = editableItem as! AcceleratorObject
                newObject = GameObjectFactory.copyAccelerator(currentAccelerator)
            }
            else if editableItem is WallObject {
                let currentWall = editableItem as! WallObject
                newObject = GameObjectFactory.createWallObjectFromPoints(currentWall.startPoint, currentWall.endPoint)
            }
            
            if let newNonNullObject = newObject{
                editableItems.insert(newNonNullObject)
            }
        }
        
        for borderWall in scene.borderWalls {
            let bwCopy = GameObjectFactory.createBorderWallObjectFromPoints(borderWall.startPoint, borderWall.endPoint)
            borderWalls.append(bwCopy)
        }
        
        for goalSection in scene.goalSections {
            let gsCopy = GameObjectFactory.copyGoal(goalSection)
            //gsCopy.removeFromParent()
            goalSections.append(gsCopy)
        }
        
        return  MapObjects(borderWalls: borderWalls, goalSections: goalSections, arenaFloor: floorCopy, gameObjects: editableItems, floorPath: floorPoints, frictionCoeff: CGFloat(EditionModeController.friction), restitutionCoeff: CGFloat(EditionModeController.rebond), accellerationCoeff: CGFloat(EditionModeController.acceleration))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        SoundManager.playSimpleButtonPress();
        if (segue.identifier == "goToOfflineEdition" ) {
            SocketIOManager.sharedInstance.closeConnection();
            EditionModeController.setInitialConstants();
        } else if segue.identifier == "PlayVsAI", let playModeController = segue.destination as? PlayModeController {
            if (playVsAi) {
                playModeController.playMode = PlayMode()
            } else {
                playModeController.playMode = PlayMode();
                playModeController.playMode.singlePlayer = false;
            }
            
            playModeController.mapObjectStruct = prepareTransferStruct(self.scene!);
        }
    }
    
}
