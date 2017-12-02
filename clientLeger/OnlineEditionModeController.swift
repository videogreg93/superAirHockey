//
//  OnlineEditionModeController.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-11-14.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import UIKit
import AEXML
import Alamofire

class OnlineEditionModeController: EditionModeController {
    
    // When loading a map
    static var loadedMap = "";
    static var mapName = "";
    static var mapId = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Enterting Online Edition Mode");
        // Reset the object Counter
        GameObject.resetGameIdCount();
        SocketIOManager.sharedInstance.establishConnection();
        if (!OnlineEditionModeController.loadedMap.isEmpty) {
            print("Were gonna load this map!");
            //loadedMap = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" + loadedMap;
            print(OnlineEditionModeController.loadedMap);
            
            do {
                
                let xmlMap = try AEXMLDocument(xml: OnlineEditionModeController.loadedMap, encoding: String.Encoding.utf8, options: AEXMLOptions())
                loadMap(xmlMap);
                // Setup selection connections and others
                let scene = self.editionModeGameScene.scene as? EditionModeScene;
                SocketIOManager.sharedInstance.setUpSelectionCallbacks { (id) -> Void in
                    EditionModeUtils.updateSelectionFromNodeId(editScene: scene!, id: id);
                }
                SocketIOManager.sharedInstance.setUpDeselectionCallbacks { (id) -> Void in
                    EditionModeUtils.removeSelectionFromNodeId(editScene: scene!, id: id);
                }
                SocketIOManager.sharedInstance.setupMovingObjectsCallbacks{ (id, posX, posY, angle, scale) -> Void in
                    EditionModeUtils.updateNodeFromId(editScene: scene!, id: id, posX: posX, posY: posY, angle: angle, scale: scale);
                    self.updateMapOnline();
                }
                // Setup adding new objects
                SocketIOManager.sharedInstance.setupOnAddAccel { (posX, posY) -> Void in
                    let accelerator : AcceleratorObject = GameObjectFactory.createAcceleratorObject(posX, posY)
                    SoundManager.playPlaceItem();
                    scene?.addNode(accelerator);
                    self.updateMapOnline();
                    //print("GameObject Count: " + String(GameObject.idCount));
                }
                SocketIOManager.sharedInstance.setupOnAddMur { (startX, startY, endX, endY) -> Void in
                    if (!EditionModeUtils.wallWithPositionAlreadyExists(editScene: scene!,
                                                                        startX: startX, startY: startY,
                                                                        endX  : endX,   endY  : endY)) {
                        print("Someone else added a wall");
                        let start: CGPoint = CGPoint(x: startX, y: startY);
                        let end  : CGPoint = CGPoint(x: endX,   y: endY);
                        let mur: WallObject = GameObjectFactory.createWallObjectFromPoints(start,end);
                        SoundManager.playPlaceItem();
                        scene?.addNode(mur);
                        self.updateMapOnline();
                    } else {
                        print("This is just our wall");
                    }
                }
                SocketIOManager.sharedInstance.setupOnAddPortails { (posX1, posY1, posX2, posY2) -> Void in
                    let portail1: PortalObject = GameObjectFactory.createPortalObject(posX1, posY1);
                    let portail2: PortalObject = GameObjectFactory.createPortalObject(posX2, posY2);
                    portail1.linkedPortalId = portail2.id;
                    portail1.linkedPortal = portail2;
                    portail2.linkedPortalId = portail1.id;
                    portail2.linkedPortal = portail1;
                    SoundManager.playPlaceItem();
                    scene?.addNode(portail1);
                    scene?.addNode(portail2);
                    self.updateMapOnline();
                }
                // Setup deletion
                SocketIOManager.sharedInstance.setupDeleteObjectsOnline { (id) -> Void in
                    scene?.removeNodeWithId(id);
                    // reset bigestGameId
                    let objects = scene?.editableItems;
                    var biggestId = -1;
                    for node in objects! {
                        if (node.id >= biggestId) {
                            biggestId = node.id;
                        }
                    }
                    GameObject.resetGameIdCount();
                    if (biggestId > GameObject.idCount) {
                        GameObject.idCount = biggestId;
                    }
                    self.updateMapOnline();
                }
                // setup duplication
                SocketIOManager.sharedInstance.setupOnDupAccel { (posX, posY, angle, scale) -> Void in
                    let accel: AcceleratorObject = GameObjectFactory.createAcceleratorObject(posX, posY);
                    accel.zRotation = angle;
                    accel.setScale(scale);
                    SoundManager.playPlaceItem();
                    scene?.addNode(accel);
                    self.updateMapOnline();
                }
                SocketIOManager.sharedInstance.setupOnDupMur { (posX, posY, angle, scale) -> Void in
                    let mur: WallObject = GameObjectFactory.createWallObject(posX, posY, angle, scale);
                    SoundManager.playPlaceItem();
                    scene?.addNode(mur);
                    self.updateMapOnline();
                }
                SocketIOManager.sharedInstance.setupOnDupPortails { (posX1, posY1, angle1, scale1, posX2, posY2, angle2, scale2) -> Void in
                    let portal1: PortalObject = GameObjectFactory.createPortalObject(posX1, posY1, true, angle1, scale1);
                    let portal2: PortalObject = GameObjectFactory.createPortalObject(posX2, posY2, false, angle2, scale2);
                    portal1.linkedPortal = portal2;
                    portal1.linkedPortalId = portal2.id;
                    portal2.linkedPortal = portal1;
                    portal2.linkedPortalId = portal1.id;
                    scene?.addNode(portal1);
                    scene?.addNode(portal2);
                    self.updateMapOnline();
                }
                // setup morph points
                SocketIOManager.sharedInstance.setupOnMorphPointsMoved { (index, posX, posY) -> Void in
                    //let temp = MorphBorderMode((scene)!);
                    scene?.morphPoints[index].position = CGPoint(x: posX, y: posY);
                    //temp.updatePointFromOnline(index, posX, posY);
                    // set the scene morph points correctly
                    for index in 0...7 {
                        EditionModeUtils.updateMorphPointCoords((scene?.morphPoints[index].position)!, index, scene!);
                    }
                    
                    // update goal positions
                    EditionModeUtils.adjustGoals(scene!);
                    self.updateMapOnline();
                }
                SocketIOManager.sharedInstance.setupOnSelectionControl { (canSelect) -> Void in
                    EditionModeController.canSelectMorphPoints = canSelect;
                    if (canSelect) {
                        let editScene : EditionModeScene = (self.editionModeGameScene.scene as! EditionModeScene)
                        editScene.makeMorphPointsVisible(true)
                        self.editMode = MorphBorderMode(editScene);
                        self.editMode.onAssign();
                        //self.changeCurrentModeIconImage(sender);
                    }
                    
                }
                SocketIOManager.sharedInstance.setupOnDeselectionMorphPoints {
                    EditionModeController.canSelectMorphPoints = true;
                }
                // setup constants
                SocketIOManager.sharedInstance.setupOnConstantsChange { (friction, rebond, accel) -> Void in
                    EditionModeController.setConstants(Float(accel), Float(friction), Float(rebond));
                }
                    
                
                
            } catch {
                print("Error loading map!");
                print("\(error)");
            }
        }

