//
//  ViewEditModeLobbiesController.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-28.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import UIKit
import Alamofire
import SpriteKit
import AEXML
import iCarousel



class ViewEditModeLobbiesController: UIViewController, UITableViewDataSource, UITableViewDelegate, iCarouselDataSource, iCarouselDelegate {
    var mapList: [Dictionary<String, Any>] = [Dictionary<String, Any>]();
    var currentlySelectedCell: Int?;
    
    @IBOutlet weak var mapListTable: UITableView!
    @IBOutlet weak var joinMapButton: UIButton!
    @IBOutlet weak var deleteMapButton: UIButton!
    @IBOutlet weak var mapNameLabel: UILabel!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapPreviewView: SKView!;
    var scene: EditionModeScene?;
    
    @IBOutlet weak var carousel: iCarousel!
    var scenes = [EditionModeScene]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressIndicator.startAnimating();
        Alamofire.request("https://log3900.herokuapp.com/map").validate().responseJSON { response in
            if let json = response.result.value {
                self.progressIndicator.stopAnimating();
                self.mapList = (json as? [Dictionary<String, Any>])!;
                print(self.mapList[0]);
                self.mapListTable.reloadData();
                
                // connect socket right away
                SocketIOManager.sharedInstance.establishConnection();
                
                //print(json);
                
                self.carousel.type = .cylinder;
                
                // create the scenes
                for map in self.mapList {
                    let temp = SKScene(fileNamed: "EditionMode") as! EditionModeScene;
                    do {
                        let xmlMap = try AEXMLDocument(xml: map["map"] as! String, encoding: String.Encoding.utf8, options: AEXMLOptions())
                        self.loadMap(xmlMap,temp);
                    } catch {
                        print("\(error)")
                    }
                    if let camera = temp.camera {
                        camera.setScale(2);
                    } else {
                        print("Could not obtain camera");
                    }
                    self.scenes.append(temp);
                    
                }
                self.carousel.reloadData();
                self.joinMapButton.isEnabled = true;
                self.deleteMapButton.isEnabled = true;
                
            } else {
                print("‼️ Could not parse response as JSON");
            }
        }
        mapNameLabel.text = "";
        scene = mapPreviewView.scene as! EditionModeScene;
        // dezoom to see actual map
        if let camera = scene?.camera {
            camera.setScale(2);
        } else {
            print("Could not obtain camera");
        }
        
        // init carousel
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK Table functions
    
