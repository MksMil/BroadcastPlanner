 import SwiftUI

struct TaskDescriptionView: View {

    let point: LocalLocationPoint?
    let text: String
    @State var isEditMode: Bool = false
    let acceptAction: (String) -> Void
    
    init(point: LocalLocationPoint?,
         isEditMode: Bool,
         acceptAction: @escaping (String)->Void ) {
        self.point = point
        self.text =  point?.viewTask ?? ""
        self.isEditMode = isEditMode
        self.acceptAction = acceptAction
    }
    
    var body: some View {
        VStack{
            Text(text.isEmpty ? "Task":"\(text)")
                .font(text.isEmpty ? .system(size: 22):.system(size: 11))
                
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal,5)
        .background(.white.opacity(0.4))
        .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 10, bottomTrailing: 10, topTrailing: 0)))
        .onTapGesture {
            isEditMode = true
        }
        .fullScreenCover(isPresented: $isEditMode) {
            VStack{
                Text("Task")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                CustomTextEditor(text: text){ text in
                    acceptAction(text)
                }
            }
            .padding(.horizontal)
            .presentationBackground(.black.opacity(0.8))
        }
        .toolbar{
            if isEditMode{
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done"){
                        isEditMode = false
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
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
//    let mdm = MainDataManager(localDataManager: DataManager(), globalDataManager: NetworkManager(),userId: "123")
//    
//   return BPEditStadiumView(event: mdm.localDataManager.fetchOrCreateEventWithId("123", inContext: .main) , editable: true)
//        .environmentObject(mdm)
//}

//#Preview {
//    TaskDescriptionView()
//}
