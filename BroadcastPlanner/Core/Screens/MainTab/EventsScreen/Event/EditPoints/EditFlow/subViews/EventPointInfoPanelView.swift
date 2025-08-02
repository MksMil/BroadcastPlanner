 import SwiftUI

struct EventPointInfoPanelView: View {
    @EnvironmentObject var vm: BPEditStadiumViewModel
    
//    let venuePoint: VenuePoint?
//    let text: String
//    @State var isEditMode: Bool = false
//    let acceptAction: (String) -> Void
    
//    init(acceptAction: @escaping (String)->Void ) {
//        self.venuePoint = venuePoint
//        self.text =  venuePoint?.viewTask ?? ""
//        self.isEditMode = isEditMode
//        self.acceptAction = acceptAction
//    }
    
    var body: some View {
        if let point = vm.selectedVenuePoint{
//            Text(vm.selectedVenuePoint?.viewId ?? "hello")
            //venuePoint number
            //venuePoint position?
            VStack(alignment: .leading, spacing: 0){
                HStack{
                    Image(systemName: "\(point.viewNumber).circle")
                    Text("\(point.viewDescription)")
                }
                // member
                HStack{
                    if point.viewMembers.isEmpty{
                     Image(systemName: "person")
                    } else {
                        point.viewMembers.first?.viewImage
                    }
                    Text("\(point.viewMembers.first?.viewCompactName ?? "---")")
                }
//                //cam
//                HStack{
//                    Image(systemName: "video")
//                    Text("\(venuePoint.viewCameras.first?.viewOptic.rawValue ?? "---")")
//                }
//                //sound
//                HStack{
//                    Image(systemName: "mic")
//                    Text("\(venuePoint.viewSounds.first?.viewPlaceType.rawValue ?? "---")")
//                }
//                //light
//                HStack{
//                    Image(systemName: "warninglight")
//                    Text("\(venuePoint.viewLocalLights.first?.viewLightType.rawValue ?? "---")")
//                }
                HStack{
                    Spacer()
                    Text("Tap to edit")
                        .font(.system(size: 8))
                        .opacity(0.3)
                    Spacer()
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .padding(5)
            .frame(maxWidth: .infinity)
            .background(content: {
                Rectangle().fill(Color.white.opacity(0.1))
            })
            .onTapGesture {
                print("edit button tapped")
            }
//            .border(.blue, width: 1)
        } else {
            Text("broadcast summary")
        }
//        .fullScreenCover(isPresented: $isEditMode) {
//            VStack{
//                Text("Task")
//                    .font(.largeTitle)
//                    .foregroundStyle(.white)
//                CustomTextEditor(text: text){ text in
//                    acceptAction(text)
//                }
//            }
//            .padding(.horizontal)
//            .presentationBackground(.black.opacity(0.8))
//        }
//        .toolbar{
//            if isEditMode{
//                ToolbarItemGroup(placement: .keyboard) {
//                    Spacer()
//                    Button("Done"){
//                        isEditMode = false
//                    }
//                    .foregroundStyle(.blue)
//                }
//            }
//        }
    }
}

struct CustomTextEditor: View {
    @FocusState private var isFocused: Bool
    
    @State var text: String
    let acceptAction: (String)->Void
    
    init(text: String,
         acceptAction: @escaping (String) -> Void) {
        self.text = text
        self.acceptAction = acceptAction
    }
    
    var body: some View {
        VStack{
            TextEditor(text: $text)
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .background(.white.opacity(0.4))
                .foregroundStyle(.black)
                .scrollContentBackground(.hidden)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .keyboardType(.alphabet)
                .padding()
        }
        .onAppear {
            isFocused = true
        }
        .onDisappear {
            acceptAction(text)
        }
    }
}

//#Preview {
//    TaskDescriptionView()
//}

//#Preview {
//    let mdm = DataManager(networkManager: NetworkManager())
//    let localEvent: Broadcast = mdm.mainContext.fetchOrCreateObject(withID: "id")
//    return BPEditStadiumView(event: localEvent)
//        .environmentObject(mdm)
//        .environment(\.managedObjectContext, mdm.mainContext)
//}
