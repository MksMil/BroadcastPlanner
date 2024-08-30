import SwiftUI

struct SignUpView: View {
    enum FieldInFocus: Hashable{
        case firstField,
             secondField
    }
    @FocusState private var isFocused: FieldInFocus?
    @Environment(\.dismiss) var dismiss
    @Binding var email: String
    @Binding var password: String
//    @EnvironmentObject var globalStorage: GlobalStorage
    
    let createAction: () -> Void
    
    var body: some View {
        ZStack{
            MainBackground()
            
            VStack{
                // MARK: - Email/Password TF's
                BPTextFieldWithIcon(text: $email,
                                    placeholder: "email",
                                    imageName: "envelope")
                    .keyboardType(.emailAddress)
                    .focused($isFocused,
                             equals: .firstField)
                
                BPTextFieldWithIcon(text: $password,
                                    placeholder: "password",
                                    imageName: "lock.fill",
                                    isSecureField: true)
                    .keyboardType(.default)
                    .focused($isFocused,
                             equals: .secondField)
                
                // MARK: - Sign Up button
                Button(action: {
                            isFocused = nil
                            createAction()
                            dismiss()
                },
                       label: {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .padding()
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                })
                .padding(.top, 40)
                Spacer()
            }
            .padding(.top, 120)
        }
    }
}

// MARK: - Preview
#Preview {
    SignUpView(email: .constant(""), password: .constant("")){}
        
}
