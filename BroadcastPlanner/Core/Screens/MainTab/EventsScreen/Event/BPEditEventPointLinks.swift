import SwiftUI

struct BPEditEventPointLinks: View {
    let event: Event
    let actionLeft: () -> Void
    let actionRight: () -> Void
    
    var body: some View {
        GeometryReader{ geo in
            HStack(spacing: 15){
                
                BPEditEventPlanPointsView(event: event, type: .stadium)
                    .frame(width: 3 * geo.size.width / 4,
                           height: geo.size.height)
                    .onTapGesture {
                        print("stad tapped")
                        actionLeft()
                    }
                
                
                BPEditEventPlanPointsView(event: event, type: .car)
                    .frame(height: geo.size.height)
                    .onTapGesture {
                        print("stad tapped")
                        actionRight()
                    }
                
            }
//            .border(.blue, width: 2)
        }
    }
}

//#Preview {
//    BPEditEventPointLinks( linkTapped: .constant(.none))
//        .environmentObject(BPEventViewModel(event: MockData.sampleEvent))
//}
#Preview {
    BPCreateEditEventView( event: MockData.sampleEvent)
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalStorage())
        .environmentObject(EventTabRouter())
}