        // Do any additional setup after loading the view.
        let scene = self.editionModeGameScene.scene as? EditionModeScene;
        print("GameObject Count: " + String(GameObject.idCount));
        print("editable items Count: " + (scene?.editableItems.count.description)!);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func goBackToMainMenu(_ sender: UIButton) {
       // SocketIOManager.sharedInstance.closeConnection();
        SocketIOManager.sharedInstance.deselectObjects(OnlineEditionModeController.mapName) {
            
        }
        OnlineEditionModeController.loadedMap = "";
        OnlineEditionModeController.mapName = "";
        let scene = editionModeGameScene.scene as? EditionModeScene;
        scene?.clearScene();
        print("come on unwind");
        self.performSegue(withIdentifier: "quitOnlineEditMode", sender: self)
        //SocketIOManager.sharedInstance.closeConnection();
        //super.goBackToMainMenu(sender);
    }
    
    override func xFieldDidChange(_ sender: UITextField) {
        super.xFieldDidChange(sender);
        let scene = editionModeGameScene.scene as! EditionModeScene;
        let object: GameObject = (scene.selectedItems.first)!;
        SocketIOManager.sharedInstance.moveObjectOnline(mapName: OnlineEditionModeController.mapName
            , gameObject: object);
    }
    
    override func yFieldDidChangeEnd(_ sender: UITextField) {
        super.yFieldDidChangeEnd(sender);
        let scene = editionModeGameScene.scene as! EditionModeScene;
        let object: GameObject = (scene.selectedItems.first)!;
        SocketIOManager.sharedInstance.moveObjectOnline(mapName: OnlineEditionModeController.mapName
            , gameObject: object);
    }
    
    override func scaleFieldDidChangeEnd(_ sender: UITextField) {
        super.scaleFieldDidChangeEnd(sender);
        let scene = editionModeGameScene.scene as! EditionModeScene;
        let object: GameObject = (scene.selectedItems.first)!;
        SocketIOManager.sharedInstance.moveObjectOnline(mapName: OnlineEditionModeController.mapName
            , gameObject: object);
    }
    
    override func rotationFieldDidChangeEnd(_ sender: UITextField) {
        super.rotationFieldDidChangeEnd(sender);
        let scene = editionModeGameScene.scene as! EditionModeScene;
        let object: GameObject = (scene.selectedItems.first)!;
        SocketIOManager.sharedInstance.moveObjectOnline(mapName: OnlineEditionModeController.mapName
            , gameObject: object);
    }
    
    func updateMapOnline() {
            //mapName = mapName + ".xml";
            let xmlFile: String = self.getXmlStringForSaving(OnlineEditionModeController.mapName);
            // Upload file to server
            let parameters: Parameters = [
                "_id": OnlineEditionModeController.mapId,
                "map" : xmlFile
            ]
            Alamofire.request("https://log3900.herokuapp.com/map", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
                if let json = response.result.value {
                    print("map has been updated");
                } else {
                    print("‼️ Could not parse response as JSON");
                }
            }
    }
    

    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        print("Unwinding from options menu thingy");
        SocketIOManager.sharedInstance.changeConstantsOnline(friction: EditionModeController.friction, rebond: EditionModeController.rebond, accel: EditionModeController.acceleration)
    }

    override func performTutorialSegue() {
        if (editMode.canChangeEditMode()) {
            self.performSegue(withIdentifier: "onlineToTutorialSegue", sender: self);
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
