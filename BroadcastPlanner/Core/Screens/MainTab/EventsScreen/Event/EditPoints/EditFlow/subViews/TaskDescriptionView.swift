import SwiftUI

struct TaskDescriptionView: View {

    @State var text: String
    @State var isEditMode: Bool = false
    
    init(text: String, isEditMode: Bool) {
        self._text = State(wrappedValue: text)
        self.isEditMode = isEditMode
    }
    
    var body: some View {
        VStack{
            Text(text.isEmpty ? "Task":"\(text)")
                .font(text.isEmpty ? .system(size: 22):.system(size: 11))
                
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
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
                CustomTextEditor(text: $text)
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
    @Binding var text: String
    
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
    }
}


#Preview {
    let mdm = MainDataManager(localDataManager: DataManager(), globalDataManager: NetworkManager(),userId: "123")
    
   return BPEditStadiumView(event: mdm.localDataManager.fetchOrCreateEventWithId("123", inContext: .main) , editable: true)
        .environmentObject(mdm)
}

//#Preview {
//    TaskDescriptionView()
//}
