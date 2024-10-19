import SwiftUI

struct BPEditEventBottomGroup: View {
    
    @EnvironmentObject var editManager: EditPlanPointsManager
    
//    var type: PlanSectionType
    let event: Event
    @Binding var isEdit: Bool
    
    var body: some View {
        if !isEdit {
            BPEditEventStuffListView(event: event)
        } else {
            BPEditEventJoystickInfoPanel(moveUp: editManager.moveUp,
                                         moveDown: editManager.moveDown,
                                         moveLeft: editManager.moveLeft,
                                         moveRight: editManager.moveRight,
                                         rotateLeft: editManager.rotateCounterClockwise,
                                         rotateRight: editManager.rotateClockwise,
                                         selectedEventPoint: editManager.selectedEventPoint)
        }
    }
}

//#Preview {
//    BPEditEventBottomGroup(event: MockData.sampleEvent,
//                           isEdit: .constant(true))
//        .environmentObject(EditPlanPointsManager())
//}
