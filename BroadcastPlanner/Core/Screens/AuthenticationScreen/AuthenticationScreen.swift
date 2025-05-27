import AuthenticationServices
import Combine
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct AuthenticationScreen: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var isSignUp: Bool = false
//    let signUpHandler: (BPUser)->()
    
    var body: some View {
        ScrollView{
            VStack{
                // MARK: - Logo
                //logo here. circle is just a placeholder
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
                
                // MARK: - Email/Password Textfields
                EmailPasswordStack(email: $sessionManager.email,
                                     password: $sessionManager.password)
                
                // MARK: - "Forget password" button
                HStack{
                    Spacer()
                    NavigationLink {
                        BPResetPasswordView()
                    } label: {
                        Text("Forget password")
                    }
                }
                .padding()
                
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
                .padding(.bottom,50)
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
                .padding(.bottom,50)
                
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
            .padding(.top,25)
        }
        .fullScreenCover(isPresented: $isSignUp){
            SignUpView(email: $sessionManager.email, password: $sessionManager.password) {
                Task{
                    await sessionManager.signUp()
//                    guard let id = sessionManager.sessionUser?.id else { return }
//                    var member = BPUser(id: id)
//                    signUpHandler(member)
                }
            }
        }
        .background{
            MainBackground().ignoresSafeArea()
        }
        .scrollDisabled(true)
        .navigationBarBackButtonHidden()
        .accentColor(.black)
        .onDisappear{
            sessionManager.email = ""
            sessionManager.password = ""
        }
    }
}

// MARK: - Preview
#Preview {
    AuthenticationScreen()
        .environmentObject(SessionManager())
    
}
