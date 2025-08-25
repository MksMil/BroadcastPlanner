import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router
    
    let createAction: () -> Void

    var body: some View {
        ZStack {
            MainBackground()

            // MARK: - Email/Password TF's
            ScrollView{
                

                VStack (spacing: 10){
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.ultraThinMaterial,lineWidth: 2)
                        }
                        .overlay {
                            HStack(spacing:0) {
                                Image(systemName: "envelope")
                                    .padding(.horizontal, 5)
                                    .frame(width: 40)
                                
                                Divider()
                                Text(sessionManager.email.isEmpty ? "login / e-mail" : sessionManager.email)
                                    .foregroundStyle(
                                        sessionManager.email.isEmpty ? .gray : .primary
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
                            appState.promptString = "Enter login / e-mail"
                            appState.openTextFieldWithAction { newEmail in
                                sessionManager.email = newEmail
                            }
                        }
                    
                    //                        Text("Enter password")
                    //                            .font(.title2)
                    //                            .foregroundStyle(.secondary)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.ultraThinMaterial,lineWidth: 2)
                        }
                        .overlay {
                            HStack(spacing: 0) {
                                Image(systemName: "lock")
                                    .padding(.horizontal, 5)
                                    .frame(width: 40)
                                
                                Divider()
                                Text(
                                    sessionManager.password.isEmpty
                                    ? "password"
                                    : (sessionManager.password.map { _ in "*" }).joined()
                                )
                                .foregroundStyle(
                                    sessionManager.password.isEmpty ? .gray : .primary
                                )
                                .padding(.horizontal, 15)
                                
                                Spacer()
                            }
                        }
                        .frame(height: 40)
                        .padding(.bottom,10)
                        .onTapGesture {
                            appState.cleanTFInfo()
                            appState.fieldType = .password
                            appState.isSecure = true
                            appState.promptString = "Enter password"
                            appState.openTextFieldWithAction { pass in
                                sessionManager.password = pass
                            }
                        }
                    
                }
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.3))
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .padding(.top,120)
                .padding(.bottom,100)
                
                // MARK: - Sign Up button
                Button{
                    createAction()
                    router.stepBack()
                } label:{
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.ultraThinMaterial,lineWidth: 2)
                        }
                        .overlay {
                            Text("Sign Up")
                                .font(.title)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .padding(.horizontal)
                }
                .padding(.bottom, 10)
                
                Button{
                    sessionManager.cleanFields()
                    router.stepBack()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 24))
                }
                Spacer()
            }
            .scrollDisabled(true)
            .transitionWithOpacity()
            .navigationBarBackButtonHidden()
        }
        .ignoresSafeArea(.keyboard)
    }
}

