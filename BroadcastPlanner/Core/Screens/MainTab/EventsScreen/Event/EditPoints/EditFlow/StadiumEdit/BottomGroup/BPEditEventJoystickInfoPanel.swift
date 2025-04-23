import SwiftUI

struct BPEditEventJoystickInfoPanel: View {
    @EnvironmentObject var mdm: MainDataManager
    @EnvironmentObject var vm: BPEditStadiumViewModel
//    @FetchRequest<LocalLocationPoint>(sortDescriptors: []) var points
    
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
                        ForEach(vm.filteredLocationPoints.sorted(by: {$0.viewNumber < $1.viewNumber})){ point in
                            PointPanelCell(size: 45,
                                           state: vm.stateForPoint(point),
                                           number: point.viewNumber,
                                           isCamera: !point.viewLocalCameras.isEmpty,
                                           isSound: !point.viewLocalSounds.isEmpty,
                                           isLight: !point.viewLocalLights.isEmpty,
                                           isUser: !point.viewUsers.isEmpty,
                                           selectedPoint: $vm.selectedEventPoint)
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
                    RoundedRectangle(cornerRadius: 5).stroke(.white.opacity(0.4), lineWidth: 2)
                }
                // Task managment
                TaskDescriptionView(point: vm.selectedEventPoint,
                                    isEditMode: vm.isEdit){ text in
                    vm.selectedEventPoint?.task = text
                    vm.selectedEventPoint = vm.selectedEventPoint
                }
                    .disabled(vm.selectedEventPoint == nil)
                    .opacity(vm.selectedEventPoint == nil ? 0.6 : 1)
            }
            .padding(5)
            .frame(width: 140)
        }
    }
}


#Preview {
    let lm = DataManager(forPreview: true)
    let mdm = MainDataManager(localDataManager: lm,
                              globalDataManager: NetworkManager(),
                              userId: "123")
    let localEvent = lm.fetchOrCreateObject(ofType: LocalEvent.self,
                  predicate: NSPredicate(format: "id == %@", "id"),
                                      in: lm.moc) { ctx in
        let newEvent = LocalEvent(context: ctx)
        newEvent.id = "id"
        return newEvent
    }
   return BPEditStadiumView(event: localEvent, editable: true)
        .environmentObject(mdm)
}

//#Preview {
//    BPEditEventJoystickInfoPanel(moveUp: {}, moveDown: {}, moveLeft: {}, moveRight: {}, rotateLeft: {}, rotateRight: {},swap: {},scaleUp: {},scaleDown: {})
////        .environmentObject(BPEditStadiumViewModel())
//}
