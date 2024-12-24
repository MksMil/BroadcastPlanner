import SwiftUI

struct BPEditEventJoystickInfoPanel: View {
    @ObservedObject var vm: BPEditStadiumViewModel
    @FetchRequest<LocalLocationPoint>(sortDescriptors: []) var points
    var body: some View {
        HStack(alignment: .top){
            // TODO: More useful customize
            //InfoPanel
            ScrollView {
                VStack{
                    HStack{
                        VStack(alignment: .leading,spacing: 3){
//                            BPUserImageNameCompactCell(users: point.viewUsers)
                        }
                        Spacer()
                        Circle()
                            .frame(width: 45)
                            .padding(.vertical,10)
                            .overlay {
                                Text(String(Int.random(in: 1..<20)))
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                    }
                    VStack(alignment: .leading,spacing: 3){
                        Divider()
                        
//                        BPCameraCompactCell(camDescription: point.viewCameras.first.view)
//                        BPMicCompactCell(micDescription: "---")
//                        BPLightCompactCell(lightDescription: "---")
//                        BPEnvCompactCell(envDescription: "---")
                    }
                .frame(maxWidth: .infinity,
                       alignment: .leading)
                }
                .padding(.horizontal,10)
            }
            .background(RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial))
//            .padding(.leading)
//            .padding(.bottom)
            
//            Spacer()
            
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
                ScrollView{
//                    List{
                        Text("Points")
                        ForEach(points){ point in
                            Text(point.viewId.prefix(4))
                        }
                    }
                .frame(width: 100)
//                }
//                .padding(.top)
//                .padding(.trailing)
                
//                BPEventPlanPointImage()
//                    .frame(width: 75, height: 75)
//                    .border(.ultraThickMaterial, width: 1)
//                    .padding(.trailing)

            }
        }
//        .onReceive(editManager.$selectedEventPoint, perform: { _ in
//            if let point = editManager.selectedEventPoint{
//                self.selectedEventPoint = point
//            }
//        })
    }
}


#Preview {
    BPEditStadiumView(event: DataManager.shared.fetchOrCreateEventWithId("123", inContext: .main) , editable: true,acceptAction: {},cancelAction: {})
        .environment(\.managedObjectContext, DataManager.shared.moc)
}

//#Preview {
//    BPEditEventJoystickInfoPanel(moveUp: {}, moveDown: {}, moveLeft: {}, moveRight: {}, rotateLeft: {}, rotateRight: {},swap: {},scaleUp: {},scaleDown: {})
////        .environmentObject(BPEditStadiumViewModel())
//}
