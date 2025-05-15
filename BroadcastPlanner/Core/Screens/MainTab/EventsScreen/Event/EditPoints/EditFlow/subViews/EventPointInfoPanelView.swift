 import SwiftUI

struct EventPointInfoPanelView: View {
    @EnvironmentObject var vm: BPEditStadiumViewModel
    
//    let point: LocationPoint?
//    let text: String
//    @State var isEditMode: Bool = false
//    let acceptAction: (String) -> Void
    
//    init(acceptAction: @escaping (String)->Void ) {
//        self.point = point
//        self.text =  point?.viewTask ?? ""
//        self.isEditMode = isEditMode
//        self.acceptAction = acceptAction
//    }
    
    var body: some View {
        if vm.selectedEventPoint != nil {
            Text(vm.selectedEventPoint?.viewId ?? "hello")
        } else {
            Text("event summary")
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

#Preview {
    let lm = DataManager(forPreview: true)
    let mdm = MainDataManager(localDataManager: lm,
                              globalDataManager: NetworkManager(),
                              userId: "123")
    let localEvent = lm.fetchOrCreateObject(ofType: Event.self,
                  predicate: NSPredicate(format: "id == %@", "id"),
                                      in: lm.mainContext) { ctx in
        let newEvent = Event(context: ctx)
        newEvent.id = "id"
        return newEvent
    }
   return BPEditStadiumView(event: localEvent)
        .environmentObject(mdm)
        .environment(\.managedObjectContext, mdm.localDataManager.mainContext)
}
