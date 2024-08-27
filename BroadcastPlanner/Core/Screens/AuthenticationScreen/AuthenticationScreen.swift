import AuthenticationServices
import Combine
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct AuthenticationScreen: View {
    
    var globalStorage: GlobalStorage
    
//    @StateObject private var authVm = AuthViewModel()
    
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    
    @State private var isSignUp: Bool = false
    
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
                BPEmailPasswordStack(email: $email,
                                     password: $password)
                
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
                        do {
                            globalStorage.currentSessionUser = try await AuthenticationManager.shared.signIn(
                                withEmail: email,
                                password: password
                            )
                            globalStorage.password = password
                            
                        } catch {
#if DEBUG
                            print("DEBUG:\(error.localizedDescription)")
#endif
                        }
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
                        do {
                            globalStorage.currentSessionUser = try await AuthenticationManager.shared.signWithGgl()
                            
                        }
                        catch {
#if DEBUG
                            print("DEBUG:\(error.localizedDescription)")
#endif
                        }
                    }
                }
                .frame(height: 44)
                .frame(width: 200)
                .padding(.horizontal)
                .padding(.bottom,10)
                
                // MARK: - "Sign in with Apple"
                SignInWithAppleButton { request in
                    request.requestedScopes = [.fullName, .email]
                    globalStorage.applCurrentNonce = AppleHelper.getRandomNonceString()
                    request.nonce = AppleHelper.getSha256(globalStorage.applCurrentNonce)
                } onCompletion: { result in
                    Task{
                        do { globalStorage.currentSessionUser = try await AuthenticationManager.shared.signInWithAppleWithResult(result, currentNonce: globalStorage.applCurrentNonce)
                            
                        } catch {
#if DEBUG
                            print("DEBUG:\(error.localizedDescription)")
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
            SignUpView {email, password in
                Task{
                    await globalStorage.signUp(email: email,
                                               password: password
                    )
                    globalStorage.password = password
                    
                }
            }
        }
        .background(content: {
            MainBackground().ignoresSafeArea()
        })
        .scrollDisabled(true)
        .navigationBarBackButtonHidden()
        .accentColor(.black)
    }
}


// MARK: - Email and password fields
struct BPEmailPasswordStack: View {
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


// MARK: - Preview
#Preview {
    AuthenticationScreen(globalStorage: GlobalStorage())
    
}
