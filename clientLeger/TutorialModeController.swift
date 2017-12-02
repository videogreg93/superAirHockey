//
//  TutorialController.swift
//  clientLeger
//
//  Created by Marco on 2017-11-26.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit

class TutorialModeController : UIViewController, SKSceneDelegate {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var imageList : [String] = ["t_basic", "t_basic", "pinkPortal", "bluePortal"]
    var textArray : [String] = ["basic", "player2", "pinkPortal", "bluePortal"]
    var currentIndex : Int = 0
    
    @IBAction func goBackPressed(_ sender: Any) {
        SoundManager.stopTutorialSound(currentIndex)
        print("exiting tutorial mode");
        if (!User.hasSeenTutorial) {
            User.hasSeenTutorial = true
            UserDefaults.standard.set(true, forKey: User.username)
            performSegue(withIdentifier: "tutorialToMainMenu", sender: nil)
            return
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func replaySoundPress(_ sender: UIButton) {
        replaySound()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textArray = TutorialModeController.getTutorialTextArray()
        imageList = TutorialModeController.getImageArray(textArray)
        currentIndex = 0
        textLabel.text = textArray[currentIndex]
        picture.image = UIImage(named:imageList[currentIndex])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            SoundManager.playTutorialSound(0)
        }
    }
    
    @IBAction func previousButtonPressed(_ sender: UIButton) {
        if (currentIndex > 0){
            SoundManager.stopTutorialSound(currentIndex)
            currentIndex -= 1
            textLabel.text = textArray[currentIndex]
            picture.image = UIImage(named:imageList[currentIndex])
            SoundManager.playTutorialSound(currentIndex)
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if (currentIndex < (imageList.count - 1)){
            SoundManager.stopTutorialSound(currentIndex)
            currentIndex += 1
            textLabel.text = textArray[currentIndex]
            picture.image = UIImage(named:imageList[currentIndex])
            SoundManager.playTutorialSound(currentIndex)
        }
    }
    
    private func replaySound(){
        SoundManager.stopTutorialSound(currentIndex)
        SoundManager.playTutorialSound(currentIndex)
    }
    
    public static func getTutorialTextArray() -> [String]{
        var textArray : [String] = []
        // Welcome 0
        textArray.append("Bienvenue dans le tutoriel du mode édition ! ")
        // Explication modes 1
        textArray.append("Les boutons dans les haut de l'écran représentent le mode d'édition. On y retrouve, de gauche à droite, les modes suivants: Caméra, Sélection, Transformation, Duplication, Ajout d'accélérateur, Ajout de mur, Ajout de portail, Tutoriel, Sauvegarder/Charger, Mode test, Effacer.\n\nPour changer de mode, il suffit d'appuyer sur l'icone du mode désiré.")
        // Camera 2
        textArray.append("Le mode caméra permet de se déplacer dans la scène et de s'approcher ou s'éloigner des objets.\n\nPour se déplacer, il suffit d'appuyer sur la scène puis déplacer son doigt dans la direction désirée.\n\nPour s'approcher ou s'éloigner de la scène. il faut appuyer avec deux doigts en même temps et faire un mouvement de pincement (approcher) ou d'écartèlement (éloigner).")
        // Selection 3
        textArray.append("Le mode sélection permet de sélectionner des éléments de plusieurs façons différentes. Un léger effet de flou est appliqué sur les objects sélectionnés.\n\nIl est possible de sélectionner un item individuellement en le touchant.\n\nIl est possible de sélectionner un groupe d'items en appuyant sur l'écran et en déplaçant son doigt. Dans ce cas, la sélection s'effectue lorsque le doigt est relevé.\n\nLa sélection peut être réinitialisée en appuyant à nouveau sur la scène.")
        // Transfo general 4
        textArray.append("Le mode transformation permet trois actions différentes: déplacer, aggrandir/rétrécir et effectuer une rotation. Il est à noter que les transformations seront effectuées sur les éléments qui sont sélectionnés seulement.")
        // Deplacer 5
        textArray.append("La fonction déplacer permet de déplacer le ou les objet(s) sélectionné(s). Pour se faire, il suffit de poser son doigt et le déplacer tout en le gardant enfoncé. Le déplacement est appliqué lorsque le doigt est relaché.\n\nLes objets ne peuvent être déplacés hors de la zone de jeu et seront restaurés à leur dernière location valide le cas échéant.")
        // Scale 6
        textArray.append("La fonction grossir/rétrécir permet d'ajuster la taille des éléments. Pour se faire, il suffit de poser deux doigts et de les rapprocher (rétrécir) ou les éloigner (aggrandir). L'ajustement est appliqué lorsque les doigts sont retirés de l'écran.\n\nSi la nouvelle taille des éléments fait en sorte qu'ils ne sont plus contenus dans l'aire de jeu, la transformation est annulée.")
        // Rotation 7
        textArray.append("La fonction rotation permet d'ajuster l'angle de rotation des éléments. Pour se faire, il suffit de poser deux doigts et de faire un mouvement de rotation. La rotation est effectuée autour du point central des objets sélectionnés L'ajustement est appliqué lorsque les doigts sont retirés de l'écran.\n\nSi la nouvelle configuration des élément fait en sorte qu'ils ne sont plus contenus dans l'aire de jeu, la transformation est annulée.")
        // Menu transfo 8
        textArray.append("Lorsqu'un seul élément est sélectionné, le menu de transformation s'affiche et permet d'éditer rapidement les charactéristiques des objets.")
        // Dupliquer 9
        textArray.append("Le mode duplication permet de copier les éléments sélectionnés et de conserver leur configuration (position, taille, angle de rotation, etc.). Pour effectuer une duplication, il suffit d'appuyer à l'écran et déplacer son doigt.\n\nLes nouveaux objets seront positionnés sous le doigt jusqu'à ce qu'il soit levé, ce qui viendra déterminer leur placement final. Les objets doivent être contenus dans l'aire de jeu sinon ils ne seront pas créés.")
        // Placer mur 10
        textArray.append("Le mode d'ajout de mur permet de tracer des murs dans l'aire de jeu. Pour se faire, il faut poser son doigt au point de départ du mur, puis le garder enfoncer jusqu'à ce que le point final du mur soit atteint. Une fois que le mur est la longueur désirée, il faut retirer son doigt pour finaliser la création.\n\nLe mur doit être contenu à l'intérieur de la zone de jeu pour être valide, sinon sa création sera annulée.")
        // Placer accelerateur 11
        textArray.append("Le mode d'ajout d'accélérateur permet d'ajouter des accélérateurs à la scène. Pour se faire, il suffit de poser son doigt à l'endroit désiré et de le retirer de l'écran.\n\nUn accélérateur doit être à l'intérieur de la zone de jeu, sinon sa création sera annulée.")
        // Placer portail 12
        textArray.append("Le mode d'ajout de portail permet d'ajouter des paires de portails à la scène. Pour se faire, il suffit de poser son doigt à l'endroit désiré et de le retirer de l'écran une fois par portail. Notez qu'il faut poser les portails par pair de deux.\n\nLes portails doivent être à l'intérieur de la zone de jeu, sinon l'ajout sera annulé.")
        // Points de controles 13
        textArray.append("Le mode ajustement des points de contrôles permet de redimensionner l'aire de jeu. Il est possible d'ajuster jusqu'à 8 points pour changer la forme de l'arène.\n\nCeci étant dit, les points placés sur un axe doivent y rester. De plus,les points de contrôle sont prisoniers de leurs cadrants par rapport au centre de la scène.")
        // Tutoriel 14
        textArray.append("Il est possible à tout moment de revenir consulter le tutoriel en appuyant sur ce bouton.")
        // Sauvegarder / Charger 15
        textArray.append("Ce bouton permet de sauvegarder ou de charger l'aire de jeu localement ou sur le serveur.")
        // Mode test 16
        textArray.append("Ce bouton permet de jouer rapidement contre une intelligence artificielle afin de voir si l'aire de jeu répond à ses attentes.")
        // Supprimer 17
        textArray.append("Ce bouton permet d'effacer les éléments sélectionnés de la scène.")
        // Mode display 18
        textArray.append("Cet indicateur permet de rapidement voir quel mode d'édition est présentement actif.")
        // Config display 19
        textArray.append("Ce bouton permet d'afficher le menu de configuration qui ajuste les valeurs liées à la physique de l'aire de jeu.")
        // Quitter 20
        textArray.append("Ce bouton permet de retourner au menu principal.")
        
        return textArray
    }
    
    public static func getImageArray(_ textArray : [String]?) -> [String]{
//        var imageArray : [String] = []
//
//        if let temp = textArray {
//            for _ in 0...(temp.count - 1){
//                imageArray.append("t_basic")
//            }
//        }
        
        var imageList : [String] = ["t_basic",    //0
                                    "t_basic",
                                    "t_camera",
                                    "t_select",
                                    "t_transform",
                                    "t_move",   //5
                                    "t_scale",
                                    "t_rotation",
                                    "t_menu",
                                    "t_duplicate",
                                    "t_wall",       //10
                                    "t_accelerator",
                                    "t_portal",
                                    "t_controlPoints",
                                    "t_tutorial", //missing
                                    "t_save",       //15
                                    "t_test",         //missing
                                    "t_delete",
                                    "t_previewMode",
                                    "t_configDisplay",
                                    "t_quit"        //20
                                    ]
        
        return imageList
    }
    
    
    
}

