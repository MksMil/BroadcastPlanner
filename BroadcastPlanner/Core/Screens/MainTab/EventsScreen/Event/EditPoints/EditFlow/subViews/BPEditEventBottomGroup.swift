import SwiftUI

struct BPEditEventBottomGroup: View {
    
    @EnvironmentObject var editManager: EditPlanPointsManager
    
    var type: PlanSectionType
    var eventPlan: BPEventPlan
    @Binding var isEdit: Bool
    
    var body: some View {
        if !isEdit {
            BPEditEventStuffListView(type: type, eventPlan: eventPlan)
        } else {
            BPEditEventJoystickInfoPanel(moveUp: editManager.moveUp,
                                         moveDown: editManager.moveDown,
                                         moveLeft: editManager.moveLeft,
                                         moveRight: editManager.moveRight,
                                         rotateLeft: editManager.rotateCounterClockwise,
                                         rotateRight: editManager.rotateClockwise, selectedEventPoint: editManager.selectedEventPoint)
        }
    }
}

#Preview {
    BPEditEventBottomGroup(type: .stadium, eventPlan: MockData.sampleEvent.eventPlan, isEdit: .constant(true))
        .environmentObject(EditPlanPointsManager())
}
