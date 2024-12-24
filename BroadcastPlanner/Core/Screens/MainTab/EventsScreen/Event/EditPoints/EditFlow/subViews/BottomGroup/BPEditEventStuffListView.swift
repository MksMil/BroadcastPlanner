import SwiftUI

struct BPEditEventStuffListView: View {
    @EnvironmentObject var editManager: BPEditStadiumViewModel
    
    let event: BPEvent
    @State var selectedEventPoint: LocationPoint?
    let selectAction: (LocationPoint) -> Void = { _ in }
    
    var body: some View {
        ScrollView{
//                ForEach(event.locationPoints) { point in
                    Text("1")
                        .fixedSize()
                        .padding(10)
                        .frame(width: 115, height: 50)
//                        .background(selectedEventPoint?.id == point.id ?  .ultraThickMaterial : .ultraThinMaterial
//                        )
//                        .onTapGesture {
//                            withAnimation {
//                                selectAction(point)
//                            }
//                        }
//            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .padding()
        }
    }
}

//#Preview {
//    BPEditEventStuffListView(event: MockData.sampleEvent)
//        .environmentObject(EditPlanPointsManager())
//}
