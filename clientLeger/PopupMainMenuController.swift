//
//  PopupMainMenuController.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-11-27.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import UIKit

class PopupMainMenuController: UIViewController {
    @IBOutlet weak var gameNumberLabel: UILabel!
    @IBOutlet weak var soundsSwitch: UIButton!
    
    @IBOutlet weak var stepper: UIStepper!
    var isSelected: Bool = SoundManager.getSoundsEnabled();

    override func viewDidLoad() {
        super.viewDidLoad()

        soundsSwitch.setImage(UIImage(named: "BTN_CHECKBOX_IN"), for: .selected)
        soundsSwitch.setImage(UIImage(named: "BTN_CHECKBOX_OUT"), for: .normal)
        
        soundsSwitch.isSelected = isSelected;
        gameNumberLabel.text = PlayModeController.goalsToWin.description;
        stepper.value = Double(PlayModeController.goalsToWin);
    }
    
    @IBAction func soundsSwitchChanged(_ sender: UIButton) {
        isSelected = !isSelected;
        sender.isSelected = isSelected;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressSave(_ sender: UIButton) {
        PlayModeController.goalsToWin = Int(stepper.value);
        SoundManager.setSoundsEnabled(isSelected);
        if (isSelected) {
            SoundManager.startBackgroundMusic();
        }
        dismiss(animated: true, completion: nil);
    }
    
    @IBAction func pressCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil);
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        gameNumberLabel.text = Int(stepper.value).description;
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
