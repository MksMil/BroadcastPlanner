import UIKit
import SpriteKit
import Combine


protocol BPSKViewDelegate: AnyObject {
    func selectPointWithId(_ id: String)
    func deselectPoint() //id?
    
    func updatePoint(x: Double, y: Double, rotation: Double, scaleFactor: Double) //x,y,rotation,scaleFactor
}

final class BPEditStadiumViewModel: ObservableObject {
    
//    var initialPoints: [LocalLocationPoint]
    
    @Published var selectedEventPoint: LocalLocationPoint?
    @Published var isEdit: Bool = false
    
    var localPoints: [LocalLocationPoint]
//    @Published var selectedBroadcaster: LocalBroadcaster?
//    @Published var selectedCar: LocalOBVan?
//    
//    @Published var cars: [LocalOBVan] = []
    
    var renderPitchScene: PitchEditSpriteScene = PitchEditSpriteScene()
//    var renderCarScene: CarEditSpriteScene = CarEditSpriteScene()
  
    init(points: [LocalLocationPoint] = []){
        self.localPoints = points
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
    
    func changeState(){
        if selectedEventPoint != nil{
            isEdit = true
        } else {
            isEdit = false
        }
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
        localPoints.append(point)
        selectedEventPoint = point
        isEdit = true
    }
    
    func deletePoint(){
        renderPitchScene.removeSelectedPoint()
        // TODO: remove LocalLocationPoint
        if let selectedEventPoint {
            localPoints.removeAll { pointToDelete in
                pointToDelete.viewId == selectedEventPoint.viewId
            }
            DataManager.shared.removeLocalLocationPoint(selectedEventPoint, inContext: .main)
        }
        isEdit = false
        selectedEventPoint = nil
    }
    
    func save(){
        renderPitchScene.saveSelectedPoint()
        // TODO: save LocalLocationPoint
        selectedEventPoint = nil
        isEdit = false
    }
    
    func selectPoint(point: LocalLocationPoint){
        selectedEventPoint = point
        renderPitchScene.select(point: point)
//        isEdit = true
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

// MARK: - Control (move,scale,rotate) Points in Stadium Edit Scene
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
        print("rotation clockwise")
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
        selectedEventPoint = localPoints.first(where: {$0.viewId == id})
    }
    
    func deselectPoint(){
        if selectedEventPoint != nil {
            self.selectedEventPoint = nil
        }
        isEdit = false
    }
    
    func deselectPointForRender(){
        if selectedEventPoint != nil {
            self.selectedEventPoint = nil
            renderPitchScene.deselect()
        }
        isEdit = false
    }
    //id?
    
    func updatePoint(x: Double, y: Double, rotation: Double, scaleFactor: Double){
        // TODO: update LocalLocationPoint
    } //x,y
}

// MARK: - Point data control
extension BPEditStadiumViewModel {
    func addUser(user: LocalUser){
        guard let selectedEventPoint else { return }
        if !selectedEventPoint.viewUsers.contains([user]) {
            DataManager.shared.moc.perform {
                selectedEventPoint.addToUser(user)
            }
        } else {
            print("this user: \(user.userLastName) exist in point")
        }
    }
    
    func acceptNubmer(num: Int){
        guard let selectedEventPoint else { return }
        DataManager.shared.moc.perform {
            selectedEventPoint.number = Int16(num)
        }
    }
    
    func addCam(cam: LocalCamera){
        guard let selectedEventPoint else { return }
        DataManager.shared.moc.perform {
            selectedEventPoint.addToCameras(cam)
        }
        
    }
    
    func addSound(sound: LocalSound){
        guard let selectedEventPoint else { return }
        DataManager.shared.moc.perform {
            selectedEventPoint.addToSounds(sound)
        }
        
    }
    
    func addLight(light: LocalLight){
        guard let selectedEventPoint else { return }
        DataManager.shared.moc.perform {
            selectedEventPoint.addToLights(light)
        }
        
    }
    
    func addDescription(desc: String){
        guard let selectedEventPoint else { return }
        DataManager.shared.moc.perform {
            selectedEventPoint.pointDescription = desc
        }
    }
}


