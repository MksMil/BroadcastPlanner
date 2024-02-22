//
//  SignUpView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 12.01.2024.
//

import SwiftUI
import Combine


struct SignUpView: View {
    enum FieldInFocus: Hashable{
        case firstField, secondField
    }
    
    @EnvironmentObject var globalStorage: GlobalStorage
    @FocusState private var isFocused: FieldInFocus?
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack{
            Color.mainBackgroundColor
                .ignoresSafeArea()
            
            VStack{
                // MARK: - Email/Password TF's
                BPTextFieldWithIcon(text: $email,placeholder: "email", imageName: "envelope")
                    .keyboardType(.emailAddress)
                    .focused($isFocused,equals: .firstField)
                
                BPTextFieldWithIcon(text: $password,placeholder: "password" ,imageName: "lock.fill",isSecureField: true)
                    .keyboardType(.default)
                    .focused($isFocused,equals: .secondField)
                
                // MARK: - Sign Up button
                Button(action: {
                    Task {
                        do{
                            isFocused = nil
                            globalStorage.currentFirebaseUser = try await AuthenticationManager.shared.createUser(email: email, password: password)
                            dismiss()
                        } catch {
                            globalStorage.showError(error: error)
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
                Spacer()
            }
            .padding(.top, 120)
        }
    }
}

// MARK: - Preview
#Preview {
    SignUpView()
        .environmentObject(GlobalStorage())
}
