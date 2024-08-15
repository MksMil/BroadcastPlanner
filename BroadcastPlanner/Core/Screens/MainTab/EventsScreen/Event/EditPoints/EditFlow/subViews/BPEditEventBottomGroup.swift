import SwiftUI

struct BPEditEventBottomGroup: View {
    var type: PlanSectionType
    var eventPlan: BPEventPlan
    var isEdit: Bool = false
    
    var body: some View {
        if !isEdit {
            BPEditEventStuffListView(type: type, eventPlan: eventPlan)
        } else {
            BPEditEventJoystickInfoPanel()
        }
    }
}

#Preview {
    BPEditEventBottomGroup(type: .stadium, eventPlan: MockData.sampleEvent.eventPlan)
}
