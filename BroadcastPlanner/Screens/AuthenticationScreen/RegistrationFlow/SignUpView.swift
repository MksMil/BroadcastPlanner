//
//  SignUpView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 12.01.2024.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var viewManager: AuthViewManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            // MARK: - Dismiss
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "arrow.backward")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .frame(height: 30)
                    .padding(.horizontal)
                    .padding(.top)
                
            })
            
            VStack{
                // MARK: - Email/Password TF's
                BPTextFieldWithIcon(text: $viewManager.email,placeholder: "email", imageName: "envelope")
                BPTextFieldWithIcon(text: $viewManager.password,placeholder: "password" ,imageName: "lock.fill",isSecureField: true)
                
                // MARK: - Sign Up button
                Button(action: {
                    Task {
                        do{
                            try await viewManager.signUpwithEmailAndPassword()
                            dismiss()
                        } catch {
                            //UI error message must be here
                            print("failed to create user: \(error.localizedDescription)")
                        }
                    }
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
                .padding(.top, 40)
            }
            .padding(.top, 120)
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    SignUpView()
        .environmentObject(AuthViewManager())
}
