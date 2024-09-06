import SwiftUI

struct BPEditEventJoystickInfoPanel: View {
    @EnvironmentObject var editManager: EditPlanPointsManager
    
    // MARK: - Actions
    
    let moveUp: () -> Void
    let moveDown: () -> Void
    let moveLeft: () -> Void
    let moveRight: () -> Void
    let rotateLeft: () -> Void
    let rotateRight: () -> Void 
    
    
   @State var selectedEventPoint: BPEventPlanPoint?
    
    var body: some View {
        HStack{
            // TODO: More useful customize
            //InfoPanel
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
                .frame(maxWidth: .infinity,
                       alignment: .leading)
                }
                .padding(.horizontal,10)
            }
            .background(RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial))
            .padding(.leading)
            .padding(.bottom)
            
            Spacer()
            
            //joystick
            VStack{
                BPJoystick(
                    upAction: moveUp,
                    downAction: moveDown,
                    leftAction: moveLeft,
                    rightAction: moveRight,
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

                Spacer()
            }
        }
        .onReceive(editManager.$selectedEventPoint, perform: { _ in
            if let point = editManager.selectedEventPoint{
                self.selectedEventPoint = point
            }
        })
    }
}

#Preview {
    BPEditEventJoystickInfoPanel(moveUp: {}, moveDown: {}, moveLeft: {}, moveRight: {}, rotateLeft: {}, rotateRight: {})
        .environmentObject(EditPlanPointsManager())
}
