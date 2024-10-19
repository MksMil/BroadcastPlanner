import UIKit
import SpriteKit
import Combine

final class EditPlanPointsManager: ObservableObject {
    
    var event: LocalEvent?
    
    @Published var selectedEventPoint: LocalLocationPoint?
    
    @Published var selectedBroadcaster: Broadcaster?
    @Published var selectedCar: OBVan?
    
    @Published var cars: [OBVan] = []
    
    var renderPitchScene: PitchEditSpriteScene = PitchEditSpriteScene()
    var renderCarScene: CarEditSpriteScene = CarEditSpriteScene()
    
    var previewCar: PreviewCarScene = PreviewCarScene()
    var previewStadium: PreviewStadiumScene = PreviewStadiumScene()
    
    var cancellables: [AnyCancellable] = []
    
    init(){
        loadScene()
        configurePublishers()
    }
    
    func setupPreview(){
//        if let imageName = selectedCar?.imageName {
//            previewCar.changeBackground(imageName: imageName)
//        } else {
//            previewCar.changeBackground(imageName: "empty_obvan")
//        }
    }
    
    func configurePublishers(){
//        $selectedBroadcaster.sink { [weak self] broadcaster in
//            guard let self else { return }
//            if let broadcaster {
//                print("cars assigned")
//                self.cars = broadcaster.cars
//                self.selectedCar = nil
//            } else {
//                self.cars = []
//                self.changeTexture(carName: "empty_obvan")
//            }
//        }
//        .store(in: &cancellables)
//        
//        $selectedCar.sink { [weak self] car in
//            guard let self else { return }
//            if let car {
//                self.changeTexture(carName: car.imageName)
//                self.previewCar.changeBackground(imageName: car.imageName)
//            } else {
//                self.changeTexture(carName: "empty_obvan")
//                self.previewCar.changeBackground(imageName: "empty_obvan")
//            }
//            self.updateCarScene(units: car?.units ?? [])
//        }
//        .store(in: &cancellables)
    }
    
    func loadScene(){
        //setup pitch scene
        let pitchScene = PitchEditSpriteScene()
        pitchScene.selectAction =  { [weak self] id in
            guard let self else { return }
            if let point = self.event?.viewLocationPoints.first(where: {$0.id == id}){
                self.selectedEventPoint = point
            } else {
//                self.selectedEventPoint = LocationPoint()
            }
        }
        pitchScene.deselectAction = { [weak self] in
            guard let self else { return }
            self.selectedEventPoint = nil
        }
        pitchScene.updatePointCoordinatesAction = { id, coord in }
        
        renderPitchScene = pitchScene
        
        //setup car scene
        let carScene = CarEditSpriteScene()
//        if let imageName = selectedCar?.imageName,
//            let points = selectedCar?.units{
//            carScene.changeBackground(imageName: imageName)
//            carScene.points = points
//        }
        renderCarScene = carScene
    }
    
    func configureWith(event: LocalEvent){
        self.event = event
//        selectedBroadcaster = event.broadcaster
//        selectedCar = event.broadcastCar
        
    }
}

// MARK: - CarEditScene managment
extension EditPlanPointsManager{
    func updateCarScene(units: [OBVanUnit]){
        renderCarScene.points = units
        renderCarScene.setupNodes()
    }
    
    func changeTexture(carName: String){
        renderCarScene.changeBackground(imageName: carName)
    }
    
    func setEnabledToUnit(name: String){
        print("set in manager \(name), ")
//        if let index = selectedCar?.units.firstIndex(where: {$0.id == name}){
//            selectedCar?.units[index].isEnabled.toggle()
//        }
        renderCarScene.setNode(name: name)
    }
}

// MARK: - Points Managment
extension EditPlanPointsManager{
    func addPoint(){
//        let point = LocationPoint()
//        renderPitchScene.addPoint(point: point)
//        selectedEventPoint = point
    }
    
    func deletePoint(){
        renderPitchScene.removeSelectedPoint()
    }
    
    func save(){
        renderPitchScene.saveSelectedPoint()
    }
}
 

// MARK: - Scaling scenes
extension EditPlanPointsManager {
    func scaleUp(type: PlanSectionType){
        switch type {
            case .stadium:
                renderPitchScene.scaleUp()
            case .car:
                renderCarScene.scaleUp()
        }
    }
    
    func scaleDown(type: PlanSectionType){
        switch type {
            case .stadium:
                renderPitchScene.scaleDown()
            case .car:
                renderCarScene.scaleDown()
        }
    }
    
    func resetScale(type: PlanSectionType){
        switch type {
            case .stadium:
                renderPitchScene.resetScale()
            case .car:
                renderCarScene.resetScale()
        }
    }
    
}

// MARK: - Move Points in Stadium Edit Scene
extension EditPlanPointsManager{
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
        renderPitchScene.rotateClockwise()
    }
    
    func rotateCounterClockwise(){
        renderPitchScene.rotateCounterClockwise()
    }
}
