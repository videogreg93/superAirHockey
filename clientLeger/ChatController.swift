//
//  GameViewController.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-09-15.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//
/*
import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var userList: UsersTableView!
    @IBOutlet weak var ChatTableView: UITableView!
    
    @IBOutlet weak var messageInputField: UITextField!
    @IBOutlet weak var buttonEnvoyerMessage: UIButton!
    
    let cellIdentifier = "CellIdentifier"
    var users: [AnyObject] = [] // List of all users
    var messages: [Dictionary<String, String>] = [] // List of all chat messages
    var nickname = "" // This users nickname
    var chatroom = "default"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if nickname == "" {
            askForNickname()
        }
        
        buttonEnvoyerMessage.backgroundColor = UIColor.black
        
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                var message = [String: String]()
                message = messageInfo as! [String : String]

                self.messages.append(message)
                self.ChatTableView.reloadData()
            })
        }
    }
    
    
    /*
     Creates a popup on startup that asks users to enter a nickname for online chat
     */
    func askForNickname() {
        let alertController = UIAlertController(title: "Client Léger", message: "Veuillez rentrer un pseudonyme et un chatroom:", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = "Votre pseudonyme"
        }
        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = "Chatroom"
        }
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            let chatroomTextField = alertController.textFields![1]

            if textfield.text?.characters.count == 0 {
                self.askForNickname()
            }
            else {
                self.nickname = textfield.text!
                if (chatroomTextField.text?.characters.count != 0) {
                    self.chatroom = chatroomTextField.text!
                }
                // Verifiy if the user name is available before connecting
                SocketIOManager.sharedInstance.checkIfUsernameIsAvailable(chatroom: self.chatroom, nickname: self.nickname, completionHandler: { (available) -> Void in
                    if (available == "false") { // TODO should not be a string but a boolean
                        // User already exists, tell the user and ask for a new name
                        self.alertUserNameAlreadyInUse()
                    } else {
                        SocketIOManager.sharedInstance.connectToServerWithNickname(nickname: self.nickname, chatroom: self.chatroom, completionHandler: { (newUser) -> Void in
                            DispatchQueue.main.async(execute: { () -> Void in
                                if newUser != nil {
                                    self.users.append(newUser as AnyObject)
                                    self.userList.reloadData()
                                    self.userList.isHidden = false
                                }
                            })
                        })
                    }
                    
                    
                })
                
            }
            
        }
        
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertUserNameAlreadyInUse() {
        let alertController = UIAlertController(title: "Client Léger", message: "Ce pseudonyme est déjà utilisé, veuillez en rentrer un nouveau", preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
            self.askForNickname()
        }
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     Function that tells the 2 tableviews how many rows they have
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.isEqual(userList)) {
            let numberOfRows = users.count
            return numberOfRows
        } else {
            let numberOfRows = messages.count
            return numberOfRows;
        }
    }
    
    /*
     Function that determines how to populate the 2 tableviews
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView.isEqual(userList)) {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            // Fetch User
            let user:NSDictionary = users[indexPath.row] as! NSDictionary
            
            // Set table cell text to username
            cell.textLabel?.text = user.allValues[1] as? String
            
            return cell
            } else { // else deals with chatTableView
            let cell = tableView.dequeueReusableCell(withIdentifier: "idCellChat", for: indexPath)
            
            let currentChatMessage = messages[indexPath.row]
            //let senderNickname = currentChatMessage["nickname"]!
            //var message = currentChatMessage["message"]!
            //let messageDate = currentChatMessage["date"]! // unused variable for now
            let senderNickname = currentChatMessage["user"]
            var message = currentChatMessage["content"]
            
            
            let timeStamp: String = currentChatMessage["date"]!
            
            
            if senderNickname == nickname {
                cell.textLabel?.textAlignment = NSTextAlignment.right
                
                cell.textLabel?.textColor = UIColor.black
                message = timeStamp + " " + message!
            } else {
                message = senderNickname!  + timeStamp +  ": " + message!
            }
            
            cell.textLabel?.text = message
            return cell
        }
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
        let timeStamp: String = "(" + String(hour) + ":" + minutesString + ")"
        return timeStamp
    }
    
    @IBAction func sendTextMessage(_ sender: UITextField) {
        if (sender.text?.characters.count)! > 0 {
            SocketIOManager.sharedInstance.sendMessage(message: sender.text!, withNickname: nickname)
            // Add message to view
            var message = [String: String]()
            message["user"] = nickname
            message["content"] = sender.text!
            message["date"] = getTimeStamp()
            
            self.messages.append(message)
            self.ChatTableView.reloadData()
            sender.text = ""
            sender.resignFirstResponder()
        }
    }
    
    @IBAction func actionBoutonEnvoyerMessage(_ sender: UIButton) {
        sendTextMessage(messageInputField)
    }
}
 */
