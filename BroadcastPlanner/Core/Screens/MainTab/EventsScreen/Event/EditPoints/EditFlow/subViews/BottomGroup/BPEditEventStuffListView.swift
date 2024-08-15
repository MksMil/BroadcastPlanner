import SwiftUI

struct BPEditEventStuffListView: View {
    var type: PlanSectionType
    var eventPlan: BPEventPlan
    var selectedEventPoint: BPEventPlanPoint?
    let selectAction: (BPEventPlanPoint) -> Void = { _ in }
    
    var body: some View {
        ScrollView{
            SmartLayout(hSpacing: 5, vSpacing: 5){
                ForEach(makePoints()) { point in
                    Text("\(point.eventPlanPointNumber)")
                        .fixedSize()
                        .padding(10)
                        .frame(width: 115, height: 50)
                        .background(selectedEventPoint?.id == point.id ?  .ultraThickMaterial : .ultraThinMaterial
                        )
                        .onTapGesture {
                            withAnimation {
                                selectAction(point)
                            }
                        }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .padding()
        }
    }
        private func makePoints() -> [BPEventPlanPoint]{
            switch type {
                case .stadium:
                    return eventPlan.fieldPoints
                case .car:
                    return eventPlan.carPoints
                case .none:
                    return []
            }
        }
    
}

#Preview {
    BPEditEventStuffListView(type: .stadium, eventPlan: MockData.sampleEvent.eventPlan)
}
