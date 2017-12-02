//
//  MorphBorderMode.swift
//  clientLeger
//
//  Created by Marco on 2017-10-28.
//  Copyright © 2017 Gregory Fournier. All rights reserved.
//

import Foundation
import SpriteKit

class MorphBorderMode: EditMode {
    
    var editScene : EditionModeScene;
    var modifiedNodeIndex : Int
    var symmetricalNodeIndex : Int
    
    init(_ scene: EditionModeScene) {
        editScene = scene;
        modifiedNodeIndex = -1
        symmetricalNodeIndex = -1
        super.init();
        self.name = "MorphBorderMode"
    }
    
    override func onSingleTap(_ xCord: CGFloat, _ yCord: CGFloat) {
        super.onSingleTap(xCord, yCord);
        updateLatestContactPoint(xCord, yCord);
        let clickPoint : CGPoint = convertScreenCoordinatesToScene(editScene, xCord, yCord);
        modifiedNodeIndex = getMorphPointIndexAt(clickPoint)
        symmetricalNodeIndex = getSymmetricalPointIndex(modifiedNodeIndex)
        for morphPoint in editScene.morphPoints {
            morphPoint.setUpBackup()
        }
        for borderWall in editScene.borderWalls {
            borderWall.setUpBackup()
        }
        for goalObject in editScene.goalSections{
            goalObject.setUpBackup()
        }
    }
    
    override func onSingleFingerSlide(_ newX: CGFloat, _ newY: CGFloat) {
        super.onSingleFingerSlide(newX, newY)
        let deltaPoint: CGPoint = getPositionDiff(newX, newY)
        
        updateNodePositions(deltaPoint, modifiedNodeIndex, symmetricalNodeIndex)
        updateLatestContactPoint( newX, newY)
    }
    
    public func updatePointFromOnline(_ index: Int, _ newX: CGFloat, _ newY: CGFloat) {
        let deltaPoint: CGPoint = getPositionDiff(newX, newY)
        modifiedNodeIndex = index;
        symmetricalNodeIndex = getSymmetricalPointIndex(modifiedNodeIndex)
        
        updateNodePositions(deltaPoint, modifiedNodeIndex, symmetricalNodeIndex)
        updateLatestContactPoint( newX, newY)
    }
    
    func updateNodePositions(_ deltaPoint : CGPoint, _ indexTouched : Int, _ indexSymm : Int) {
        if (indexTouched < 0 || indexTouched > 8){
            return
        }
        if (indexTouched == 1 || indexTouched == 5){
            handleXAxis(indexTouched,indexSymm,deltaPoint)
        }
        else if (indexTouched == 3 || indexTouched == 7){
            handleYAxis(indexTouched,indexSymm,deltaPoint)
        }
        else {
            handleCorners(indexTouched,indexSymm,deltaPoint)
        }

    }
    
    override func onTouchEnded(_ newX: CGFloat, _ newY: CGFloat) {
        
        var sendToServer : Bool = true
        if (!validateBoardItems()){
            for morphPoint in editScene.morphPoints {
                morphPoint.restoreBackup()
            }
            for borderWall in editScene.borderWalls {
                borderWall.restoreBackup()
                borderWall.size.height = EditionModeUtils.distanceBetween(borderWall.startPoint, borderWall.endPoint)
            }
            for goalObject in editScene.goalSections{
                goalObject.restoreBackup()
            }
            editScene.refreshFloor()
            sendToServer = false
        }
        
        if (SocketIOManager.sharedInstance.isConnected() && EditionModeController.canSelectMorphPoints && sendToServer) {
            for index in 0...(editScene.morphPoints.count-1) {
                SocketIOManager.sharedInstance.moveMorphPointsOnline(index, editScene.morphPoints[index].position);
            }
        }
    
        modifiedNodeIndex = -1
        symmetricalNodeIndex = -1
    }
    
    public func validateBoardItems() -> Bool{
        return EditionModeUtils.canPlaceAllItems(editScene.editableItems, editScene)
    }
    
    private func handleXAxis(_ regularIndex : Int, _ symmIndex : Int, _ regularDelta: CGPoint){
        let currentPositionTouched : CGPoint = editScene.morphPoints[regularIndex].position
        let newPositionTouched : CGPoint = CGPoint(x:currentPositionTouched.x + regularDelta.x, y:currentPositionTouched.y)
        
        let currentPositionSymm : CGPoint = editScene.morphPoints[symmIndex].position
        let newPositionSymm : CGPoint = CGPoint(x:currentPositionSymm.x - regularDelta.x, y:currentPositionSymm.y)
        
        let adjustedReg = limitMovementToQuad(regularIndex, newPositionTouched)
        let adjustedSym = limitMovementToQuad(symmIndex, newPositionSymm)
        
        updateCoords(adjustedReg, regularIndex)
        updateCoords(adjustedSym, symmIndex)
        adjustGoalsFromXMorph()
    }
    
    private func handleYAxis(_ regularIndex : Int,_ symmIndex : Int, _ regularDelta: CGPoint){
        let currentPositionTouched : CGPoint = editScene.morphPoints[regularIndex].position
        let newPositionTouched : CGPoint = CGPoint(x:currentPositionTouched.x, y:currentPositionTouched.y - regularDelta.y)
        
        let currentPositionSymm : CGPoint = editScene.morphPoints[symmIndex].position
        let newPositionSymm : CGPoint = CGPoint(x:currentPositionSymm.x, y:currentPositionSymm.y + regularDelta.y)
        
        let adjustedReg = limitMovementToQuad(regularIndex, newPositionTouched)
        let adjustedSym = limitMovementToQuad(symmIndex, newPositionSymm)
        
        updateCoords(adjustedReg, regularIndex)
        updateCoords(adjustedSym, symmIndex)
    }
    
