//
//  PopupEditionModeController.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-11-24.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import UIKit

class PopupEditionModeController: UIViewController {
    @IBOutlet weak var accelField: UITextField!
    @IBOutlet weak var frictionField: UITextField!
    @IBOutlet weak var rebondField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        accelField.text = EditionModeController.acceleration.description;
        frictionField.text = EditionModeController.friction.description;
        rebondField.text = EditionModeController.rebond.description;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil);
    }
    @IBAction func pressAccept(_ sender: Any) {
        let accel = NumberFormatter().number(from: accelField.text!)
        let friction = NumberFormatter().number(from: frictionField.text!)
        let rebond = NumberFormatter().number(from: rebondField.text!)
        
        if (accel != nil && friction != nil && rebond != nil) {
            // Do something with these values
            EditionModeController.acceleration = accel as! Float;
            EditionModeController.friction = friction as! Float;
            EditionModeController.rebond = rebond as! Float;
            if (SocketIOManager.sharedInstance.isConnected()) {
                SocketIOManager.sharedInstance.changeConstantsOnline(friction: friction as! Float, rebond: rebond as! Float, accel: accel as! Float);
            }
            dismiss(animated: true, completion: nil);
        } else {
            EditionModeUtils.showErrorMessage("Veuillez rentrer des chiffres", self);
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
