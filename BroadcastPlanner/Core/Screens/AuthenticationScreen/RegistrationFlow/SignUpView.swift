//
//  SignUpView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 12.01.2024.
//

import SwiftUI
//import Combine


struct SignUpView: View {
    enum FieldInFocus: Hashable{
        case firstField, secondField
    }
    @FocusState private var isFocused: FieldInFocus?
    
//    @EnvironmentObject var globalStorage: GlobalStorage
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AuthViewModel
    
    
    var body: some View {
        ZStack{
            MainBackground()
            
            VStack{
                // MARK: - Email/Password TF's
                BPTextFieldWithIcon(text: $viewModel.email,
                                    placeholder: "email",
                                    imageName: "envelope")
                    .keyboardType(.emailAddress)
                    .focused($isFocused,
                             equals: .firstField)
                
                BPTextFieldWithIcon(text: $viewModel.password,
                                    placeholder: "password",
                                    imageName: "lock.fill",
                                    isSecureField: true)
                    .keyboardType(.default)
                    .focused($isFocused,
                             equals: .secondField)
                
                // MARK: - Sign Up button
                Button(action: {
                    Task {
                        do{
                            isFocused = nil
                            viewModel.currentSessionUser = try await AuthenticationManager.shared.createUser(
                                email: viewModel.email,
                                password: viewModel.password
                            )
                            dismiss()
                        } catch {
#if DEBUG
                            print("DEBUG:\(error.localizedDescription)")
#endif
                        }
                    }
                },
                       label: {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .padding()
                        .background(.ultraThickMaterial)
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
    SignUpView(viewModel: GlobalStorage().authVm)
}
