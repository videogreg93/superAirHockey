//
//  LoginController.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-10-31.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import UIKit
import Alamofire

class LoginController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        SoundManager.startBackgroundMusic();
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: Button functions
    @IBAction func createUser(_ sender: UIButton) {
        let username: String = usernameField.text!;
        let password: String = passwordField.text!;
        // Make sure the fields aren't empty
        if (validateFields(username, password)) {
            let parameters: Parameters = [
                "userName": username,
                "password": password
            ]
            Alamofire.request("https://log3900.herokuapp.com/user", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
                if let json = response.result.value {
                    print(json);
                } else {
                    print("‼️ Could not parse response as JSON");
                }
            }
        } else {
            SoundManager.playError();
            showErrorMessage();
        }
        
        
        
    }
    
    @IBAction func login(_ sender: UIButton) {
        let username: String = usernameField.text!;
        let password: String = passwordField.text!;
        // Make sure the fields aren't empty
        if (validateFields(username, password)) {
            let parameters: Parameters = [
                "userName": username,
                "password": password
            ]
            Alamofire.request("https://log3900.herokuapp.com/user/signin", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
                if let json = response.result.value {
                    print(json);
                    let jsonResponse = json as? Dictionary<String, Any>;
                    if (jsonResponse!["isAuthenticated"] as? Int == 1) {
                        User.login(username);
                        SoundManager.playStartGame()
                        User.hasSeenTutorial = UserDefaults.standard.bool(forKey: User.username.description)
                        if (User.hasSeenTutorial){
                            self.performSegue(withIdentifier: "showMainMenu", sender: nil)
                        }
                        else {
                            self.performSegue(withIdentifier: "loginToTutorial", sender: nil)
                        }

                    } else {
                        self.showErrorMessage("Could not log in");
                    }
                    
                } else {
                    print(response.response?.statusCode as Any);
                    //self.performSegue(withIdentifier: "showMainMenu", sender: nil)
                    SoundManager.playError();
                    if (response.response?.statusCode == 403) {
                        self.showErrorMessage("Cet utilisateur est déjà en ligne.");
                    } else {
                        self.showErrorMessage("Erreur avec le serveur: " + (response.response?.statusCode.description)! );
                    }
                    
                }
            }
        } else {
            SoundManager.playError();
            showErrorMessage();
        }
    }
    
    @IBAction func loginOffline() {
        User.loginOffline();
        SoundManager.playStartGame();
        self.performSegue(withIdentifier: "showMainMenu", sender: nil)
    }
    
    func validateFields(_ username: String, _ password: String) -> Bool {
        var validFields = true;
        if (username.isEmpty) {
            validFields = false;
            usernameField.layer.borderColor = UIColor.red.cgColor
        }
        if (password.isEmpty) {
            validFields = false;
            passwordField.layer.borderColor = UIColor.red.cgColor
        }
        return validFields;
    }
    
    func showErrorMessage() {
        let alertController = UIAlertController(title: "Error", message: "Text fields cannot be empty", preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default);
        alertController.addAction(OKAction);
        present(alertController, animated: true, completion: nil)
    }
    
    func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default);
        alertController.addAction(OKAction);
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onFieldTouch(_ sender: UITextField) {
        sender.layer.borderColor = UIColor.gray.cgColor;
    }
    
    @IBAction func gregLoginButton(_ sender: UIButton) {
        debugLogin("gregory", "test");
    }
    
    @IBAction func testUserLoginButton(_ sender: UIButton) {
        debugLogin("testUserGregory", "testUserGregory");
    }
    
    //MARK: Functions to quickly login for testing
    func debugLogin(_ user: String,_ pass: String) {
        usernameField.text = user;
        passwordField.text = pass;
        login(UIButton());
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
