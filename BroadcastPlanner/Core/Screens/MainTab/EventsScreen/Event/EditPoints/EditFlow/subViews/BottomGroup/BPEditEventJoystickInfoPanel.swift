import SwiftUI

struct BPEditEventJoystickInfoPanel: View {
    @EnvironmentObject var vm: BPEditStadiumViewModel
    @FetchRequest<LocalLocationPoint>(sortDescriptors: []) var points
    var body: some View {
        HStack(alignment: .top){
            // TODO: More useful customize
            //InfoPanel
            VStack{
                if vm.isEdit, vm.selectedEventPoint != nil {
                    PointInfoPanelView(point: vm.selectedEventPoint)
                        .layoutPriority(1)
                } else {
                    SmartLayout(hSpacing: 3, vSpacing: 3){
                        ForEach(points.sorted(by: {$0.viewNumber < $1.viewNumber})){ point in
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
                .aspectRatio(1, contentMode: .fit)
                .padding(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5).stroke(.ultraThinMaterial, lineWidth: 2)
                }
                // Task managment
                TaskDescriptionView(text: vm.selectedEventPoint?.viewTask ?? "", isEditMode: vm.isEdit)
                
            }
            .padding(5)
            .frame(width: 140)
        }
    }
}


#Preview {
    let mdm = MainDataManager(localDataManager: DataManager(), globalDataManager: NetworkManager(),userId: "123")
    
    BPEditStadiumView(event: mdm.localDataManager.fetchOrCreateEventWithId("123", inContext: .main) , editable: true)
    .environmentObject(BPEditStadiumViewModel())
    .environmentObject(mdm)
}

//#Preview {
//    BPEditEventJoystickInfoPanel(moveUp: {}, moveDown: {}, moveLeft: {}, moveRight: {}, rotateLeft: {}, rotateRight: {},swap: {},scaleUp: {},scaleDown: {})
////        .environmentObject(BPEditStadiumViewModel())
//}
