import SwiftUI

struct BPEditEventCarView: View {
    @Environment(\.dismiss) var dismiss

// MARK: - Actions
    let select: (BPEventPlanPoint) -> Void = { _ in }
    let upAction: () -> Void = {}
    let downAction: () -> Void = {}
    let leftAction: () -> Void = {}
    let rightAction: () -> Void = {}
    let rotationLeftAction: () -> Void = {}
    let rotationRightAction: () -> Void = {}
    

    var isEdit: Bool = false
    var event: Event
    var selectedEventPoint: BPEventPlanPoint?
    
    @State var pointFilter: BPEventPlanPointCarFilter = .all
    
    var body: some View {
        ZStack{
            
            MainBackground()
            
            //event plan view + filter
            VStack{
               
                Rectangle().fill(.ultraThinMaterial)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .overlay {
                        BPEventFilterCaseTabView(selectedTab: $pointFilter)
//                            .padding(.horizontal,20)
                    }
            
//                BPEditEventPlanPointsView(
//                    scaleFactor: 1,
//                    filter: pointFilter,
//                    type: .car,
//                    isEditState: true
//                    
//                )
//                .frame(height: 300)
                
                if !isEdit{
                    ScrollView{
                        SmartLayout(hSpacing: 5, vSpacing: 5){
                            ForEach(event.eventPlan.carPoints) { point in
                                Text("\(point.eventPlanPointNumber)")
                                    .fixedSize()
                                    .padding(10)
                                    .frame(width: 115, height: 50)
                                    .background(selectedEventPoint?.id == point.id ?  .ultraThickMaterial : .ultraThinMaterial
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            select(point)
                                        }
                                    }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(.inset)
                        .padding()
                    }
                } else {
                    
                    HStack{
                        ScrollView {
                            VStack{
                                HStack{
                                    VStack(alignment: .leading,spacing: 3){
                                        BPUserImageNameCompactCell(user: selectedEventPoint?.user)
                                        BPPositionCompactCell(pointPositionName: selectedEventPoint?.coordinates.description)
                                    }
                                    Spacer()
                                    Circle()
                                        .frame(width: 45)
                                        .padding(.vertical,10)
                                        .overlay {
                                            Text(String(selectedEventPoint?.eventPlanPointNumber ?? Int.random(in: 1..<20)))
                                                .font(.title)
                                                .bold()
                                                .foregroundStyle(.white)
                                        }
                                }
                                VStack(alignment: .leading,spacing: 3){
                                    Divider()
                                    BPCameraCompactCell(camDescription: "---")
                                    BPMicCompactCell(micDescription: "---")
                                    BPLightCompactCell(lightDescription: "---")
                                    BPEnvCompactCell(envDescription: "---")
                                }
                            .frame(maxWidth: .infinity,alignment: .leading)
                            }
                            .padding(.horizontal,10)
                        }
//                        .scrollDisabled(true)
                        .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
                        .padding(.leading)
                        .padding(.bottom)
                        
                        Spacer()
                        
                        VStack{
                            
                            BPJoystick(
                                upAction: upAction,
                                downAction: downAction,
                                leftAction: leftAction,
                                rightAction: rightAction,
                                rotationLeft: rotationLeftAction,
                                rotationRight: rotationRightAction
                            )
                            .frame(width: 100, height: 100)
                            .padding(.top)
                            .padding(.trailing)
                            BPEventPlanPointImage()
                                .frame(width: 75, height: 75)
                                .border(.ultraThickMaterial, width: 1)
                                .padding(.trailing)
//                                .padding(.top)
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            .padding(.top)
        }
    }
}
 


#Preview {
    BPEditEventCarView(event: MockData.sampleEvent)
        
}
