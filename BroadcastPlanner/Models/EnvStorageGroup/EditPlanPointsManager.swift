import UIKit
import SpriteKit
import Combine

final class EditPlanPointsManager: ObservableObject {
//    typealias RenderDelegate = SKScene & BPPlanDelegateProtocol
    
    @Published var eventPlan: BPEventPlan?
    @Published var selectedEventPoint: BPEventPlanPoint?
    
    @Published var selectedBroadcater: Broadcaster?
    @Published var selectedCar: BroadcasterCar?
    
    @Published var cars: [BroadcasterCar] = []
    
    var renderPitchScene: PitchEditSpriteScene = PitchEditSpriteScene()
    var renderCarScene: CarEditSpriteScene = CarEditSpriteScene()
    var previewCar: PreviewCarScene = PreviewCarScene()
    
    var cancellables: [AnyCancellable] = []
    
    init(){
        loadScene(isPreview: true)
        configurePublishers()
    }
    
    func setupPreview(){
        if let imageName = selectedCar?.imageName {
            previewCar.changeBackground(imageName: imageName)
        } else {
            previewCar.changeBackground(imageName: "empty_obvan")
        }
    }
    
    func configurePublishers(){
        $selectedBroadcater.sink { [weak self] broadcaster in
            guard let self else { return }
            if let broadcaster {
                self.cars = broadcaster.cars
                self.selectedCar = nil
            } else {
                self.cars = []
                self.changeTexture(carName: "empty_obvan")
            }
        }
        .store(in: &cancellables)
        
        $selectedCar.sink { [weak self] car in
            guard let self else { return }
            if let car {
                self.changeTexture(carName: car.imageName)
                self.previewCar.changeBackground(imageName: car.imageName)
            } else {
                self.changeTexture(carName: "empty_obvan")
                self.previewCar.changeBackground(imageName: "empty_obvan")
            }
            
        }
        .store(in: &cancellables)
    }
    
    func loadScene(isPreview: Bool){
        //setup pitch scene
        let pitchScene = PitchEditSpriteScene()
        
//        scene.isPreview = isPreview

        pitchScene.selectAction =  { [weak self] id in
            guard let self else { return }
            if let point = self.eventPlan?.fieldPoints.first(where: {$0.id == id}){
                self.selectedEventPoint = point
            } else {
                    self.selectedEventPoint = BPEventPlanPoint()
                }
        }
        pitchScene.deselectAction = { [weak self] in
            guard let self else { return }
            self.selectedEventPoint = nil
        }
        
        pitchScene.updatePointCoordinatesAction = { id, coord in
            
        }
        renderPitchScene = pitchScene
        
        //setup car scene
        let carScene = CarEditSpriteScene()
        carScene.isPreview = isPreview
        if let imageName = selectedCar?.imageName{
            carScene.changeBackground(imageName: imageName)
        }
        renderCarScene = carScene
    }
    
    func configureWith(event: Event){
        self.eventPlan = event.eventPlan
        selectedBroadcater = event.broadcaster
        selectedCar = event.broadcastCar
    }
    
    func update(type: PlanSectionType){
        guard let eventPlan else { return }
        renderPitchScene.points = type == .stadium ? eventPlan.fieldPoints: eventPlan.carPoints
    }
    
    func changeTexture(carName: String){
        renderCarScene.changeBackground(imageName: carName)
    }
    
    func addPoint(){
        let point = BPEventPlanPoint()
        renderPitchScene.addPoint(point: point)
        selectedEventPoint = point
    }
    
    func deletePoint(){
        renderPitchScene.removeSelectedPoint()
    }
    
    func save(){
        renderPitchScene.saveSelectedPoint()
    }
    
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
