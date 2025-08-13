import AuthenticationServices
import Combine
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct AuthenticationScreen: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState
    
    @State private var isSignUp: Bool = false

    
    var body: some View {
        ZStack{
            MainBackground()
            VStack(spacing: 5){
                // MARK: - Logo
                //logo here. circle is just a placeholder
                Spacer()
                Circle()
                    .frame(width: 150, height: 150)
                    .opacity(0.8)
                    .overlay {
                        Text("LOGO")
                            .font(.title)
                            .bold()
                            .foregroundStyle(.white)
                    }
                Divider()
                
                // MARK: - Email/Password Zone

                VStack{
                    RoundedRectangle(cornerRadius: 5)
                        .fill( .ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.ultraThinMaterial)
                        }
                        .overlay {
                            HStack {
                                Text(sessionManager.email.isEmpty ? "login" : sessionManager.email)
                                    .foregroundStyle(sessionManager.email.isEmpty ? .gray: .primary)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            appState.cleanTFInfo()
                            appState.fieldType = .email
                            appState.isSecure = false
                            appState.promptString = "Enter login / e-mail"
                            appState.openTextFieldWithAction { email in
                                sessionManager.email = email
                            }
                        }
                    RoundedRectangle(cornerRadius: 5)
                        .fill( .ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.ultraThinMaterial)
                        }
                        .overlay {
                            HStack {
                                Text(sessionManager.password.isEmpty ? "password" : (sessionManager.password.map{_ in "*"}).joined())
                                    .foregroundStyle(sessionManager.password.isEmpty ? .gray: .primary)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                        }
                        .frame(height: 40)
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
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                
                // MARK: - "Forget password" button
//                HStack{
//                    Spacer()
//                    NavigationLink {
//                        BPResetPasswordView()
//                    } label: {
//                        Text("Forget password")
//                    }
//                }
//                .padding()
                
                // MARK: - "Sign In"
                Button(action: {
                    Task{
                        await sessionManager.signInWithEmailAndPassword()
                    }
                },
                       label: {
                    Text("Sign In")
                        .frame(height: 30)
                        .frame(width: 250)
                        .padding(.vertical,10)
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                })
                .padding(.bottom,20)
                .padding(.top,10)
                
                // MARK: - "Sign in with Google"
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                    Task{
                        await sessionManager.signInWithGoogle()
                    }
                }
                .frame(height: 44)
                .frame(width: 200)
                .padding(.horizontal)
                .padding(.bottom,10)
                
                // MARK: - "Sign in with Apple"
                SignInWithAppleButton { request in
                    request.requestedScopes = [.fullName, .email]
                    sessionManager.getRandomNonceString()
                    request.nonce = sessionManager.getSha256()
                } onCompletion: { result in
                    Task{
                        do { try await sessionManager.signInWithAppleWithResult(result)
                        } catch {
#if DEBUG
                            print("DEBUG: AuthenticationScreen/signInWithApple failed: \(error.localizedDescription)")
#endif
                        }
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 44)
                .frame(width: 200)
                .padding(.horizontal)
                .padding(.bottom,20)
                
                // MARK: - "Sign Up" Link
                Button {
                    isSignUp.toggle()
                } label: {
                    Text("Not Registered?   Sign Up!")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                Spacer()
            }
//            .fullScreenCover(isPresented: $isSignUp){
//                SignUpView(email: $sessionManager.email, password: $sessionManager.password) {
//                    Task{
//                        await sessionManager.signUp()
//                    }
//                }
//            }
//            .accentColor(.black)
        }
        .navigationBarBackButtonHidden()
        .onDisappear{
            sessionManager.email = ""
            sessionManager.password = ""
        }
        .ignoresSafeArea(.keyboard)
            
    }
}

// MARK: - Preview
#Preview {
    AuthenticationScreen()
        .environmentObject(SessionManager())
        .environmentObject(Router())
        .environmentObject(ApplicationState())
    
}
