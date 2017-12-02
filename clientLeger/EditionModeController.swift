//
//  EditionModeController.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-01.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import AEXML
import FileBrowser
import Alamofire

//TODO: remove morph point selection when done!

class EditionModeController: UIViewController, SKSceneDelegate, UIGestureRecognizerDelegate {
    var editMode: EditMode;
    var panGestureRecognizer = UIPanGestureRecognizer()
    var pinchGestureRecognizer = UIPinchGestureRecognizer()
    var rotationGestureRecognizer = UIRotationGestureRecognizer()
    // Timer variables for double tap
    var doubleTapTimer: Timer = Timer();
    var checkingDoubleTap: Bool = false;
    @IBOutlet weak var currentModeIcon: UIImageView!
    // Precise field variables
    @IBOutlet weak var precisePanelView: UIView!
    @IBOutlet weak var xPositionField: UITextField!
    @IBOutlet weak var yPositionField: UITextField!
    @IBOutlet weak var rotationField: UITextField!
    @IBOutlet weak var scaleField: UITextField!
    
    public static var canSelectMorphPoints: Bool = true;
    
    // constants
    public static var acceleration: Float = 2;
    public static var friction: Float = 0.0020000001;
    public static var rebond: Float = 0.0099999998;
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPinchGestureRecognizer || gestureRecognizer is UIRotationGestureRecognizer || gestureRecognizer is UIPanGestureRecognizer) {
            return true
        } else {
            return false
        }
    }
    
    init() {
        editMode = EditMode();
        super.init(nibName: "", bundle: nil)
        precisePanelView.isHidden = true;
        self.view.isMultipleTouchEnabled = true;
        //let editScene = editionModeGameScene.scene as! EditionModeScene
        EditionModeController.setInitialConstants();
    }
    
    required init?(coder aDecoder: NSCoder) {
        editMode = EditMode();
        super.init(coder: aDecoder)
        EditionModeController.setInitialConstants();
    }
    
    
    @IBOutlet weak var editionModeGameScene: SKView!
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        if (editMode is CameraMode) { // only check for double taps when in camera mode
            print(touches.debugDescription)
            if (!checkingDoubleTap) {
                checkingDoubleTap = true;
                self.doubleTapTimer = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: false) {
                    timer in
                    self.checkingDoubleTap = false;
                    self.editMode.onSingleTap(touches.first!.location(in: self.view).x, touches.first!.location(in: self.view).y)
                };
            } else {
                if (touches.count < 2) {
                    print(touches.debugDescription)
                    self.editMode.onDoubleTap(touches.first!.location(in: self.view).x, touches.first!.location(in: self.view).y);
                    checkingDoubleTap = false;
                    doubleTapTimer.invalidate();
                }
            }
        } else {
            self.editMode.onSingleTap(touches.first!.location(in: self.view).x, touches.first!.location(in: self.view).y)
            // if we selected only 1 object, show and update the precise value fields
            let scene: EditionModeScene = editionModeGameScene.scene as! EditionModeScene;
            if (scene.selectedItems.count == 1) {
                precisePanelView.isHidden = false;
                updatePrecisePanelValues(scene.selectedItems.first!);

            } else if (scene.selectedItems.count == 0) {
                // If we aren't selecting any more objects, hide the precise value view
                precisePanelView.isHidden = true;
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        editMode.onTouchEnded(touches.first!.location(in: self.view).x, touches.first!.location(in: self.view).y)
        // if we selected only 1 object, show and update the precise value fields
        let scene: EditionModeScene = editionModeGameScene.scene as! EditionModeScene;
        if (scene.selectedItems.count == 1) {
            precisePanelView.isHidden = false;
            updatePrecisePanelValues(scene.selectedItems.first!)
        } else if (scene.selectedItems.count == 0) {
            // If we aren't selecting any more objects, hide the precise value view
            precisePanelView.isHidden = true;
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                              
        with event: UIEvent?) {
        let x = touches.first?.location(in: self.view).x
        let y = touches.first?.location(in: self.view).y
        
        editMode.onSingleFingerSlide(x!, y!, touches)
        
        let scene = (editionModeGameScene.scene as! EditionModeScene);
        if (scene.selectedItems.count == 1) {
            precisePanelView.isHidden = false;
            updatePrecisePanelValues(scene.selectedItems.first!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EditionModeController.canSelectMorphPoints = true;
        editionModeGameScene.preferredFramesPerSecond = 30
//        editionModeGameScene.showsFPS = true
//        editionModeGameScene.showsNodeCount = true
        editionModeGameScene.isMultipleTouchEnabled = true
        GameObject.resetGameIdCount();
        // Do any additional setup after loading the view.
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized(sender:)))
        pinchGestureRecognizer.delegate = self
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panRecognized(sender:)))
        panGestureRecognizer.delegate = self
        rotationGestureRecognizer = UIRotationGestureRecognizer(target:self, action: #selector(rotationRecognized(sender:)))
        rotationGestureRecognizer.delegate = self
        
        editionModeGameScene.addGestureRecognizer(pinchGestureRecognizer)
        editionModeGameScene.addGestureRecognizer(rotationGestureRecognizer)
        //SocketIOManager.sharedInstance.closeConnection();
        //editionModeGameScene.addGestureRecognizer(panGestureRecognizer)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Functions for changing edit mode
    @IBAction func onSelectModePress(_ sender: UIButton) {
        if (editMode.canChangeEditMode()) {
            editionModeGameScene.removeGestureRecognizer(panGestureRecognizer)
            let editScene : EditionModeScene = (editionModeGameScene.scene as! EditionModeScene)
            editScene.makeMorphPointsVisible(false)
            editMode = SelectMode(editScene);
            editMode.onAssign()
            changeCurrentModeIconImage(sender);
        }
    }
    
    @IBAction func portalModePress(_ sender: UIButton) {
        if (editMode.canChangeEditMode()) {
            editionModeGameScene.removeGestureRecognizer(panGestureRecognizer)
            let editScene : EditionModeScene = (editionModeGameScene.scene as! EditionModeScene)
            editScene.makeMorphPointsVisible(false)
            editMode = CreatePortalMode(editScene)
            editMode.onAssign()
            changeCurrentModeIconImage(sender);
        }
    }
    
    @IBAction func addAcceleratorModePress(_ sender: UIButton) {
        if (editMode.canChangeEditMode()) {
            editionModeGameScene.removeGestureRecognizer(panGestureRecognizer)
            let editScene : EditionModeScene = (editionModeGameScene.scene as! EditionModeScene)
            editScene.makeMorphPointsVisible(false)
            editMode = CreateAcceleratorMode(editScene)
            editMode.onAssign()
            changeCurrentModeIconImage(sender);
        }
    }
    
    @IBAction func addWallModePress(_ sender: UIButton) {
        if (editMode.canChangeEditMode()) {
            editionModeGameScene.removeGestureRecognizer(panGestureRecognizer)
            let editScene : EditionModeScene = (editionModeGameScene.scene as! EditionModeScene)
            editScene.makeMorphPointsVisible(false)
            editMode = CreateWallMode(editScene)
            editMode.onAssign()
            changeCurrentModeIconImage(sender);
        }
    }
    
    @IBAction func cameraModePress(_ sender: UIButton) {
        if (editMode.canChangeEditMode()) {
            editionModeGameScene.removeGestureRecognizer(panGestureRecognizer)
            let editScene : EditionModeScene = (editionModeGameScene.scene as! EditionModeScene)
            editScene.makeMorphPointsVisible(false)
            editMode = CameraMode(editScene)
            editMode.onAssign()
            changeCurrentModeIconImage(sender);
        }
    }
    
    @IBAction func moveModePress(_ sender: UIButton) {
        if (editMode.canChangeEditMode()) {
            let editScene : EditionModeScene = (editionModeGameScene.scene as! EditionModeScene)
            editScene.makeMorphPointsVisible(false)
            editMode = TransformationMode(editScene);
            editMode.onAssign();
            changeCurrentModeIconImage(sender);
            editionModeGameScene.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    @IBAction func duplicateModePress(_ sender: UIButton) {
        if (editMode.canChangeEditMode()) {
            editionModeGameScene.removeGestureRecognizer(panGestureRecognizer)
            let editScene : EditionModeScene = (editionModeGameScene.scene as! EditionModeScene)
            editScene.makeMorphPointsVisible(false)
            editMode = DuplicateMode(editScene);
            editMode.onAssign();
            changeCurrentModeIconImage(sender);
        }
    }
    
    @IBAction func MorphBorderModePress(_ sender: UIButton) {
            if (editMode.canChangeEditMode() && EditionModeController.canSelectMorphPoints) {
                editionModeGameScene.removeGestureRecognizer(panGestureRecognizer)
                    SocketIOManager.sharedInstance.askForMorphPointSelection {
                        let editScene : EditionModeScene = (self.editionModeGameScene.scene as! EditionModeScene)
                        editScene.makeMorphPointsVisible(true)
                        self.editMode = MorphBorderMode(editScene);
                        self.editMode.onAssign();
                        self.changeCurrentModeIconImage(sender);
                    }
                }
    }
    
    @IBAction func deletePress(_ sender: UIButton) {
        if (editMode.canChangeEditMode()) {
            // 
            SoundManager.deleteObjectsPlay();
            (editionModeGameScene.scene as! EditionModeScene).deleteSelectedNodes();
            // Hide and reset the precise panel
            precisePanelView.isHidden = true;
            resetPrecisePanelValues();
        }
    }
    
    @IBAction func playPress(_ sender: UIButton) {
        if (editMode.canChangeEditMode()) {
            editionModeGameScene.removeGestureRecognizer(panGestureRecognizer)
            self.performSegue(withIdentifier: "testMapFromEditionSegue", sender: self);
        }
    }
    
    @IBAction func tutorialPress(_ sender: UIButton) {
        performTutorialSegue()
    }
    
    public func performTutorialSegue(){
        if (editMode.canChangeEditMode()) {
            self.performSegue(withIdentifier: "offlineToTutorialSegue", sender: self);
        }
    }
    
    
    //MARK: Saving
    
    @IBAction func savePress(_ sender: UIButton) {
        if (editMode.canChangeEditMode()) {
            print(listFilesFromDocumentsFolder())
            showSaveDialog()
        }
    }
    
    func showSaveDialog() {
        let alertController = UIAlertController(title: "Save or Load Map", message: "Choose a map", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = "Map Name"
        }
        if (User.isAuthenticated) {
            alertController.addTextField{ (textField : UITextField!) -> Void in
                textField.placeholder = "Mot de passe (vide pour carte publique)";
            }
        }
        let OKAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default) { (action) -> Void in
            var mapName: String  = alertController.textFields![0].text!;
            if (!mapName.isEmpty) {
                mapName = mapName + ".xml";
                self.saveMap(mapName);
                SoundManager.playSaveMap();
            } else {
                EditionModeUtils.showErrorMessage("Map name cannot be empty", self);
            }
            
        };
        let uploadAction = UIAlertAction(title: "Upload to Server", style: UIAlertActionStyle.default) { (action) -> Void in
            var mapName: String  = alertController.textFields![0].text!;
            let password: String = alertController.textFields![1].text!;
            if (!mapName.isEmpty) {
                if (User.isAuthenticated) {
                    mapName = mapName + ".xml";
                    let xmlFile: String = self.getXmlStringForSaving(mapName);
                    // Upload file to server
                    let parameters: Parameters = [
                        "name": mapName,
                        "holderName": User.getUsername(),
                        "biggestId" : GameObject.idCount,
                        "map" : xmlFile,
                        "password": password
                    ]
                    Alamofire.request("https://log3900.herokuapp.com/map", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
                        if let json = response.result.value {
                            print(json);
                        } else {
                            SoundManager.playError();
                            EditionModeUtils.showErrorMessage("Une carte avec le nom " + mapName + " existe déjà", self);
                            print("‼️ Could not parse response as JSON");
                        }
                    }
                } else {
                    EditionModeUtils.showErrorMessage("Must be Authenticated to upload map file", self)
                }
            } else {
                EditionModeUtils.showErrorMessage("Map name cannot be empty", self)
            }
        };
        let loadAction = UIAlertAction(title: "Load", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            // Lets try loading a map
            let fileBrowser = FileBrowser( allowEditing: true, showCancelButton: true);
            self.present(fileBrowser, animated: true, completion: nil)
            fileBrowser.didSelectFile = { (file: FBFile) -> Void in
                print(file.displayName)
                self.getMapFile(file.displayName);
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel ) { (action) -> Void in
            
        }
        alertController.addAction(OKAction);
        alertController.addAction(loadAction);
        uploadAction.isEnabled = User.isAuthenticated;
        alertController.addAction(uploadAction);
        alertController.addAction(cancelAction);
        present(alertController, animated: true, completion: nil)
    }

    
    func saveMap(_ mapName: String) {
        // Write to file
        let someDummyTextForTextFile  = getXmlStringForSaving(mapName);
        let data:NSData = someDummyTextForTextFile.data(using: String.Encoding.utf8)! as NSData
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(mapName)
            print("Writing to " + fileURL.absoluteString);
            data.write(to: fileURL, atomically: true);
        } catch {
            print(error)
        }
        print(someDummyTextForTextFile);
    }
    
    func getXmlStringForSaving(_ mapName: String) -> String {
        let file = AEXMLDocument();
        var attributes = ["coefFriction": EditionModeController.friction.description, "coefRebond" : EditionModeController.rebond.description, "accel": EditionModeController.acceleration.description];
        // Save arbre
        let arbre = file.addChild(name: "arbre", attributes: attributes);
        // save planche
        // TODO get actual control point values
        var pointsArray = (editionModeGameScene.scene as? EditionModeScene)?.getPointArrayFromMorphPoints();
        let coinInfDx = abs(pointsArray![0].x);
        let coinInfDy = abs(pointsArray![0].y);
        let axeHoriDx = abs(pointsArray![1].x);
        let coinSupDx = abs(pointsArray![2].x);
        let coinSupDy = abs(pointsArray![2].y);
        let axeVertDy = abs(pointsArray![3].y);
        attributes = ["type":"planche", "id":"1", "e_0_s":"1", "e_1_t":"1", "e_2_p":"1", "p_0_x":"1", "p_0_r":"1", "p_0_s":"1", "r_3_w":"1", "r_3_a": "1",  "r_3_q":"1", "r_0_s":"1", "r_0_t":"0", "r_1_s":"0", "r_1_t":"1", "p_3_s":"0", "p_3_t":"0", "axeVertDY": axeVertDy.description, "axeHoriDX":axeHoriDx.description, "coinSupDX":coinSupDx.description, "coinSupDY":coinSupDy.description, "coinInfDX":coinInfDx.description, "coinInfDY":coinInfDy.description]
        let planche = arbre.addChild(name: "planche", attributes: attributes);
        // Save all items in editable items
        let allItems = (editionModeGameScene.scene as! EditionModeScene).editableItems
        for object in allItems {
            object.saveObjectToXml(planche);
        }
        return file.xml;
    }

    func getMapFile(_ mapName: String) {
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
                    else { return }
                do {
                    let xmlDoc = try AEXMLDocument(xml: data)
                    // load the map into the scene
                    loadMap(xmlDoc);
                }
                    
                catch {
                    print("\(error)")
                }
            } catch {
                print(error);
            }
        }
    }
    
    // Loads the map into the scene
    func loadMap(_ xmlDoc: AEXMLDocument) {
        // Clear current map
        let scene = (editionModeGameScene.scene as! EditionModeScene);
        scene.clearScene();
        print("Loading this map:");
        print(xmlDoc.xml)
        // Get constant values
        let arbre = xmlDoc.root;
        let acceleration: Float = NumberFormatter().number(from: arbre.attributes["accel"]!) as! Float;
        let friction: Float = NumberFormatter().number(from: arbre.attributes["coefFriction"]!) as! Float;
        let rebond: Float = NumberFormatter().number(from: arbre.attributes["coefRebond"]!) as! Float;
        EditionModeController.setConstants(acceleration, friction, rebond);
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
        
        // link portals
        for node in scene.editableItems {
            if (node is PortalObject) {
                if let portal: Optional = (node as! PortalObject) {
                    portal?.findAndSetLinkPortal(scene.editableItems);
                }
            }
        }
    }
    
    func listFilesFromDocumentsFolder() -> [String]?
    {
        let fileMngr = FileManager.default;
        
        // Full path to documents directory
        let docs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0].path
        
        // List all contents of directory and return as [String] OR nil if failed
        return try? fileMngr.contentsOfDirectory(atPath:docs)
    }
    
    
    func changeCurrentModeIconImage(_ sender: UIButton) {
        currentModeIcon.image = sender.imageView?.image;
    }
    
    @IBAction func pinchRecognized(sender: UIPinchGestureRecognizer) {
        if sender.numberOfTouches >= 2{
            editMode.pinchRecognized(sender);
        }
        let scene = (editionModeGameScene.scene as! EditionModeScene);
        if (scene.selectedItems.count == 1) {
            precisePanelView.isHidden = false;
            updatePrecisePanelValues(scene.selectedItems.first!)
        }
        if (sender.state == .ended) {
            for object in scene.selectedItems {
                SocketIOManager.sharedInstance.moveObjectOnline(mapName: OnlineEditionModeController.mapName, gameObject: object);
            }
        }
    }
    
    @IBAction func rotationRecognized(sender: UIRotationGestureRecognizer) {
        editMode.rotationRecognized(sender);
        let scene = (editionModeGameScene.scene as! EditionModeScene);
        if (scene.selectedItems.count == 1) {
            precisePanelView.isHidden = false;
            updatePrecisePanelValues(scene.selectedItems.first!)
        }
        if (sender.state == .ended) {
            for object in scene.selectedItems {
                SocketIOManager.sharedInstance.moveObjectOnline(mapName: OnlineEditionModeController.mapName, gameObject: object);
            }
        }
    }
    
    @IBAction func panRecognized(sender: UIPanGestureRecognizer) {
        editMode.panRecognized(sender);

        if (sender.state == .began){
            if (editMode is CameraMode) { // only check for double taps when in camera mode
                if (!checkingDoubleTap) {
                    checkingDoubleTap = true;
                    self.doubleTapTimer = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: false) {
                        timer in
                        self.checkingDoubleTap = false;
                        self.editMode.onSingleTap(sender.location(in: self.view).x, sender.location(in: self.view).y)
                    };
                } else {
                    self.editMode.onDoubleTap(sender.location(in: self.view).x, sender.location(in: self.view).y);
                    checkingDoubleTap = false;
                    doubleTapTimer.invalidate();
                }
            } else {
                self.editMode.onSingleTap(sender.location(in: self.view).x, sender.location(in: self.view).y)
                // if we selected only 1 object, show and update the precise value fields
                let scene: EditionModeScene = editionModeGameScene.scene as! EditionModeScene;
                if (scene.selectedItems.count == 1) {
                    precisePanelView.isHidden = false;
                    updatePrecisePanelValues(scene.selectedItems.first!);
                    
                } else if (scene.selectedItems.count == 0) {
                    // If we aren't selecting any more objects, hide the precise value view
                    precisePanelView.isHidden = true;
                    
                }
                
            }
        }
        else if (sender.state == .changed){
            let x = sender.location(in: self.view).x
            let y = sender.location(in: self.view).y
            
            editMode.onSingleFingerSlide(x, y)
            
            let scene = (editionModeGameScene.scene as! EditionModeScene);
            if (scene.selectedItems.count == 1) {
                precisePanelView.isHidden = false;
                updatePrecisePanelValues(scene.selectedItems.first!)
            }
        }
        else if(sender.state == .ended){
            editMode.onTouchEnded(sender.location(in: self.view).x, sender.location(in: self.view).y)
            // if we selected only 1 object, show and update the precise value fields
            let scene: EditionModeScene = editionModeGameScene.scene as! EditionModeScene;
            if (scene.selectedItems.count == 1) {
                precisePanelView.isHidden = false;
                updatePrecisePanelValues(scene.selectedItems.first!)
            } else if (scene.selectedItems.count == 0) {
                // If we aren't selecting any more objects, hide the precise value view
                precisePanelView.isHidden = true;
            }
        }
        
        let scene = (editionModeGameScene.scene as! EditionModeScene);
        
        if (scene.selectedItems.count == 1) {
            precisePanelView.isHidden = false;
            updatePrecisePanelValues(scene.selectedItems.first!)
        }
        if (sender.state == .ended) {
            for object in scene.selectedItems {
                SocketIOManager.sharedInstance.moveObjectOnline(mapName: OnlineEditionModeController.mapName, gameObject: object);
            }
        }
    }
    
    // MARK text field change methods
    func updatePrecisePanelValues(_ selectedObject: GameObject) {
        xPositionField.text = selectedObject.position.x.description;
        yPositionField.text = selectedObject.position.y.description;
        // Convert rotation to degrees
        let degrees = Double(selectedObject.zRotation) * (180.0 / Double.pi);
        rotationField.text = String(degrees);
        scaleField.text = selectedObject.xScale.description;
    }
    
    func resetPrecisePanelValues() {
        self.xPositionField.text = "0";
        yPositionField.text = "0";
        rotationField.text = "0";
        scaleField.text = "1";
        
    }
    
    @IBAction func xFieldDidChange(_ sender: UITextField) {
        let scene = editionModeGameScene.scene as! EditionModeScene;
        if (scene.selectedItems.count == 1) {
            if let n = NumberFormatter().number(from: sender.text!) {
                let newX = CGFloat(n);
                let object: GameObject = (scene.selectedItems.first)!;
                object.position.x = newX;
            }
        }
    }
    
    @IBAction func yFieldDidChangeEnd(_ sender: UITextField) {
        let scene = editionModeGameScene.scene as! EditionModeScene;
        if (scene.selectedItems.count == 1) {
            if let n = NumberFormatter().number(from: sender.text!) {
                let newY = CGFloat(n);
                let object: GameObject = (scene.selectedItems.first)!;
                object.position.y = newY;
            }
        }
    }
    
    @IBAction func rotationFieldDidChangeEnd(_ sender: UITextField) {
        let scene = editionModeGameScene.scene as! EditionModeScene;
        if (scene.selectedItems.count == 1) {
            if let n = NumberFormatter().number(from: sender.text!) {
                // Convert degrees to radians
                let radians = Double(n) * (Double.pi/180);
                let newRotation = CGFloat(radians);
                let object: GameObject = (scene.selectedItems.first)!;
                object.zRotation = newRotation;
            }
        }
    }
    
    @IBAction func scaleFieldDidChangeEnd(_ sender: UITextField) {
        let scene = editionModeGameScene.scene as! EditionModeScene;
        if (scene.selectedItems.count == 1) {
            if let n = NumberFormatter().number(from: sender.text!) {
                let newScale = CGFloat(n);
                let object: GameObject = (scene.selectedItems.first)!;
                object.xScale = newScale;
                object.yScale = newScale;
            }
        }
    }
    
    public static func setInitialConstants() {
        EditionModeController.acceleration = 2;
        EditionModeController.friction = 0.0020000001;
        EditionModeController.rebond =  0.0099999998;
    }
    
    public static func setConstants(_ accel: Float, _ fric: Float, _ rebond: Float) {
        EditionModeController.acceleration = accel;
        EditionModeController.friction = fric;
        EditionModeController.rebond = rebond;
        
    }
    
    // MARK unwind segue
    
    @IBAction func goToTutorial(_ sender: Any) {
        self.performSegue(withIdentifier: "offlineToTutorialSegue", sender: self)
    }
    
    @IBAction func goBackToMainMenu(_ sender: UIButton) {
        //navigationController?.popViewController(animated: true);
        dismiss(animated: true, completion: nil)
    }
    
    func prepareTransferStruct() -> MapObjects{
        let scene = editionModeGameScene.scene as! EditionModeScene;
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
                //newObject = GameObjectFactory.createWallObjectFromPoints(currentWall.startPoint, currentWall.endPoint)
                newObject = GameObjectFactory.createWallObject(currentWall.position.x, currentWall.position.y, currentWall.zRotation, currentWall.size.height)
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
 
        if segue.identifier == "testMapFromEditionSegue", let playModeController = segue.destination as? PlayModeController {
            playModeController.playMode = PlayMode()
            playModeController.mapObjectStruct = prepareTransferStruct()
        }
    }
}


