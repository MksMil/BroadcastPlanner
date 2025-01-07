import SwiftUI

struct BPEditEventJoystickInfoPanel: View {
    @EnvironmentObject var vm: BPEditStadiumViewModel
    @FetchRequest<LocalLocationPoint>(sortDescriptors: []) var points
    var body: some View {
        HStack(alignment: .top){
            // TODO: More useful customize
            //InfoPanel
            
            if vm.isEdit, vm.selectedEventPoint != nil {
                PointInfoPanelView(point: vm.selectedEventPoint)
            } else {
                SmartLayout(hSpacing: 3, vSpacing: 3){

                    ForEach(points){ point in
                        Circle().fill( vm.selectedEventPoint?.viewId == point.viewId ?  .red:.gray)
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text("\(point.viewNumber)")
                            }
                            .onTapGesture {
                                withAnimation{
                                    if vm.selectedEventPoint == point{
                                        vm.deselectPointForRender()
                                    } else {
                                        vm.selectPoint(point: point)
                                    }
                                }
                            }
                            .animation(.easeInOut, value: vm.selectedEventPoint)
                    }
                }
                .padding(2)
            }
            Spacer()
            //joystick
            VStack{
                BPJoystick(
                    upAction: vm.moveUp,
                    downAction: vm.moveDown,
                    leftAction: vm.moveLeft,
                    rightAction: vm.moveRight,
                    rotationLeft: vm.rotateCounterClockwise,
                    rotationRight: vm.rotateClockwise,
                    swap: vm.swap,
                    scaleUp: vm.scaleUpPoint,
                    scaleDown: vm.scaleDownPoint
                )
                .frame(width: 140, height: 140)
                .padding(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(.ultraThinMaterial, lineWidth: 2)
                }
                .padding(5)

//                }
//                .padding(.top)
//                .padding(.trailing)
                
//                BPEventPlanPointImage()
//                    .frame(width: 75, height: 75)
//                    .border(.ultraThickMaterial, width: 1)
//                    .padding(.trailing)

            }
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    BPEditStadiumView(event: DataManager.shared.fetchOrCreateEventWithId("123", inContext: .main),
                      editable: true,
                      acceptAction: {},
                      cancelAction: {})
        .environment(\.managedObjectContext, DataManager.shared.moc)
}

//#Preview {
//    BPEditEventJoystickInfoPanel(moveUp: {}, moveDown: {}, moveLeft: {}, moveRight: {}, rotateLeft: {}, rotateRight: {},swap: {},scaleUp: {},scaleDown: {})
////        .environmentObject(BPEditStadiumViewModel())
//}
