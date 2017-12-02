//
//  SocketIOManager.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-09-16.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import UIKit
import SocketIO
//import SpriteKit

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    static var room = "default"
    static let URLONLINE = "https://log3900.herokuapp.com/"
    static let URLLOCAL = "http://127.0.0.1:3000"
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: URLONLINE )! as URL)
    
    override init() {
        super.init();
    }
    
    //MARK: Connecting to server
    
    func establishConnection() {
        if (!isConnected()) {
            socket.connect()
            print("Socket Connected");
        }
        
    }
    
    
     func closeConnection() {
        socket.removeAllHandlers();
        socket.disconnect()
        print("Socket Disconnected");
    }
    
     func checkIfUsernameIsAvailable(chatroom: String, nickname: String, completionHandler: @escaping (_ available:String) -> Void) {
        socket.emit("user-available",chatroom, nickname)
        socket.on("user-available"){ ( dataArray, ack) -> Void in
            completionHandler((dataArray[0] as? String)!)
        }
    }
    
     func connectToServerWithNickname(nickname: String, chatroom: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
        socket.emit("joining_room", chatroom, nickname)
        SocketIOManager.room = chatroom
        socket.on("new_user") { ( dataArray, ack) -> Void in
            let userName: String = dataArray[0] as! String
            print(userName + " has joined")
            completionHandler(dataArray[0] as? [[String: AnyObject]])
        }
    }
    
    //MARK : Chatting
    
     func sendMessage(message: String, withNickname nickname: String) {
        let timeStamp: String = getTimeStamp()
        //socket.emit("chat_message", message, SocketIOManager.room, nickname)
        socket.emit("chat_message", message, SocketIOManager.room, timeStamp)
    }
    
     func getTimeStamp() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        // Add a 0 to minutes if its lower than 10
        var minutesString: String
        if (minutes < 10) {
            minutesString = "0" + String(minutes)
        } else {
            minutesString = String(minutes)
        }
        let timeStamp: String = String(hour) + ":" + minutesString
        return timeStamp
    }
    
    
    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
        socket.on("chat_message") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: String]()
            
            /*messageDictionary["nickname"] = dataArray[0] as? String
            messageDictionary["message"] = dataArray[1] as? String
            messageDictionary["date"] = dataArray[2] as? String*/
            
            
            
            
            messageDictionary["user"] = dataArray[0] as? String
            messageDictionary["content"] = dataArray[1] as? String
            messageDictionary["date"] = dataArray[2] as? String
            
            
            completionHandler(messageDictionary as [String : AnyObject])
        }
    }
    
    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        socket.emit("disconnect", nickname)
        completionHandler()
    }
    
    //MARK: Online map editing
    
    func startEditingMap(_ mapName: String, _ sender: UIViewController, callBack: @escaping () -> Void) {
        socket.emit("start_edit_map", mapName, User.getUsername());
        print("Trying to join map " + mapName + " as user " + User.getUsername());
        socket.on("start_edit_map_resp") {( dataArray, ack) -> Void in
            print("Server response")
            for object in dataArray {
                print(object);
            }
            callBack();
        }
        socket.on("session_full") {( dataArray, ack) -> Void in
            EditionModeUtils.showErrorMessage("Session full", sender);
        }
    }
    
    func setUpSelectionCallbacks(selectCallback: @escaping (_ id: Int) -> Void) {
        // Set callbacks for setting objects selected when another user selects it
        self.socket.on("selection_object_resp") { (dataArray, ack) -> Void in
            let id: Int        = self.getIdFromOnline(dataArray[0]);
            let user      = (dataArray[1] as! String);
            let canSelect = (dataArray[2] as! String);
            if (canSelect == "true" && user != User.getUsername()) {
                // someone else selected the object
                selectCallback(id) // other user selects this id
            }
        }
    }
    
    func setUpDeselectionCallbacks(deselectCallback: @escaping (_ id: Int) -> Void) {
        self.socket.on("deselection_object_resp") { (dataArray, ack) -> Void in
            let id = self.getIdFromOnline(dataArray[0]);
            // someone else deselected the object
            deselectCallback(id);
        }
    }
    
    func setupMovingObjectsCallbacks(movingCallback: @escaping (_ id:Int, _ posX: CGFloat,
        _ posY: CGFloat,_ angle:CGFloat,_ scale: CGFloat) -> Void) {
        self.socket.on("changement_noeud_resp") { (dataArray, ack) -> Void in
            let id    = self.getIdFromOnline(dataArray[0]);
            let posX  = self.getCGFloat(dataArray[1]);
            let posY  = self.getCGFloat(dataArray[2]);
            let angle = self.getCGFloat(dataArray[3]);
            var scale = self.getCGFloat(dataArray[4]);
            scale = GameObject.convertScaleLourdToLeger(scale);
            movingCallback(id,posX,posY,angle,scale);
        }
    }
    
    func getIdFromOnline(_ value: Any) -> Int {
        if let stringId = value as? String {
            return Int(stringId)!;
        } else {
            return Int(value as! Float);
        }
    }
    
    func askForSelection(_ id: Int, _ mapName: String, callBack: @escaping () -> Void) {
        if (!isConnected()) {
            callBack();
        } else {
            print("Selecting " + String(id) + " in " + mapName);
            socket.emit("selection_object", String(id), mapName, User.getUsername());
            socket.once("selection_object_resp") { ( dataArray, ack) -> Void in
                print("Server response");
                for object in dataArray {
                    print(object);
                }
                
                if let canSelect: String = (dataArray[2] as! String) {
                    if (canSelect == "true") {
                        print("selection granted");
                        callBack();
                    } else {
                        print("selection refused");
                    }
                } else {
                    print("Could not parse server response of ");
                    print(dataArray[2]);
                }
            }
        }
    }
    
    func deselectObjects(_ mapName: String, callBack: @escaping () -> Void) {
        if (isConnected()) {
            print("deselecting objects held by " + User.getUsername() + " in map " + mapName);
            socket.emit("deselection_object", mapName, User.getUsername());
        }
        callBack();
    }
    
    func moveObjectOnline( mapName: String,gameObject: GameObject) {
        if (isConnected()) {
            let id: String = String(gameObject.id);
            var xScale = GameObject.convertScaleLegerToLourd(gameObject.xScale);
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 5;
            socket.emit("changement_noeud", mapName, id,
                        gameObject.position.x.description, gameObject.position.y.description,
                        gameObject.zRotation.description, xScale.description);
            print("Client: emitting changement_noeud");
        }
    }
    
    //MARK: Add objects online
    
    // Setup
    func setupOnAddAccel(callback: @escaping (_ posX: CGFloat,_ posY:CGFloat) -> Void) {
        self.socket.on("add_accel_resp") { (dataArray, ack) -> Void in
            print("Server telling me to create a boost");
            let posX: CGFloat = self.getCGFloat(dataArray[0]);
            let posY: CGFloat = self.getCGFloat(dataArray[1]);
            callback(posX,posY);
        }
    }
    
    func setupOnAddMur(callback: @escaping (_ startX: CGFloat,_ startY:CGFloat,_ endX: CGFloat,_ endY:CGFloat) -> Void) {
        self.socket.on("add_mur_resp") { (dataArray, ack) -> Void in
            print("Server says: add_mur_resp with this object: ");
            print(dataArray.debugDescription);
            let startX: CGFloat = self.getCGFloat(dataArray[0]);
            let startY: CGFloat = self.getCGFloat(dataArray[1]);
            let endX  : CGFloat = self.getCGFloat(dataArray[2]);
            let endY  : CGFloat = self.getCGFloat(dataArray[3]);
            callback(startX,startY,endX,endY);
        }
    }
    
    func setupOnAddPortails(callback: @escaping (_ posX1:CGFloat,_ posY1:CGFloat,_ posX2:CGFloat,_ posY2:CGFloat) -> Void) {
        self.socket.on("add_portails_resp") { (dataArray, ack) -> Void in
            print("Server says: Add portals");
            let posX1: CGFloat = self.getCGFloat(dataArray[0]);
            let posY1: CGFloat = self.getCGFloat(dataArray[1]);
            let posX2: CGFloat = self.getCGFloat(dataArray[2]);
            let posY2: CGFloat = self.getCGFloat(dataArray[3]);
            callback(posX1,posY1,posX2,posY2);
        }
    }
    
    //MARK: Setup for duplication
    func setupOnDupAccel(callback: @escaping (_ posX: CGFloat,_ posY:CGFloat,_ angle:CGFloat,_ scale:CGFloat) -> Void) {
        self.socket.on("duplication_accel_resp") { (dataArray, ack) -> Void in
            print("Server telling me to duplicate a boost");
            let posX : CGFloat = self.getCGFloat(dataArray[0]);
            let posY : CGFloat = self.getCGFloat(dataArray[1]);
            let angle: CGFloat = self.getCGFloat(dataArray[2]);
            var scale: CGFloat = self.getCGFloat(dataArray[3]);
            scale = GameObject.convertScaleLourdToLeger(scale);
            callback(posX,posY, angle, scale);
        }
    }
    
    func setupOnDupMur(callback: @escaping (_ posX: CGFloat,_ posY:CGFloat,_ angle: CGFloat,_ scale:CGFloat) -> Void) {
        self.socket.on("duplication_mur_resp") { (dataArray, ack) -> Void in
            print("Server says: duplication_mur_resp with this object: ");
            print(dataArray.debugDescription);
            let posX   : CGFloat = self.getCGFloat(dataArray[0]);
            let posY   : CGFloat = self.getCGFloat(dataArray[1]);
            let angle  : CGFloat = self.getCGFloat(dataArray[2]);
            var scale  : CGFloat = self.getCGFloat(dataArray[3]);
            scale = GameObject.convertScaleLourdToLeger(scale);
            callback(posX,posY,angle,scale);
        }
    }
    
    func setupOnDupPortails(callback: @escaping (_ posX1:CGFloat,_ posY1:CGFloat,_ angle1:CGFloat,_ scale1:CGFloat,
                                                 _ posX2:CGFloat,_ posY2:CGFloat,_ angle2:CGFloat,_ scale2:CGFloat) -> Void) {
        self.socket.on("duplication_portail_resp") { (dataArray, ack) -> Void in
            print("Recieved duplication_portail_resp" );
            let posX1 : CGFloat = self.getCGFloat(dataArray[0]);
            let posY1 : CGFloat = self.getCGFloat(dataArray[1]);
            let angle1: CGFloat = self.getCGFloat(dataArray[2]);
            var scale1: CGFloat = self.getCGFloat(dataArray[3]);
            scale1 = GameObject.convertScaleLourdToLeger(scale1);
            let posX2 : CGFloat = self.getCGFloat(dataArray[4]);
            let posY2 : CGFloat = self.getCGFloat(dataArray[5]);
            let angle2: CGFloat = self.getCGFloat(dataArray[6]);
            var scale2: CGFloat = self.getCGFloat(dataArray[7]);
            scale2 = GameObject.convertScaleLourdToLeger(scale2);
            callback(posX1,posY1,angle1,scale1,posX2,posY2,angle2,scale2);
        }
    }
    
    //MARK: Online duplication
    func dupPortailsOnline(mapName:String,posX1:CGFloat,posY1:CGFloat,angle1:CGFloat,scale1:CGFloat,
                           posX2:CGFloat,posY2:CGFloat,angle2:CGFloat,scale2:CGFloat) {
        if (isConnected()) {
            print("Emitting dup portals online");
            let newScale1 = GameObject.convertScaleLegerToLourd(scale1);
            let newScale2 = GameObject.convertScaleLegerToLourd(scale2);
            socket.emit("duplication_portails",mapName, posX1.description,posY1.description,angle1.description,newScale1.description,
                        posX2.description,posY2.description,angle2.description,newScale2.description);
            socket.emit("duplication_portail",mapName, posX1.description,posY1.description,angle1.description,newScale1.description,
                        posX2.description,posY2.description,angle2.description,newScale2.description);
        }
    }
    
    func dupAccelOnline(mapName:String,posX:CGFloat,posY:CGFloat,angle:CGFloat,scale:CGFloat) {
        if (isConnected()) {
            let newScale = GameObject.convertScaleLegerToLourd(scale);
            socket.emit("duplication_accel",mapName,posX.description,posY.description,angle.description,newScale.description);
            print("emitting dup accel online");
        }
    }
    
    func dupWallOnline(mapName:String,posX:CGFloat,posY:CGFloat,angle:CGFloat,scale:CGFloat) {
        if (isConnected()) {
            let newScale = GameObject.convertScaleLegerToLourd(scale);
            socket.emit("duplication_mur",mapName,posX.description,posY.description,angle.description,newScale.description);
            print("emitting dup mur online");
        }
    }
    
    func addAccelOnline(mapName:String,posX:CGFloat,posY:CGFloat) {
        if (isConnected()) {
            socket.emit("add_accel", OnlineEditionModeController.mapName, posX.description, posY.description);
            print("emitting add boost online");
        }
    }
    
    func addMurOnline(mapName:String,startX:CGFloat,startY:CGFloat,endX:CGFloat,endY:CGFloat) {
        if (isConnected()) {
            socket.emit("add_mur", OnlineEditionModeController.mapName, startX.description, startY.description, endX.description, endY.description);
            print("emitting add mur online");
            
        }
    }
    
    func addPortalOnline(mapName:String,posX1:CGFloat,posY1:CGFloat,posX2:CGFloat,posY2:CGFloat) {
        if (isConnected()) {
            socket.emit("add_portails", OnlineEditionModeController.mapName, posX1.description, posY1.description,
                        posX2.description, posY2.description);
            print("emitting add portals online");
        }
    }
    
    //MARK: Delete objects online
    func setupDeleteObjectsOnline(deleteCallback: @escaping (_ id: Int) -> Void) {
        socket.on("delete_object_resp") { (dataArray, ack) -> Void in
            print("Recieve delte_object_resp");
            if let id = dataArray[0] as? String {
                deleteCallback(Int(id)!);
            } else {
                deleteCallback(Int(dataArray[0] as! Float));
            }
            
        }
    }
    
    func deleteObjectOnline(mapName: String, id: String) {
        if (isConnected()) {
            socket.emit("delete_object", mapName, id);
            print("emitting delete_object");
        }
    }
    
    //MARK: Morph controls online
    func askForMorphPointSelection(callback: @escaping () -> Void) {
        if (!isConnected()) {
            callback();
        } else {
            socket.emit("selection_controles", OnlineEditionModeController.mapName, User.getUsername());
            
        } 
    }
    
    func setupOnSelectionControl(callback: @escaping (_ canSelect: Bool) -> Void) {
        socket.on("selection_controles_resp") { (dataArray, ack) -> Void in
            let username: String = dataArray[0] as! String;
            if (username == User.getUsername()) {
                EditionModeController.canSelectMorphPoints = true;
                callback(true);
            } else {
                SoundManager.playCantPlaceThere();
                EditionModeController.canSelectMorphPoints = false;
                callback(false);
            }
        }
    }
    
    func setupOnDeselectionMorphPoints(callback: @escaping () -> Void) {
        socket.on("deselection_controles_resp") { (dataArray, ack) -> Void in
            callback();
        }
    }
    
    func deselectMorphPoints() {
        if (isConnected()) {
            socket.emit("deselection_controles", OnlineEditionModeController.mapName, User.getUsername());
        }
    }
    
    func moveMorphPointsOnline(_ index: Int, _ position: CGPoint) {
        if (isConnected()) {
            let lourdIndex = self.morphLegerToLourd(index);
            socket.emit("moving_controles", OnlineEditionModeController.mapName, lourdIndex.description, position.x.description, position.y.description)
        }
    }
    
    func setupOnMorphPointsMoved(callback: @escaping (_ index: Int, _ posX: CGFloat,_ posY:CGFloat) -> Void) {
        socket.on("moving_controles_resp") { (dataArray, ack) -> Void in
            let index: Int    = self.getIdFromOnline(dataArray[0]);
            let legerIndex    = self.morphLourdToLeger(index);
            let posX: CGFloat = self.getCGFloat(dataArray[1]);
            let posY: CGFloat = self.getCGFloat(dataArray[2]);
            callback(legerIndex,posX,posY);
        }
    }
    
    //MARK: Constants
    func setupOnConstantsChange(callback: @escaping (_ friction: CGFloat, _ rebond: CGFloat,_ accel:CGFloat) -> Void) {
        socket.on("update_propriete_planche_resp") { (dataArray, ack) -> Void in
            let friction = self.getCGFloat(dataArray[0]);
            let rebond   = self.getCGFloat(dataArray[1]);
            let accel    = self.getCGFloat(dataArray[2]);
            callback(friction,rebond,accel);
        }
    }
    
    func changeConstantsOnline(friction:Float,rebond:Float,accel:Float) {
        if (isConnected()) {
            socket.emit("update_propriete_planche", OnlineEditionModeController.mapName, friction.description, rebond.description, accel.description);
        }
    }
    
    //MARK: Utils
    
    func isConnected() -> Bool {
        return (socket.status == SocketIOClientStatus.connected);
    }
    
    func getCGFloat(_ value: Any) -> CGFloat {
        if let stringValue = value as? String {
            return (NumberFormatter().number(from: stringValue) as! CGFloat);
        } else {
            return (CGFloat(value as! Float));
        }
    }
    
    func morphLourdToLeger(_ index: Int) -> Int {
        let lourdLeger = [2,3,4,1,5,0,7,6];
        return lourdLeger[index];
    }
    
    func morphLegerToLourd(_ index: Int) -> Int {
        let legerLourd = [5,3,0,1,2,4,7,6];
        return legerLourd[index];
    }
}
