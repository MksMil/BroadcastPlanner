//
//  StartScreen.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 10.01.2024.
//

import AuthenticationServices
import Combine
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI


struct AuthenticationScreen: View {
    enum FieldInFocus: Hashable{
        case firstField, secondField
    }
    
    @FocusState private var isFocused: FieldInFocus?
    @State private var email: String = ""
    @State private var password: String = ""
    
    @EnvironmentObject var globalStorage: GlobalStorage
    
    
    //viewModel here, viewModel contrlos data and delegates creating user to manager
    
    var body: some View {
        NavigationStack{
            ZStack{
                
                Color.mainBackgroundColor.ignoresSafeArea()
                
                VStack{
                    // MARK: - Logo
                    //logo here. circle is just a placeholder
                    Circle()
                        .frame(width: 150, height: 150)
                        .opacity(0.8)
                    
                    Divider()
                    // MARK: - Email/Password Textfields
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
                    
                    // MARK: - "Forget password" button
                    HStack{
                        Spacer()
                        Button(action: {
                            Task {
                                
                            }
                        }, label: {
                            Text("Forget password")
                        })
                    }
                    .padding(.horizontal)
                    
                    // MARK: - "Sign In"
                    Button(action: {
                        isFocused = nil
                        Task{
                            do {
                                globalStorage.currentFirebaseUser = try await AuthenticationManager.shared.signIn(withEmail: email, password: password)
                                globalStorage.showSuccessMessage()
                            } catch {
                                globalStorage.showError(error: error)
                            }
                        }
                    }, label: {
                        Text("Sign In")
                            .frame(height: 30)
                            .frame(width: 200)
                            .padding(.vertical,10)
                            .background { Color(.systemGray4)}
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.horizontal)
                    })
                    .padding(.bottom,20)
                    
                    //                    Divider()
                    
                    if isFocused == nil {
                        // MARK: - "Sign in with Google"
                        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                            Task{
                                do {
                                    globalStorage.currentFirebaseUser = try await AuthenticationManager.shared.signWithGgl()
                                    globalStorage.showSuccessMessage()
                                } catch {
                                    globalStorage.showError(error: BPError.authError)
                                    //debug
                                    print("\(error.localizedDescription)")
                                }
                            }
                        }
                        .frame(height: 44)
                        .frame(width: 200)
                        .padding(.horizontal)
                        .transition(.asymmetric(insertion: .opacity.animation(.easeInOut(duration: 0.3)),
                                                removal: .opacity.animation(.easeInOut(duration: 0.3))))
                        .padding(.bottom,10)
                        
                        // MARK: - "Sign in with Apple"
                        SignInWithAppleButton { request in
                            request.requestedScopes = [.fullName, .email]
                            globalStorage.applCurrentNonce = AuthenticationManager.shared.getRandomNonceString()
                            request.nonce = AuthenticationManager.shared.getSha256(globalStorage.applCurrentNonce)
                        } onCompletion: { result in
                            Task{
                                do { globalStorage.currentFirebaseUser = try await AuthenticationManager.shared.handleResult(result, currentNonce: globalStorage.applCurrentNonce)
                                    globalStorage.showSuccessMessage()
                                } catch {
                                    globalStorage.showError(error: BPError.authError)
                                    //debug
                                    print("\(error.localizedDescription)")
                                }
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 40)
                        .frame(width: 200)
                        .padding(.horizontal)
                        .transition(.asymmetric(insertion: .opacity.animation(.easeInOut(duration: 0.3)),
                                                removal: .opacity.animation(.easeInOut(duration: 0.3))))
                                                
                        Spacer()
                        
                        // MARK: - "Sign Up" Link
                        NavigationLink {
                            SignUpView()
                            
                        } label: {
                            Text("Not Registered?   Sign Up!")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background { Color(.systemGray4)}
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal)
                        }
                        .transition(.asymmetric(insertion: .opacity.animation(.easeInOut(duration: 0.3)),
                                                removal: .opacity.animation(.easeInOut(duration: 0.3))))
                    }
                    Spacer()
                }
                .padding(.top,20)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AuthenticationScreen()
        .environmentObject(GlobalStorage())
}
