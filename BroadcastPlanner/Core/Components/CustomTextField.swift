import SwiftUI

struct CustomTextField: View {
    
    @FocusState private var isFocused: Bool
    
    @Binding var text: String
    
    let submitAction: ()->()
    
    var body: some View {
        VStack{
            TextField("template title", text: $text)
                .padding()
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .background(.white.opacity(0.4))
                .foregroundStyle(.black)
                .scrollContentBackground(.hidden)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .keyboardType(.alphabet)
                .padding()
                .onSubmit {
                    submitAction()
                }
            if !isFocused {
                Button("Save") {
                    submitAction()
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
}


