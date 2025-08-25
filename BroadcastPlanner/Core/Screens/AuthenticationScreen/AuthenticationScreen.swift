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

    var body: some View {
        ZStack{
            MainBackground()
            ScrollView{
                VStack(spacing: 5){
                    // MARK: - Logo
                    //logo here. circle is just a placeholder
                    Circle()
                        .opacity(0.8)
                        .overlay {
                            Text("LOGO")
                                .font(.title)
                                .bold()
                                .foregroundStyle(.white)
                        }
                        .frame(width: 150, height: 150)
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
                    //TODO: forget password flow
                                    HStack{
                                        Spacer()
//                                        NavigationLink {
//                                            BPResetPasswordView()
//                                        } label: {
                                            Text("Forget password")
//                                        }
                                    }
                                    .padding()
                    
                    // MARK: - "Sign In"
                    Button{
                        Task{
                            await sessionManager.signInWithEmailAndPassword()
                        }
                    } label:{
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.white.opacity(0.7))
                            .overlay {
                                HStack {
                                    
                                    Text("Sign In")
                                        .foregroundStyle(.primary)
                                        .padding(.leading, 8)
                                    
                                }
                            }
                            .frame(height: 40)
                            .padding(.horizontal)
                            .padding(.vertical,20)
                    }
                        
//                    .padding(.bottom,20)
//                    .padding(.top,10)
                    
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
                    
                    
//                    // MARK: - "Sign in with Apple"
                    
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
                    Spacer()
                    Button{
                        sessionManager.cleanFields()
                        router.routeTo(path: RouterPath.sighUp)
                    } label: {
                        Text("Not Registered?   Sign Up!")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                
            }
            .scrollDisabled(true)
            .transitionWithOpacity()
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden()
        .onDisappear{
            sessionManager.cleanFields()
        }
        
    }
}

// MARK: - Preview
#Preview {
    AuthenticationScreen()
        .environmentObject(SessionManager())
        .environmentObject(Router())
        .environmentObject(ApplicationState())
    
}
