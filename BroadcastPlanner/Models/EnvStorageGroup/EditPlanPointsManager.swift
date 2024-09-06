import UIKit
import SpriteKit
import Combine

final class EditPlanPointsManager: ObservableObject {
    typealias RenderDelegate = SKScene & BPPlanDelegateProtocol
    
    @Published var eventPlan: BPEventPlan?
    @Published var selectedEventPoint: BPEventPlanPoint?
    
    var renderScene: RenderDelegate = BPSpriteEditScene()
    
    init(){
        loadScene(type: .none)
    }
    
    func loadScene(type: PlanSectionType){
        let scene = BPSpriteEditScene()
//        scene.backgroundName = event.eventPlan.background
//        scene.type = type
//        scene.isPreview = isPreview
//        scene.manager = editManager
//        switch type {
//            case .stadium:
//                scene.points = event.eventPlan.fieldPoints
//            case .car:
//                scene.points = event.eventPlan.carPoints
//            case .none:
//                scene.points = []
//        }
//        editManager.renderDelegate = scene
//        return scene
        scene.selectAction = {[weak self] point in
            guard let self else { return }
            self.selectedEventPoint = point
            
        }
        renderScene = scene
    }
    
    func configureWith(event: Event){
        self.eventPlan = event.eventPlan
    }
    
    func addPoint(){
        let point = BPEventPlanPoint()
        renderScene.addPoint(point: point)
        selectedEventPoint = point
    }
    
    func deletePoint(){
        renderScene.removeSelectedPoint()
    }
    
    func save(){
        renderScene.saveSelectedPoint()
    }
    
    func scaleUp(){
        renderScene.scaleUp()
    }
    
    func scaleDown(){
        renderScene.scaleDown()
    }
 
    func resetScale(){
        renderScene.resetScale()
    }
    
    func moveUp(){
        renderScene.moveUP()
    }
    
    func moveDown(){
        renderScene.moveDown()
    }
    
    func moveLeft(){
        renderScene.moveLeft()
    }
    
    func moveRight(){
        renderScene.moveRight()
    }
    
    func rotateClockwise(){
        renderScene.rotateClockwise()
    }
    
    func rotateCounterClockwise(){
        renderScene.rotateCounterClockwise()
    }
}