    private func handleCorners(_ regularIndex : Int, _ symmIndex : Int, _ deltaPoint: CGPoint){
        let currentPositionTouched : CGPoint = editScene.morphPoints[regularIndex].position
        let newPositionTouched : CGPoint = CGPoint(x:currentPositionTouched.x + deltaPoint.x, y:currentPositionTouched.y - deltaPoint.y)
    
        let currentPositionSymm : CGPoint = editScene.morphPoints[symmIndex].position
        let newPositionSymm : CGPoint = CGPoint(x:currentPositionSymm.x - deltaPoint.x, y:currentPositionSymm.y - deltaPoint.y)
        
        let adjustedReg = limitMovementToQuad(regularIndex, newPositionTouched)
        let adjustedSym = limitMovementToQuad(symmIndex, newPositionSymm)
        
        updateCoords(adjustedReg, regularIndex)
        updateCoords(adjustedSym, symmIndex)
        adjustGoalsFromCornerMorph(regularIndex)
    }
    
    private func limitMovementToQuad(_ index : Int, _ newPosition : CGPoint) -> CGPoint{
        var limitedPosition : CGPoint = newPosition
        switch index {
        case 0 :
            if (newPosition.x > 0){
                limitedPosition.x = 0
            }
            if (newPosition.y > 0){
                limitedPosition.y = 0
            }
            break
        case 1 :
            if (newPosition.x > 0){
                limitedPosition.x = 0
            }
            if (newPosition.y != 0){
                limitedPosition.y = 0
            }
            break
        case 2 :
            if (newPosition.x > 0){
                limitedPosition.x = 0
            }
            if (newPosition.y < 0){
                limitedPosition.y = 0
            }
            break
        case 3 :
            if (newPosition.x != 0){
                limitedPosition.x = 0
            }
            if (newPosition.y < 0){
                limitedPosition.y = 0
            }
            break
        case 4 :
            if (newPosition.x < 0){
                limitedPosition.x = 0
            }
            if (newPosition.y < 0){
                limitedPosition.y = 0
            }
            break
        case 5 :
            if (newPosition.x < 0){
                limitedPosition.x = 0
            }
            if (newPosition.y != 0){
                limitedPosition.y = 0
            }
            break
        case 6 :
            if (newPosition.x < 0){
                limitedPosition.x = 0
            }
            if (newPosition.y > 0){
                limitedPosition.y = 0
            }
            break
        case 7 :
            if (newPosition.x != 0){
                limitedPosition.x = 0
            }
            if (newPosition.y > 0){
                limitedPosition.y = 0
            }
            break
        default:
            break
        }
        
        return limitedPosition
    }
    
    func updateCoords(_ coords : CGPoint, _ index : Int){
        editScene.morphPoints[index].position = coords
        
        let startPointWallIndex : Int = index
        var endPointWallIndex : Int = (index - 1)
        if (endPointWallIndex == -1){
            endPointWallIndex = 7
        }
        
        editScene.borderWalls[startPointWallIndex].startPoint = coords
        editScene.borderWalls[endPointWallIndex].endPoint = coords
        EditionModeUtils.adjustWallNodePosition(editScene.borderWalls[startPointWallIndex])
        EditionModeUtils.adjustWallNodePosition(editScene.borderWalls[endPointWallIndex])
        
        editScene.refreshFloor()
    }
    
    func getMorphPointIndexAt(_ point: CGPoint) -> Int{
        for i in 0...(editScene.morphPoints.count-1) {
            if (editScene.morphPoints[i].contains(point)){
                return i
            }
        }
        return -1
    }
    
    func getSymmetricalPointIndex(_ index : Int) -> Int{
        switch index {
            case EditionModeUtils.MP_LEFTMID: return EditionModeUtils.MP_RIGHTMID
            case EditionModeUtils.MP_LEFTTOP: return EditionModeUtils.MP_RIGHTTOP
            case EditionModeUtils.MP_LEFTBOTTOM: return EditionModeUtils.MP_RIGHTBOTTOM
            case EditionModeUtils.MP_RIGHTMID: return EditionModeUtils.MP_LEFTMID
            case EditionModeUtils.MP_RIGHTTOP: return EditionModeUtils.MP_LEFTTOP
            case EditionModeUtils.MP_RIGHTBOTTOM: return EditionModeUtils.MP_LEFTBOTTOM
            case EditionModeUtils.MP_CENTERTOP: return EditionModeUtils.MP_CENTERBOTTOM
            case EditionModeUtils.MP_CENTERBOTTOM: return EditionModeUtils.MP_CENTERTOP
            default: return -1
        }
    }
    
    private func adjustGoalsFromXMorph(){
        EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[0], editScene.goalSections[0])
        EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[1], editScene.goalSections[1])
        EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[4], editScene.goalSections[2])
        EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[5], editScene.goalSections[3])
    }
    
    private func adjustGoalsFromCornerMorph(_ index : Int){
        if (index == EditionModeUtils.MP_LEFTTOP || index == EditionModeUtils.MP_RIGHTTOP){
            EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[1], editScene.goalSections[1])
            EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[4], editScene.goalSections[2])
        }
        else {
            EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[0], editScene.goalSections[0])
            EditionModeUtils.adjustGoalFromBorderWall(editScene.borderWalls[5], editScene.goalSections[3])
        }
    }
    
}
