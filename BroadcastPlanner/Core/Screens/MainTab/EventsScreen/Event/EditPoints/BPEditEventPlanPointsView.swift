import SwiftUI
import SpriteKit

enum PlanSectionType: String, Identifiable {
    case stadium
    case car
    case none
    
    var id: Self { self }
}

struct BPEditEventPlanPointsView: View {
    @EnvironmentObject var editManager: EditPlanPointsManager
    
    var event: Event
    var type: PlanSectionType
    var isPreview: Bool
    var isEditState: Bool = false
    
    var body: some View {
        SpriteView(scene: loadScene(type: type))
    }
    
    func loadScene(type: PlanSectionType) -> SKScene{
        let scene = BPSpriteEditScene()
        scene.type = type
        scene.isPreview = isPreview
        switch type {
            case .stadium:
                scene.points = event.eventPlan.fieldPoints
            case .car:
                scene.points = event.eventPlan.carPoints
            case .none:
                scene.points = []
        }
        return scene
    }
    
    
}

#Preview {
    BPEditEventPlanPointsView(event: MockData.sampleEvent, type: .stadium, isPreview: true)
        .environmentObject(EditPlanPointsManager())
}
//#Preview {
//    BPCreateEditEventView( event: MockData.sampleEvent)
//        .environmentObject(GlobalSettings())
//        .environmentObject(GlobalStorage())
//        .environmentObject(EventTabRouter())
//        .environmentObject(GlobalTimer())
//}
