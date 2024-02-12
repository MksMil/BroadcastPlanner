//
//  StartScreen.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 10.01.2024.
//

import SwiftUI
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import Combine
import AuthenticationServices


struct AuthenticationScreen: View {
    enum FieldInFocus: Hashable{
        case firstField, secondField
    }
    
    @FocusState private var isFocused: FieldInFocus?
    
    @StateObject var viewManager: AuthViewManager = AuthViewManager()
    @EnvironmentObject var globalStorage: GlobalStorage
    @Binding var isLogged: Bool
    
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
                        BPTextFieldWithIcon(text: $viewManager.email,
                                            placeholder: "e-mail",
                                            imageName: "envelope")
                        .keyboardType(.emailAddress)
                        .focused($isFocused,equals: .firstField)
                        
                        BPTextFieldWithIcon(text: $viewManager.password,
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
                        Task{
                            do {
                                isFocused = nil
                                try await viewManager.signInWithEmailAndPassword()
                                isLogged = true
                                globalStorage.showSuccessMessage()
                            } catch {
                                globalStorage.showError(error: error)
                            }
                        }
                    }, label: {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .padding()
                            .background { Color(.systemGray4)}
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.horizontal)
                    })
                    
                    Divider()
                    
                    if isFocused == nil {
                        
                        // MARK: - "Sign in with Google"
                        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .standard, state: .normal)) {
                            Task{
                                try await AuthenticationManager.shared.signWithGgl()
                                isLogged = true
                                globalStorage.showSuccessMessage()
                            }
                        }
                        .frame(height: 50)
//                        .clipShape(RoundedRectangle(cornerRadius: ))
                        .padding(.horizontal)
                        .transition(.asymmetric(insertion: .opacity
                            .animation(.easeInOut(duration: 0.3)),
                                                removal: .opacity
                            .animation(.easeInOut(duration: 0.3))))
                        
                        
                        // MARK: - "Sign in with Apple"
                        SignInWithAppleButton { req in
                            
                        } onCompletion: { res in
                            
                        }
                        .frame(height: 50)
                        .padding(.horizontal)
                        .transition(.asymmetric(insertion: .opacity
                            .animation(.easeInOut(duration: 0.3)),
                                                removal: .opacity
                            .animation(.easeInOut(duration: 0.3))))


                        
                        Spacer()
                        
                        // MARK: - "Sign Up" Link
                        NavigationLink {
                            SignUpView()
                                .environmentObject(viewManager)
                        } label: {
                            Text("Sign Up")
                                .frame(maxWidth: .infinity)
                                .frame(height: 30)
                                .padding()
                                .background { Color(.systemGray4)}
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal)
                        }
                        .transition(.asymmetric(insertion: .opacity
                            .animation(.easeInOut(duration: 0.3)),
                                                removal: .opacity
                            .animation(.easeInOut(duration: 0.3))))
                        
                        
                    }
                    Spacer()
                }
                //                .padding(.top,20)
            }
        }
    }
}


// MARK: - Preview
#Preview {
    AuthenticationScreen(isLogged: .constant(false))
        .environmentObject(GlobalStorage())
}
