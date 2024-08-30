import SwiftUI

// MARK: - Email and password fields
struct EmailPasswordStack: View {
    enum FieldInFocus: Hashable{
        case firstField, secondField
    }
    
    @FocusState private var isFocused: FieldInFocus?
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        VStack{
            BPTextFieldWithIcon(text: $email,
                                placeholder: "e-mail",
                                imageName: "envelope")
            .keyboardType(.emailAddress)
            .focused($isFocused,equals: .firstField)
            
            BPTextFieldWithIcon(text: $password,
                                placeholder: "password",
                                imageName: "lock.fill",
                                isSecureField: true)
            .keyboardType(.default)
            .focused($isFocused,equals: .secondField)
        }
    }
}
