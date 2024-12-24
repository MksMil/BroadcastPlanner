import UIKit
//import SwiftUI
import SpriteKit
import Combine


protocol BPSKViewDelegate: AnyObject {
    func selectPointWithId(_ id: String)
    func deselectPoint() //id?
    
    func updatePoint(x: Double, y: Double) //x,y
}

final class BPEditStadiumViewModel: ObservableObject {
    
    var initialPoints: [LocalLocationPoint]
    
    @Published var selectedEventPoint: LocalLocationPoint?
    @Published var isEdit: Bool = false
    var localPoints: [LocalLocationPoint] = []
//    @Published var selectedBroadcaster: LocalBroadcaster?
//    @Published var selectedCar: LocalOBVan?
//    
//    @Published var cars: [LocalOBVan] = []
    
    var renderPitchScene: PitchEditSpriteScene = PitchEditSpriteScene()
//    var renderCarScene: CarEditSpriteScene = CarEditSpriteScene()
  
    init(points: [LocalLocationPoint] = []){
        self.initialPoints = points
        self.renderPitchScene = PitchEditSpriteScene()
        renderPitchScene.pointDelegate = self
    }
    
    func loadScene(){
        //setup pitch scene
//        pitchScene.selectAction =  { [weak self] id in
//            guard let self else { return }
//            if let point = self.event?.viewLocationPoints.first(where: {$0.id == id}){
//                self.selectedEventPoint = point
//            } else {
////                self.selectedEventPoint = LocationPoint()
//            }
//        }
//        pitchScene.deselectAction = { [weak self] in
//            guard let self else { return }
//            self.selectedEventPoint = nil
//        }
//        pitchScene.updatePointCoordinatesAction = { id, coord in }
        
        
        //setup car scene
//        let carScene = CarEditSpriteScene()
//        if let imageName = selectedCar?.imageName,
//            let points = selectedCar?.units{
//            carScene.changeBackground(imageName: imageName)
//            carScene.points = points
//        }
//        renderCarScene = carScene
    }
    
    func configureWith(event: LocalEvent){
//        self.event = event
//        selectedBroadcaster = event.broadcaster
//        selectedCar = event.broadcastCar
        
    }
}

//// MARK: - CarEditScene managment
//extension EditPlanPointsManager{
//    func updateCarScene(units: [OBVanUnit]){
//        renderCarScene.points = units
//        renderCarScene.setupNodes()
//    }
//    
//    func changeTexture(carName: String){
//        renderCarScene.changeBackground(imageName: carName)
//    }
//    
//    func setEnabledToUnit(name: String){
//        print("set in manager \(name), ")
////        if let index = selectedCar?.units.firstIndex(where: {$0.id == name}){
////            selectedCar?.units[index].isEnabled.toggle()
////        }
//        renderCarScene.setNode(name: name)
//    }
//}

// MARK: - Points Managment
extension BPEditStadiumViewModel{
    func addPoint(){
        let  point = DataManager.shared.fetchOrCreateLocationPointWithId(UUID().uuidString, inContext: .main)
        renderPitchScene.addPoint(point: point)
        selectedEventPoint = point
        isEdit = true
    }
    
    func deletePoint(){
        renderPitchScene.removeSelectedPoint()
        // TODO: remove LocalLocationPoint
        isEdit = false
    }
    
    func save(){
        renderPitchScene.saveSelectedPoint()
        // TODO: save LocalLocationPoint
        selectedEventPoint = nil
        isEdit = false
    }
}
 

// MARK: - Scaling scenes
extension BPEditStadiumViewModel {
    func scaleUp(type: PlanSectionType){
        switch type {
            case .stadium:
                renderPitchScene.scaleUp()
            case .car:
//                renderCarScene.scaleUp()
                return
        }
    }
    
    func scaleDown(type: PlanSectionType){
        switch type {
            case .stadium:
                renderPitchScene.scaleDown()
            case .car:
//                renderCarScene.scaleDown()
                return
        }
    }
    
    func resetScale(type: PlanSectionType){
        switch type {
            case .stadium:
                renderPitchScene.resetScale()
            case .car:
//                renderCarScene.resetScale()
                return
        }
    }
    
}

// MARK: - Control Points in Stadium Edit Scene
extension BPEditStadiumViewModel{
    func moveUp(){
        renderPitchScene.moveUP()
    }
    
    func moveDown(){
        renderPitchScene.moveDown()
    }
    
    func moveLeft(){
        renderPitchScene.moveLeft()
    }
    
    func moveRight(){
        renderPitchScene.moveRight()
    }
    
    func rotateClockwise(){
        print("rotztion clockwise")
        renderPitchScene.rotateClockwise()
    }
    
    func rotateCounterClockwise(){
        renderPitchScene.rotateCounterClockwise()
    }
    
    func swap(){
        renderPitchScene.swapSelectedPoint()
    }
    
    func scaleUpPoint(){
        renderPitchScene.scaleUpSelectedPoint()
    }
    
    func scaleDownPoint(){
        renderPitchScene.scaleDownSelectedPoint()
    }
    
}


// MARK: - BPSKViewDelegate
extension BPEditStadiumViewModel: BPSKViewDelegate {
    func selectPointWithId(_ id: String){
//        withAnimation{
            selectedEventPoint = initialPoints.first(where: {$0.viewId == id})
            isEdit = true
//        }
//        if let point = initialPoints.first(where: {$0.viewId == id}) {
//            selectedEventPoint = point
//        }
    }
    
    func deselectPoint(){
        if selectedEventPoint != nil {
            self.selectedEventPoint = nil
        }
        isEdit = false
    }
    //id?
    
    func updatePoint(x: Double, y: Double){
        // TODO: update LocalLocationPoint
    } //x,y
}