    /*
     Function that tells the tableviews how many rows they have
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows: Int = mapList.count
            return numberOfRows
    }
    
    /*
     Function that tells the tableviews how to show their cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        // Fetch mapName
        let mapName: String = mapList[indexPath.row]["name"] as! String;
        // Set table cell text to username
        cell.textLabel?.text = mapName
        cell.detailTextLabel?.text = "testing";
        return cell
    }
    
    // Change selected map when clicking on a cell
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        currentlySelectedCell = indexPath.row;
        joinMapButton.isEnabled = true;
        let map = mapList[indexPath.row];
        mapNameLabel.text = map["name"] as? String;
        // load map into map preview
        getMap();
        
        // hm....
         self.carousel.reloadData();
        
        
    }
    
    //MARK: Button functions
    @IBAction func goBackToMainMenu(_ sender: UIButton) {
        SoundManager.playSimpleButtonPress();
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteMap(_ sender: UIButton) {
        if let mapNumber: Int = carousel.currentItemIndex {
            let map = mapList[mapNumber];
            let mapId: String = map["_id"] as! String;
            let mapName: String = map["name"] as! String;
            Alamofire.request("https://log3900.herokuapp.com/map/" + mapName).validate().responseJSON { response in
                if let json = response.result.value {
                    print(json);
                     let jsonResponse = json as? [Dictionary<String, Any>];
                    let owner: String = (jsonResponse![0]["holderName"] as? String)!;
                    if (owner != User.getUsername()) {
                        EditionModeUtils.showErrorMessage("Désolez, vous ne pouvez pas supprimer la carte de " + owner, self);
                    } else {
                        // Ask for confirmation, then delete map
                        let alertController = UIAlertController(title: "Supprimer carte",
                                                                message: "Voulez-vous supprimer la carte " + mapName + "?",
                                                                preferredStyle: UIAlertControllerStyle.alert);
                        let OkAction = UIAlertAction(title: "Delete Map", style: .default ) { (action) -> Void in
                            Alamofire.request("https://log3900.herokuapp.com/map/" + mapId, method: .delete).validate().responseString { response in
                                if response.result.value != nil {
                                    print(response);
                                    self.mapList.remove(at: mapNumber);
                                    self.mapListTable.reloadData();
                                    EditionModeUtils.showErrorMessage("Carte Supprimée", self, "Supprimer");
                                    SoundManager.playSaveMap();
                                    self.carousel.removeItem(at: mapNumber, animated: true);
                                } else {
                                    EditionModeUtils.showErrorMessage("Il y a eu une erreur en supprimant la carte", self);
                                }
                            }
                        }
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel ) { (action) -> Void in
                            
                        }
                        alertController.addAction(OkAction);
                        alertController.addAction(cancelAction);
                        self.present(alertController, animated: true, completion: nil)                    }
                }
                
            }
        }
    }
    
     @IBAction func joinMap(_ sender: UIButton) {
        if let mapNumber: Int = carousel.currentItemIndex {
            let map = mapList[mapNumber];
            let mapId: String = map["_id"] as! String;
            let mapName: String = map["name"] as! String
            //let password: String = map["password"] as! String;
            var password: String? = map["password"] as? String;
            if let pw = password {
                print ("password " + password!);
                if (!pw.isEmpty) {
                    // ask user for the password
                    showPasswordDialog(pw, mapName, mapId);
                } else {
                    enterMap(mapName, mapId)
                }
            }
            else {
                enterMap(mapName, mapId)
            }
            
        
            
        }
    }
    
    func showPasswordDialog(_ intendedPassword: String, _ mapName: String, _ mapId: String) {
        let alertController = UIAlertController(title: "Carte privée", message: "Cette carte nécessite un mot de passe", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = "Mot de passe"
        }
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            
            if textfield.text == intendedPassword {
                self.enterMap(mapName, mapId);
            } else {
                EditionModeUtils.showErrorMessage("Mot de passe incorrect", self);
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel);
        alertController.addAction(OKAction);
        alertController.addAction(cancelAction);
        present(alertController, animated: true, completion: nil)
    }
    
    func enterMap(_ mapName: String, _ mapId: String) {
        progressIndicator.startAnimating();
        Alamofire.request("https://log3900.herokuapp.com/map/" + mapName).validate().responseString{ response in
            if response.result.value != nil {
                self.progressIndicator.stopAnimating();
                let prettyString: String = self.getPrettyJsonString(response.result.value!);
                // Tell the server we wanna edit online, and wait for a response
                // Establish connections
                SocketIOManager.sharedInstance.establishConnection();
                SocketIOManager.sharedInstance.startEditingMap(mapName, self) { () -> Void in
                    OnlineEditionModeController.mapName = mapName;
                    OnlineEditionModeController.loadedMap = prettyString;
                    OnlineEditionModeController.mapId = mapId;
                    self.performSegue(withIdentifier: "loadMapFromOnline", sender: prettyString)
                }
            } else {
                print("‼️ Could not parse response as String");
            }
        }
    }
    
    // MARK: Utils
    // Remove unwanted characters from map file when downloading
    func getPrettyJsonString(_ json: String) -> String {
        var prettyJson: String;
        prettyJson = json.replacingOccurrences(of: "\\n", with: "");
        prettyJson = prettyJson.replacingOccurrences(of: "\\t", with: "");
        prettyJson = prettyJson.replacingOccurrences(of: "\\", with: "");
        prettyJson = prettyJson.replacingOccurrences(of: "[", with: "");
        prettyJson = prettyJson.replacingOccurrences(of: "]", with: "");
        prettyJson = prettyJson.replacingOccurrences(of: "{", with: "");
        prettyJson = prettyJson.replacingOccurrences(of: "}", with: "");
        // Remove everything before and after the actual xml
        if let xmlStartRange = prettyJson.range(of: "<") {
            prettyJson.removeSubrange(prettyJson.startIndex..<xmlStartRange.lowerBound);
        }
        if let xmlEndRange = prettyJson.range(of: ">", options: String.CompareOptions.backwards, range: nil, locale: nil) {
            prettyJson.removeSubrange(xmlEndRange.upperBound..<prettyJson.endIndex);
        }
        print("Server response cleaned up");
        print(prettyJson);
        return prettyJson;
        
    }
    
    func getMap() {
        if let mapNumber: Optional = currentlySelectedCell {
            let map = mapList[mapNumber!];
            let mapName: String = map["name"] as! String
            //progressIndicator.startAnimating()
            Alamofire.request("https://log3900.herokuapp.com/map/" + mapName).validate().responseString{ response in
                if response.result.value != nil {
                    //self.progressIndicator.stopAnimating();
                    let loadedMap: String = self.getPrettyJsonString(response.result.value!);
                    do {
                        let xmlMap = try AEXMLDocument(xml: loadedMap, encoding: String.Encoding.utf8, options: AEXMLOptions())
                        self.loadMap(xmlMap,self.scene!);
                    } catch {
                        print("\(error)")
                    }
                } else {
                    print("‼️ Could not parse response as String");
                }
            }
        }
    }
    
    // Loads the map into the scene
    func loadMap(_ xmlDoc: AEXMLDocument,_ scene: EditionModeScene) {
        // Clear current map
        scene.clearScene();
        print("Loading this map:");
        print(xmlDoc.xml)
        let planche = xmlDoc.root["planche"];
        var pointArray = [CGPoint](repeating: CGPoint(), count:8); // NumberFormatter().number(from: xmlElem.attributes["e_0_s"]!) as! CGFloat;
        let coinInfDx = NumberFormatter().number(from: planche.attributes["coinInfDX"]!) as! CGFloat;
        let coinInfDy = NumberFormatter().number(from: planche.attributes["coinInfDY"]!) as! CGFloat;
        let axeHoriDx = NumberFormatter().number(from: planche.attributes["axeHoriDX"]!) as! CGFloat;
        let coinSupDx = NumberFormatter().number(from: planche.attributes["coinSupDX"]!) as! CGFloat;
        let coinSupDy = NumberFormatter().number(from: planche.attributes["coinSupDY"]!) as! CGFloat;
        let axeVertDy = NumberFormatter().number(from: planche.attributes["axeVertDY"]!) as! CGFloat;
        pointArray[0] = CGPoint(x: -coinInfDx, y: -coinInfDy);
        pointArray[6] = CGPoint(x: coinInfDx, y: -coinInfDy);
        pointArray[1] = CGPoint(x: -axeHoriDx, y: CGFloat(0));
        pointArray[5] = CGPoint(x: axeHoriDx, y: CGFloat(0));
        pointArray[2] = CGPoint(x: -coinSupDx, y: coinSupDy);
        pointArray[4] = CGPoint(x: coinSupDx, y: coinSupDy);
        pointArray[3] = CGPoint(x: CGFloat(0) , y: axeVertDy);
        pointArray[7] = CGPoint(x: CGFloat(0) , y: -axeVertDy);
        // set the scene morph points correctly
        for index in 0 ... pointArray.count-1 {
            EditionModeUtils.updateMorphPointCoords(pointArray[index], index, scene);
        }
        
        // update goal positions
        EditionModeUtils.adjustGoals(scene);
        
        for object in xmlDoc.root["planche"].children {
            print("Loading " + object.attributes["type"]!);
            switch object.attributes["type"] {
            case "portail"?:
                let portal = GameObjectFactory.createPortalObject(object);
                scene.addNode(portal);
            case "accelerateur"?:
                let accel = GameObjectFactory.createAcceleratorObject(object);
                scene.addNode(accel);
            case "mur"?:
                let mur = GameObjectFactory.createWallObject(object);
                scene.addNode(mur);
            default:
                print("Can't find suitable constructor for " + object.attributes["type"]!);
                //case .none: break
                // do nothing
                //case .some(_): break
                // do nothing
            }
        }
    }
    
    //MARK: Carousel functions
    func numberOfItems(in carousel: iCarousel) -> Int {
        return scenes.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        var mainView: UIStackView
        var sceneView: SKView;
        var imageView: UIImageView;

        mainView = UIStackView(frame: CGRect(x: 0, y: 0, width: 600, height: 400))
        mainView.axis = .vertical;
        mainView.contentMode = .center
        
        sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 600, height: 370));

        sceneView.tag = 2;
        sceneView.isUserInteractionEnabled = false;
        mainView.addArrangedSubview(sceneView);
        // if map is private we add a locked icon
        var pw: String? = (mapList[index]["password"] as? String)
        if let password = pw {
            if (!password.isEmpty) {
                imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 186, height: 255))
                imageView.image = UIImage(named: "lockedMap.png");
                imageView.contentMode = .center
                sceneView.addSubview(imageView);
                print("lockedMap");
            }
        }
        
        
        
        label = UILabel(frame: mainView.bounds)
        label.backgroundColor = .white;
        label.textAlignment = .center
        label.font = label.font.withSize(20)
        label.tag = 1
        mainView.addArrangedSubview(label)
        
 
        label.text = (mapList[index]["name"] as! String);
        sceneView.presentScene(scenes[index]);
       
        
        return mainView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Entering prepare function");
        if segue.identifier == "loadMapFromOnline", let editModeController = segue.destination as? OnlineEditionModeController {
            OnlineEditionModeController.loadedMap = sender as! String;
            SoundManager.playStartGame();
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        SocketIOManager.sharedInstance.closeConnection();
        //joinMap(UIButton());
        goBackToMainMenu(UIButton());
    }

}
