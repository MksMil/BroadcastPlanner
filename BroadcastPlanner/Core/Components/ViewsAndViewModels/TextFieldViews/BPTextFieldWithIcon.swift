import SwiftUI

struct BPTextFieldWithIcon: View {
    
    @Binding var text: String
    var placeholder: String = "some text here"
    var imageName: String?
    var isSecureField: Bool = false
    
    var body: some View {
        HStack{
            Image(systemName: imageName ?? "textformat.abc")
                .imageScale(.large)
                
            
            if isSecureField{
             SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.emailAddress)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .padding(.horizontal)
                    
            } else {
                TextField(placeholder,text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.password)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .padding(.horizontal)
            }
        }
        .frame(height: 30)
        .padding()
        .background(.white.opacity(0.4))
        .foregroundColor(.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}

#Preview {
    BPTextFieldWithIcon(text: .constant(""))
}
