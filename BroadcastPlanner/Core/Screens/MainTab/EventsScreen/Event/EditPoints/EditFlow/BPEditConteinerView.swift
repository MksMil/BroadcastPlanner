import SwiftUI
import SpriteKit

struct BPEditConteinerView: View {
    
    @Environment(\.dismiss) var dismiss
    var event: Event
    var type: PlanSectionType = .car
    
    @State var isEditState: Bool = false
    @State private var stadiumFilter: BPEventPlanPointStadiumFilter = .all
    @State private var carFilter: BPEventPlanPointCarFilter = .all
    
    var filteredStadiumPoints: [BPEventPlanPoint] {
        let points = event.eventPlan.fieldPoints
        
        switch stadiumFilter {
            case .all:
                return points
            case .cam:
                return points.filter { point in
                    point.cam.optic != .none
                }
            case .light:
                return points.filter { point in
                    point.light.lightType != .none
                }
            case .mic:
                return points.filter { point in
                    point.mic.placeType != .none
                }
        }
    }
    var filteredCarPoints: [BPEventPlanPoint] {
        let points = event.eventPlan.carPoints
        
        switch carFilter {
            case .all:
                return points
            case .dir:
                return points.filter { point in
                    //                        point.cam.optic != .none
                    true
                }
            case .rep:
                return points.filter { point in
                    //                        point.light.lightType != .none
                    true
                }
            case .grf:
                return points.filter { point in
                    //                        point.mic.placeType != .none
                    true
                }
            case .sou:
                return points.filter { point in
                    //                        point.mic.placeType != .none
                    true
                }
        }
        
    }
    
    var body: some View {
        ZStack{
            MainBackground()
//                .opacity(0.2)
            VStack{
                //filter
                Rectangle().fill(.ultraThinMaterial)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .overlay {
                        HStack(spacing: 0){
                            
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.title)
                            }
                            .padding(.leading,30)
                            Spacer()
                            if type == .stadium{
                                BPEventFilterCaseTabView(selectedTab:  $stadiumFilter)
                            } else {
                                BPEventFilterCaseTabView(selectedTab:  $carFilter)
                            }
                            Spacer()
                        }
                    }
                //SKView
                
                BPEditEventPlanPointsView(event: event,
                                          type: type,
                                          isEditState: isEditState,
                                          isCarEdit: type == .car)
                    .aspectRatio(1.5, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                  
                //control panel
                BPEditEventControlPanel()
                    .padding(.horizontal)
//                    .randomColorBackground()
                //users collection
                
                BPEditEventBottomGroup(type: type,
                                       eventPlan: event.eventPlan)
//                    .randomColorBackground()
                .padding(.horizontal)
            }
            
        }
//        .randomColorBackground()
    }
}

#Preview {
    BPEditConteinerView(event: MockData.sampleEvent,
                        type: .car) 
    
}
