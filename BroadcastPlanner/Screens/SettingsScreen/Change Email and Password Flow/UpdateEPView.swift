//
//  UpdateEPView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 24.01.2024.
//

import SwiftUI
import Firebase
import Combine

enum UpdatedEP: String,Identifiable {
    case email, password
    
    var id: String {
        return self.rawValue
    }
}

struct UpdateEPView: View {
    enum FieldInFocus: Hashable{
        case firstField, secondField
    }
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var globalStorage: GlobalStorage
    
    @FocusState private var isFocus: FieldInFocus?
    
    @State private var oldValue: String = ""
    @State private var newValue: String = ""
 var updEP: UpdatedEP
    
    var body: some View {
        
        ZStack{
            Color.mainBackgroundColor.ignoresSafeArea()
            
            VStack{
                // MARK: - Header Text
                Text("Update \(updEP == .email ? "email":"password")")
                    .font(.title)
                    .foregroundColor(.accentColor)
                    .padding(.top)
                    
                VStack(spacing: 20){
                    // MARK: - Old Value TF
                    BPTextFieldWithIcon(text: $oldValue,
                                        placeholder: "old \(updEP == .email ? "email":"password")",
                                        imageName: updEP == .email ? "envelope":"lock.fill",
                                        isSecureField: updEP == .password  )
                    .keyboardType(updEP == .email ? .emailAddress: .default)
                    .focused($isFocus, equals: .firstField)
                    
                   // MARK: - New Value TF
                    BPTextFieldWithIcon(text: $newValue,
                                        placeholder: "new \(updEP == .email ? "email":"password")",
                                        imageName: updEP == .email ? "envelope":"lock.fill",
                                        isSecureField: updEP == .password  )
                    .keyboardType(updEP == .email ? .emailAddress: .default)
                    .focused($isFocus, equals: .secondField)
                    
                    // MARK: - Confirm Button
                    Button{
                        Task{
                            isFocus = nil
                            print("keyboard dissabled")
                            updEP == .email ? await updateEmail(): await updatePassword()
                        }
                    } label: {
                        
                        Text("Confirm")
                            .font(.title)
                            .foregroundStyle(Color.accent)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundColor(Color.white.opacity(0.7))
                            .padding(.horizontal)
                    }
                    .padding(.top,20)
                   Spacer()
                }
                .padding(.top,100)
            }
        }
        
    }
    
    func updateEmail() async {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        if currentUser.email == oldValue{
            do{
                try await AuthenticationManager.shared.updateEmail(newEmail: newValue)
                dismiss()
                globalStorage.showSuccessMessage()
            } catch {
                globalStorage.showError(error: error)
            }
        } else {
            print("error shown")
            globalStorage.showErrorWithDescription(des: ("Wrong old Email", "envelope.badge.shield.half.filled"))
        }
        
    }
    
    func updatePassword() async{
        guard oldValue == globalStorage.password else {
            globalStorage.showErrorWithDescription(des: ("Wrong old Password", "key.slash"))
            return
        }
        do{
            try await AuthenticationManager.shared.updatePass(pass: newValue)
            print("password changed!")
            dismiss()
            globalStorage.showSuccessMessage()
        } catch {
            print("password NOT changed! error: \(error)")
            globalStorage.showError(error: error)
        }
    }
}

#Preview {
    UpdateEPView(updEP: .password)
        .environmentObject(GlobalStorage())
    
}
//#Preview {
//        UpdateEPView(updEP: .email)
//        .environmentObject(GlobalStorage())
//
//}
