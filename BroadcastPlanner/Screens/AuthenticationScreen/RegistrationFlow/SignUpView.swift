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
    @EnvironmentObject var viewManager: AuthViewManager
    @FocusState private var isFocused: FieldInFocus?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack{
            Color.mainBackgroundColor
                .ignoresSafeArea()
            
            VStack{
                // MARK: - Email/Password TF's
                BPTextFieldWithIcon(text: $viewManager.email,placeholder: "email", imageName: "envelope")
                    .keyboardType(.emailAddress)
                    .focused($isFocused,equals: .firstField)
                
                BPTextFieldWithIcon(text: $viewManager.password,placeholder: "password" ,imageName: "lock.fill",isSecureField: true)
                    .keyboardType(.default)
                    .focused($isFocused,equals: .secondField)
                
                // MARK: - Sign Up button
                Button(action: {
                    Task {
                        do{
                            isFocused = nil
                            try await viewManager.signUpwithEmailAndPassword()
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
        .environmentObject(AuthViewManager())
        .environmentObject(GlobalStorage())
}
