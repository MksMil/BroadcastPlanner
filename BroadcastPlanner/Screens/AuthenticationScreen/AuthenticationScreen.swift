//
//  StartScreen.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 10.01.2024.
//

import SwiftUI

struct AuthenticationScreen: View {
    
    @StateObject var viewManager: AuthViewManager = AuthViewManager()
    @EnvironmentObject var globalStorage: GlobalStorage
    @Binding var isLogged: Bool
    
    
    
    @State private var isSignUp: Bool = false
    
    //viewModel here, viewModel contrlos data and delegates creating user to manager
    
    
    var body: some View {
        ZStack{
            Color.blue.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 20){
                // MARK: - Logo
                //logo here. circle is just a placeholder
                Circle()
                    .frame(width: 150)
                    .opacity(0.8)
                
                Divider()
                // MARK: - Email/Password Textfields
                VStack{
                    BPTextFieldWithIcon(text: $viewManager.email,
                                        placeholder: "e-mail",
                                        imageName: "envelope")
                    
                    BPTextFieldWithIcon(text: $viewManager.password,
                                        placeholder: "password",
                                        imageName: "lock.fill",
                                        isSecureField: true)
                }
                
                // MARK: - "Forget password" button
                HStack{
                    Spacer()
                    Button(action: {
                        Task {
                            
                                globalStorage.errorDescription = BPErrorHandleManager.mockError
                                globalStorage.isErrorShow = true
                            
                        }
                    }, label: {
                        Text("Forget password")
                    })
                }
                .padding(.horizontal)
                
                VStack{
                    
                    // MARK: - "Sign In"
                    Button(action: {
                        Task{
                            do {
                                try await viewManager.signInWithEmailAndPassword()
                                isLogged = true
                            } catch {
                                //UI error message must be here
                                print(error.localizedDescription)
                            }
                        }
                        
                    }, label: {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .padding()
                            .background {
                                Color(.systemGray4)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.horizontal)
                    })
                    
                    Divider()
                    
                    Spacer()
                    
                    // MARK: - "Sign in with Google"
                    Button(action: {
                        
                    }, label: {
                        Text("Sign In with Google")
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .padding()
                            .background {
                                Color(.systemGray4)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.horizontal)
                    })
                    
                    // MARK: - "Sign in with Apple"
                    Button(action: {
                        globalStorage.errorDescription = BPErrorHandleManager.handleError(error: BPError.invalidData, completion: { })
                        globalStorage.isErrorShow = true
                    }, label: {
                        Text("Sign In with Apple")
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .padding()
                            .background {
                                Color(.systemGray4)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.horizontal)
                    })
                    Spacer()
                }
                Spacer()
                
                // MARK: - "Sign Up" button
                Button(action: {
                    viewManager.email = ""
                    viewManager.password = ""
                    isSignUp = true
                    
                }, label: {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .padding()
                        .background {
                            Color(.systemGray4)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                })
                .padding(.bottom)
            }
            // MARK: - "Sign Up" flow
            .fullScreenCover(isPresented: $isSignUp) {
                SignUpView()
                    .environmentObject(viewManager)
            }
        }
    }
}


// MARK: - Preview
#Preview {
    AuthenticationScreen(isLogged: .constant(false))
}
