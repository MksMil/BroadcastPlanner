import SwiftUI

enum UpdatedEP: String,Identifiable {
    case email, password
    var id: Self { self }
}

struct UpdateSessionUserDataView: View {
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router
    
    let currentValue: String
    
    @State private var oldValue: String = ""
    @State private var newValue: String = ""
    
    @State private var oldValueRepresentation: String = ""
    @State private var newValueRepresentation: String = ""
    
    let updEP: UpdatedEP
    let cancelAction: ()->Void
    let updateAction: (String) -> Void
    
    var body: some View {
        
        ZStack{
            MainBackground()
                
                VStack(spacing: 20){
                    // MARK: - Old Value TF

                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.ultraThinMaterial,lineWidth: 2)
                        }
                        .overlay {
                            HStack(spacing:0) {
                                Image(systemName: updEP == .email ? "envelope":"lock.fill")
                                    .padding(.horizontal, 5)
                                    .frame(width: 40)
                                
                                Divider()
                                Text(oldValueRepresentation)
                                    .foregroundStyle(
                                        oldValue.isEmpty ? .gray : .primary
                                    )
                                    .padding(.horizontal, 15)
                                Spacer()
                            }
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            appState.cleanTFInfo()
                            appState.fieldType = updEP == .email ? .email: .password
                            appState.isSecure = updEP != .email
                            appState.promptString = "Enter old " + (updEP == .email ?  "e-mail": "password")
                            appState.openTextFieldWithAction { value in
                                self.oldValue = value
                                oldValueRepresentation = textForValue(value: value, isOld: true)
                                appState.makePrimaryButtonEnabled(validate())
                            }
                        }
//                    // MARK: - New Value TF
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.ultraThinMaterial,lineWidth: 2)
                        }
                        .overlay {
                            HStack(spacing:0) {
                                Image(systemName: updEP == .email ? "envelope":"lock.fill")
                                    .padding(.horizontal, 5)
                                    .frame(width: 40)
                                
                                Divider()
                                Text(newValueRepresentation)
                                    .foregroundStyle(
                                        newValue.isEmpty ? .gray : .primary
                                    )
                                    .padding(.horizontal, 15)
                                Spacer()
                            }
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            appState.cleanTFInfo()
                            appState.fieldType = updEP == .email ? .email: .password
                            appState.isSecure = updEP != .email
                            appState.promptString = "Enter new " + (updEP == .email ?  "e-mail": "password")
                            appState.openTextFieldWithAction { value in
                                self.newValue = value
                                newValueRepresentation = textForValue(value: value, isOld: false)
                                appState.makePrimaryButtonEnabled(validate())
                            }
                        }
                    // MARK: - Confirm Button
                    
                    Spacer()
                }
                .padding(.top,100)
                .padding(.horizontal)
            .ignoresSafeArea(.keyboard)
            .transitionWithOpacity()
            .navigationBarBackButtonHidden()
        }
        .onAppear{
            appState.setTitle("Update \(updEP == .email ? "email":"password")")
            appState.primaryAction = {
                Task{
                    updateAction(newValue)
                }
            }
            
            appState.secondaryAction = {
                Task{
                    cancelAction()
                }
            }
            
            appState.stepBackAction = {
                router.stepBack()
            }
            
            
        }
        
    }
    func textForValue(value: String, isOld: Bool)->String{
        if value.isEmpty{
            return ((isOld ? "old":"new") + " " + (updEP == .email ? "email": "password"))
        } else {
            return updEP == .email ? value : value.starred()
        }
    }
    
    func validate()->Bool{
        print("validate \(updEP.rawValue) called: \(currentValue), \(oldValue),\(newValue)")
        if updEP == .email, !newValue.isValidEmail(){
            return false
        }
        if updEP == .password, newValue.count < 6{
            return false
        }
        if !oldValue.isEmpty, oldValue == currentValue{
            return true
        }
        return false
    }
}

#Preview {
    UpdateSessionUserDataView(currentValue: "", updEP: .password, cancelAction: {}, updateAction: {_ in })
}
#Preview {
    UpdateSessionUserDataView(currentValue: "", updEP: .email, cancelAction: {}, updateAction: {_ in })
}
