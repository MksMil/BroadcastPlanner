import SwiftUI

struct SignUpView: View {
    enum FieldInFocus: Hashable{
        case firstField,
             secondField
    }
    @FocusState private var isFocused: FieldInFocus?
    @EnvironmentObject var globalStorage: GlobalStorage
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AuthViewModel = AuthViewModel()
    let createAction: ( String, String) -> Void 
    
    var body: some View {
        ZStack{
            MainBackground()
            
            VStack{
                // MARK: - Email/Password TF's
                BPTextFieldWithIcon(text: $viewModel.email,
                                    placeholder: "email",
                                    imageName: "envelope")
                    .keyboardType(.emailAddress)
                    .focused($isFocused,
                             equals: .firstField)
                
                BPTextFieldWithIcon(text: $viewModel.password,
                                    placeholder: "password",
                                    imageName: "lock.fill",
                                    isSecureField: true)
                    .keyboardType(.default)
                    .focused($isFocused,
                             equals: .secondField)
                
                // MARK: - Sign Up button
                Button(action: {
                            isFocused = nil
                            createAction(viewModel.email,
                                         viewModel.password)
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
    SignUpView(viewModel: AuthViewModel()){_,_  in}
        
}
