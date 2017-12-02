//
//  soundManager.swift
//  clientLeger
//
//  Created by Gregory Fournier on 2017-11-22.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import AVFoundation
import SwiftySound
import Foundation

class SoundManager {
    // Background music
    static let bg1 = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "bg1", ofType: "mp3")!) as URL);
    
    // Sounds
    private static let cantPlaceThere = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "cantPlaceThere", ofType: "wav")!) as URL);
    private static let simpleButtonPress = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "error", ofType: "wav")!) as URL);
    private static let goalPoint = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "goalPoint", ofType: "wav")!) as URL);
    private static let hitPuck = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "hitPuck", ofType: "wav")!) as URL);
    private static let hitWall1 = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "hitWall1", ofType: "wav")!) as URL);
    private static let hitWall2 = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "hitWall2", ofType: "wav")!) as URL);
    private static let hitWall3 = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "hitWall3", ofType: "wav")!) as URL);
    private static let hitWallArray = [hitWall1, hitWall2, hitWall3];
    private static let placeItem = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "placeItem", ofType: "wav")!) as URL);
    private static let savedMap = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "savedMap", ofType: "wav")!) as URL);
    private static let error = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "simpleButtonPress", ofType: "wav")!) as URL);
    private static let startGame = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "startGame", ofType: "wav")!) as URL);
    private static let victory = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "victory", ofType: "wav")!) as URL);
    private static let deleteObject = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "delete", ofType: "wav")!) as URL);
    private static let accelSound = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "accelSound", ofType: "wav")!) as URL);
    private static let portalSound = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "portal", ofType: "wav")!) as URL);
    
    private static let tuto_intro = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "00Intro", ofType: "wav")!) as URL);
    private static let tuto_expli_modes = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "01ExplicationModes", ofType: "wav")!) as URL);
    private static let tuto_camera = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "02Camera", ofType: "wav")!) as URL);
    private static let tuto_selection = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "03Selection", ofType: "wav")!) as URL);
    private static let tuto_transfo = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "04TransfoGeneral", ofType: "wav")!) as URL);
    private static let tuto_deplacer = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "05Deplacer", ofType: "wav")!) as URL);
    
    private static let tuto_scale = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "06Scale", ofType: "wav")!) as URL);
    private static let tuto_rotation = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "07Rotation", ofType: "wav")!) as URL);
    private static let tuto_menu_transfo = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "08MenuTransfo", ofType: "wav")!) as URL);
    private static let tuto_dupliquer = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "09Dupliquer", ofType: "wav")!) as URL);
    private static let tuto_placerMur = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "10PlacerMur", ofType: "wav")!) as URL);
    private static let tuto_placerAccel = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "11PlacerAccelerateur", ofType: "wav")!) as URL);
    
    private static let tuto_placerPortail = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "12PlacerPortail", ofType: "wav")!) as URL);
    private static let tuto_pointControle = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "13PointsDeControle", ofType: "wav")!) as URL);
    private static let tuto_tutoriel = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "14Tutoriel", ofType: "wav")!) as URL);
    private static let tuto_saveLoad = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "15SauvegarderCharger", ofType: "wav")!) as URL);
    private static let tuto_test = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "16ModeTest", ofType: "wav")!) as URL);
    private static let tuto_supprimer = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "17Supprimer", ofType: "wav")!) as URL);
    
    private static let tuto_modeDisplay = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "18ModeDisplay", ofType: "wav")!) as URL);
    private static let tuto_configDisplay = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "19ConfigDisplay", ofType: "wav")!) as URL);
    private static let tuto_quitter = Sound(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "20Quitter", ofType: "wav")!) as URL);

    private static let tutorialSounds : [Sound?] = [tuto_intro,tuto_expli_modes,tuto_camera,tuto_selection,tuto_transfo,tuto_deplacer,tuto_scale,tuto_rotation,tuto_menu_transfo,tuto_dupliquer,tuto_placerMur,tuto_placerAccel,tuto_placerPortail,tuto_pointControle,tuto_tutoriel,tuto_saveLoad,tuto_test,tuto_supprimer,tuto_modeDisplay,tuto_configDisplay,tuto_quitter]
    
    public static func playTutorialSound(_ index : Int){
        tutorialSounds[index]?.play()
    }
    
    public static func stopTutorialSound(_ index : Int){
        tutorialSounds[index]?.stop()
    }
    
    public static func startBackgroundMusic() {
        bg1?.play(numberOfLoops: -1);
    }
    
    public static func stopBackgroundMusic() {
        bg1?.stop();
    }
    
    public static func playStartGame() {
        startGame?.play();
    }
    
    public static func playSimpleButtonPress() {
        simpleButtonPress?.play();
    }
    
    public static func playError() {
        error?.play();
    }
    
    public static func playCantPlaceThere() {
        cantPlaceThere?.play();
    }
    
    public static func playPlaceItem() {
        placeItem?.play();
    }
    
    public static func playSaveMap() {
        savedMap?.play();
    }
    
    public static func playGoalPoint() {
        goalPoint?.play();
    }
    
    public static func playVictory() {
        victory?.play();
    }
    
    public static func deleteObjectsPlay() {
        deleteObject?.play();
    }
    
    public static func playAccelSound() {
        accelSound?.play();
    }
    
    public static func playPortalSound() {
        portalSound?.play();
    }
    
    public static func playPuckHitWall() {
        // play random sound
        let index = Int(arc4random_uniform(UInt32(hitWallArray.count)));
        hitWallArray[index]?.play();
    }
    
    //MARK: enable and disable sounds
    
    public static func disableSounds() {
        Sound.enabled = false;
    }
    
    public static func enableSounds() {
        Sound.enabled = true;
    }
    
    public static func setSoundsEnabled(_ enable: Bool) {
        Sound.enabled = enable;
    }
    
    public static func getSoundsEnabled() -> Bool {
        return Sound.enabled;
    }

    
    
}
