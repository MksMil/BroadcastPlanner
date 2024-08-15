import SwiftUI
import SpriteKit

enum PlanSectionType: String, Identifiable {
    case stadium
    case car
    case none
    
    var id: Self { self }
}

struct BPEditEventPlanPointsView: View {
    var event: Event
    var type: PlanSectionType
    var isEditState: Bool = false
    var isCarEdit: Bool = false
    
    var body: some View {
            SpriteView(scene: loadScene(type: type))
    }
    
    func loadScene(type: PlanSectionType) -> SKScene{
        let scene = BPSpriteEditView()
        scene.isCarEdit = isCarEdit
        scene.type = type
        switch type {
            case .stadium:
                scene.points = event.eventPlan.fieldPoints
            case .car:
                scene.points = event.eventPlan.carPoints
            case .none:
                break
        }
//        vm.renderDelegate = scene
        return scene
    }
    
}

//#Preview {
//    BPEditEventPlanPointsView(type: .stadium)
//        .environmentObject(BPEventViewModel(event: Event()))
//}
#Preview {
    BPCreateEditEventView( event: MockData.sampleEvent)
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalStorage())
        .environmentObject(EventTabRouter())
}
