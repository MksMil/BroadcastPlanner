import SwiftUI
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
