import SwiftUI

enum UpdatedEP: String,Identifiable {
    case email, password
    var id: Self { self }
}

struct UpdateEPView: View {
    enum FieldInFocus: Hashable{
        case firstField, secondField
    }
    
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocus: FieldInFocus?
    
    var currentValue: String
    
    @State private var oldValue: String = ""
    @State private var newValue: String = ""
    
    var updEP: UpdatedEP
    let updateAction: (String) -> Void
    
    var body: some View {
        
        ZStack{
            MainBackground()
            
            VStack{
                // MARK: - Header Text
                Text("Update \(updEP == .email ? "email":"password")")
                    .font(.title)
                    .foregroundColor(.accentColor)
                    .padding(.top)
                
                VStack(spacing: 20){
                    // MARK: - Old Value TF
                    BPTextFieldWithIcon(text: $oldValue,
                                        placeholder: "old \(updEP == .email ? "email":"password")",
                                        imageName: updEP == .email ? "envelope":"lock.fill",
                                        isSecureField: updEP == .password  )
                    .keyboardType(updEP == .email ? .emailAddress: .default)
                    .focused($isFocus, equals: .firstField)
                    
                    // MARK: - New Value TF
                    BPTextFieldWithIcon(text: $newValue,
                                        placeholder: "new \(updEP == .email ? "email":"password")",
                                        imageName: updEP == .email ? "envelope":"lock.fill",
                                        isSecureField: updEP == .password  )
                    .keyboardType(updEP == .email ? .emailAddress: .default)
                    .focused($isFocus, equals: .secondField)
                    
                    // MARK: - Confirm Button
                    Button{
                        print("Confirm Button tapped")
                        Task{
                            isFocus = nil
                            updateAction(newValue)
                            dismiss()
                        }
                    } label: {
                        Text("Confirm")
                            .font(.title)
                            .foregroundStyle(Color.accent)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundColor(Color.white.opacity(0.7))
                            .padding(.horizontal)
                    }
                    .padding(.top,20)
                    Spacer()
                }
                .padding(.top,100)
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    UpdateEPView(currentValue: "", updEP: .password, updateAction: {_ in })
//        .environmentObject(GlobalStorage())
    
}
#Preview {
    UpdateEPView(currentValue: "", updEP: .email, updateAction: {_ in })
//        .environmentObject(GlobalStorage())
}
