import SwiftUI

struct UpdateSessionUserDataView: View {
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var oldEmailValue: String = ""
    @State private var oldEmailinfoMessage: String = ""
    
    @State private var newEmailValue: String = ""
    @State private var newEmailinfoMessage: String = ""
    
    
    @State private var oldPasswordValue: String = ""
    @State private var oldPasswordinfoMessage: String = ""
    
    @State private var newPasswordValue: String = ""
    @State private var newPasswordinfoMessage: String = ""
    
    
    @State private var isOldEmailValid: Bool = true
    @State private var isNewEmailValid: Bool = true
    @State private var isOldPasswordValid: Bool = true
    @State private var isNewPasswordValid: Bool = true
    
    
    
    var body: some View {
        
        ZStack{
            MainBackground()
                
            VStack(spacing: 20){
                // MARK: - Email
                VStack{
                    //MARK: old email value
                    HStack{
                        Text(oldEmailinfoMessage.isEmpty ? "Confirm old email addrress":oldEmailinfoMessage)
                            .font(.footnote)
                            .foregroundStyle(isOldEmailValid ? Color.secondary: Color.red)
                        Spacer()
                    }
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isOldEmailValid ? Color.white: Color.red, lineWidth: 2)
                        }
                        .overlay {
                            HStack(spacing:0) {
                                Image(systemName: "envelope")
                                    .padding(.horizontal, 5)
                                    .frame(width: 40)
                                
                                Divider()
                                Text(oldEmailValue)
                                    .foregroundStyle(
                                        oldEmailValue.isEmpty ? .gray : .primary
                                    )
                                    .padding(.horizontal, 15)
                                Spacer()
                            }
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            appState.cleanTFInfo()
                            appState.fieldType =  .email
                            appState.isSecure = false
                            appState.textfieldSource = oldEmailValue
                            appState.promptString = "Confirm old e-mail"
                            appState.openTextFieldWithAction { value in
                                self.oldEmailValue = value
                                appState.makePrimaryButtonEnabled(validate())
                            }
                        }
                    // MARK: - new email value
                    HStack{
                        Text(newEmailinfoMessage.isEmpty ? "Enter new email addrress":newEmailinfoMessage)
                            .font(.footnote)
                            .foregroundStyle(isNewEmailValid ? Color.secondary: Color.red)
                        Spacer()
                    }
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isNewEmailValid ? Color.white: Color.red, lineWidth: 2)
                        }
                        .overlay {
                            HStack(spacing:0) {
                                Image(systemName: "envelope")
                                    .padding(.horizontal, 5)
                                    .frame(width: 40)
                                
                                Divider()
                                Text(newEmailValue)
                                    .foregroundStyle(
                                        newEmailValue.isEmpty ? .gray : .primary
                                    )
                                    .padding(.horizontal, 15)
                                Spacer()
                            }
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            appState.cleanTFInfo()
                            appState.fieldType = .email
                            appState.isSecure = false
                            appState.textfieldSource = newEmailValue
                            appState.promptString = "Enter new valid e-mail"
                            appState.openTextFieldWithAction { value in
                                self.newEmailValue = value
                                appState.makePrimaryButtonEnabled(validate())
                            }
                        }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.7))
                }
                // MARK: - Password
                VStack{
                    //MARK: old password value
                    HStack{
                        Text(oldPasswordinfoMessage.isEmpty ? "Confirm old password":oldPasswordinfoMessage)
                            .font(.footnote)
                            .foregroundStyle(isOldPasswordValid ? Color.secondary: Color.red)
                        Spacer()
                    }
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isOldPasswordValid ?  Color.white: Color.red, lineWidth: 2)
                        }
                        .overlay {
                            HStack(spacing:0) {
                                Image(systemName: "lock.fill")
                                    .padding(.horizontal, 5)
                                    .frame(width: 40)
                                
                                Divider()
                                Text(oldPasswordValue.starred())
                                    .foregroundStyle(
                                        oldPasswordValue.isEmpty ? .gray : .primary
                                    )
                                    .padding(.horizontal, 15)
                                Spacer()
                            }
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            appState.cleanTFInfo()
                            appState.fieldType = .password
                            appState.isSecure = true
                            appState.promptString = "Confirm old password"
                            appState.openTextFieldWithAction { value in
                                self.oldPasswordValue = value
                                appState.makePrimaryButtonEnabled(validate())
                            }
                        }
                    // MARK: new password value
                    HStack{
                        Text(newPasswordinfoMessage.isEmpty ? "Enter new password minimum 6 characters":newPasswordinfoMessage)
                            .font(.footnote)
                            .foregroundStyle(isNewPasswordValid ? Color.secondary: Color.red)
                        Spacer()
                    }
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white,lineWidth: 2)
                        }
                        .overlay {
                            HStack(spacing:0) {
                                Image(systemName: "lock.fill")
                                    .padding(.horizontal, 5)
                                    .frame(width: 40)
                                
                                Divider()
                                Text(newPasswordValue.starred())
                                    .foregroundStyle(
                                        newPasswordValue.isEmpty ? .gray : .primary
                                    )
                                    .padding(.horizontal, 15)
                                Spacer()
                            }
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            appState.cleanTFInfo()
                            appState.fieldType = .password
                            appState.isSecure = true
                            appState.promptString = "Enter new password"
                            appState.openTextFieldWithAction { value in
                                self.newPasswordValue = value
                                appState.makePrimaryButtonEnabled(validate())
                            }
                        }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(.top,100)
            .padding(.horizontal)
            .ignoresSafeArea(.keyboard)
            .transitionWithOpacity()
            .navigationBarBackButtonHidden()
        }
        .onAppear{
            
            appState.primaryAction = {
                Task{
                    await sessionManager.updateEmailOrPassword(newEmailValue: newEmailValue, newPasswordValue: newPasswordValue)
                }
                router.stepBack()
            }
            appState.secondaryAction = {}
            appState.stepBackAction = {
                router.stepBack()
            }
            
            
        }
        
    }
    
    func validate()->Bool{
        // old email
        
        if !oldEmailValue.isEmpty{
            if oldEmailValue == sessionManager.email{
                //old email confirm
                oldEmailinfoMessage = "old email is valid"
                isOldEmailValid = true
            } else {
                isOldEmailValid = false
                oldEmailinfoMessage = "old email not valid"
            }
        } else {
            isOldEmailValid = true
            oldEmailinfoMessage = ""
        }
        
        //new email
        if !newEmailValue.isEmpty{
            if newEmailValue.isValidEmail(){
                newEmailinfoMessage = "looks like email"
                isNewEmailValid = true
            } else {
                isNewEmailValid = false
                newEmailinfoMessage = "wrong email signature"
            }
        } else {
            isNewEmailValid = true
            newEmailinfoMessage = ""
        }
        
        //old password
        if !oldPasswordValue.isEmpty{
            if oldPasswordValue == sessionManager.password{
                oldPasswordinfoMessage = "password confirmation done"
                isOldPasswordValid = true
            } else {
                isOldPasswordValid = false
                oldPasswordinfoMessage = "wrong password confirmation"
            }
        } else {
            isOldPasswordValid = true
            oldPasswordinfoMessage = ""
        }
        
        if !newPasswordValue.isEmpty{
            if newPasswordValue.count > 5{
                newPasswordinfoMessage = "that is new password !"
                isNewPasswordValid = true
            } else {
                newPasswordinfoMessage = "minimum 6 characters in password"
                isNewPasswordValid = false
            }
        } else {
            isNewPasswordValid = true
            newPasswordinfoMessage = ""
        }
        
        return (isOldPasswordValid && isNewEmailValid && isOldEmailValid && isNewPasswordValid && (!newEmailValue.isEmpty || !newPasswordValue.isEmpty) && !oldEmailValue.isEmpty && !oldPasswordValue.isEmpty)

    }
}


