import SwiftUI
import SpriteKit

struct BPEditEventPointLinks: View {
    @EnvironmentObject var editManager: EditPlanPointsManager
//    let event: Event
    let actionLeft: () -> Void
    let actionRight: () -> Void
    
    var body: some View {
        GeometryReader{ geo in
            HStack(spacing: 15){
                
                SpriteView(scene: editManager.renderPitchScene)
                    .frame(width: 3 * geo.size.width / 4,
                           height: geo.size.height)
                    .onTapGesture {
                        actionLeft()
                    }
                
                SpriteView(scene: editManager.renderCarScene)
                    .frame(height: geo.size.height)
                    .onTapGesture {
                        actionRight()
                    }
                    
            }
        }
    }
}

//#Preview {
//    BPEditEventPointLinks( linkTapped: .constant(.none))
//        .environmentObject(BPEventViewModel(event: MockData.sampleEvent))
//}
//#Preview {
//    BPCreateEditEventView( event: MockData.sampleEvent)
//        .environmentObject(GlobalSettings())
//        .environmentObject(GlobalStorage())
//        .environmentObject(EventTabRouter())
//        .environmentObject(GlobalTimer())
//        .environmentObject(EditPlanPointsManager())
//        
//}
