import SwiftUI

struct BPEditEventPlanView: View {
    //    @EnvironmentObject var globalStorage: GlobalStorage
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var vm: BPEventViewModel
    
    @State var pointFilter: BPEventPlanPointFilter = .all
    
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
            
                BPEditEventPlanPointsView(
                    scaleFactor: 1,
                    vm: vm,
                    filter: $pointFilter,
                    isEditState: true
                )
                .frame(height: 300)
            
                
                if !vm.isEdit{
                    ScrollView{
                        SmartLayout(hSpacing: 5, vSpacing: 5){
                            ForEach(vm.event.eventPlan.points) { point in
                                Text("\(point.eventPlanPointNumber)")
                                    .fixedSize()
                                    .padding(10)
                                    .frame(width: 115, height: 50)
                                    .background(vm.selectedEventPoint?.id == point.id ?  .ultraThickMaterial : .ultraThinMaterial
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            vm.select(point: point)
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
                                        BPUserCompactCell(user: vm.selectedEventPoint?.user)
                                        BPPositionCompactCell(pointPositionName: vm.selectedEventPoint?.coordinates.description)
                                    }
                                    Spacer()
                                    Circle()
                                        .frame(width: 45)
                                        .padding(.vertical,10)
                                        .overlay {
                                            Text(String(vm.selectedEventPoint?.eventPlanPointNumber ?? Int.random(in: 1..<20)))
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
                                rotationLeft: rotateLeft,
                                rotationRight: rotateRight
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
 
// MARK: - move/rotate Points
extension BPEditEventPlanView {
        func upAction(){
            //        print(vm.selectedEventPoint?.coordinates.description ?? "")
            withAnimation{
                vm.moveUp()
            }
        }
        func downAction(){
            //        print(vm.selectedEventPoint?.coordinates.description ?? "")
            withAnimation{
                vm.moveDown()
            }
        }
        func leftAction(){
            //        print(vm.selectedEventPoint?.coordinates.description ?? "")
            withAnimation{
                vm.moveLeft()
            }
        }
        func rightAction(){
            //        print(vm.selectedEventPoint?.coordinates.description ?? "")
            withAnimation{
                vm.moveRight()
            }
        }
        
        func rotateLeft(){
//            if vm.selectedEventPoint?.coordinates.rotation == 360{
//                vm.selectedEventPoint?.coordinates.rotation = 0
//            }
            withAnimation{
                vm.rotateLeft()
            }
        }
        
        func rotateRight(){
//            if vm.selectedEventPoint?.coordinates.rotation == -360{
//                vm.selectedEventPoint?.coordinates.rotation = 0
//            }
            withAnimation{
                vm.rotateRight()
            }
        }
    
}




#Preview {
    BPEditEventPlanView(vm: BPEventViewModel(event: MockData.sampleEvent))
}

//#Preview {
//    MainTabView()
//        .environmentObject(GlobalStorage())
//    
//}
