import SwiftUI

struct BPEditEventStuffListView: View {
    @EnvironmentObject var editManager: BPEditStadiumViewModel
    
    let event: EventDTO
    @State var selectedEventPoint: PointDTO?
    let selectAction: (PointDTO) -> Void = { _ in }
    
    var body: some View {
        ScrollView{
//                ForEach(event.locationPoints) { point in
                    Text("1")
                        .fixedSize()
                        .padding(10)
                        .frame(width: 115, height: 50)

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
