//
//  UpdateEPView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 24.01.2024.
//

import SwiftUI
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
    
    // TODO: must remove globalStorage dependency
    @EnvironmentObject var globalStorage: GlobalStorage
    
    @FocusState private var isFocus: FieldInFocus?
    var currentValue: String
    @State private var oldValue: String = ""
    @State private var newValue: String = ""
    
    var updEP: UpdatedEP
    
    var body: some View {
        
        ZStack{
            MainBackground()
            
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
        guard let currentUser = globalStorage.currentSessionUser else {
            return
        }
        if currentUser.email == oldValue{
            do{
                try await AuthenticationManager.shared.updateEmail(newEmail: newValue)
                //email chnged
                dismiss()
            } catch {
#if DEBUG
                print("DEBUG:\(error.localizedDescription)")
#endif
            }
        } else {
          //wrong old email value
        }
    }
    
    func updatePassword() async{
        guard oldValue == globalStorage.password else {
            //wrong password conformance
            return
        }
        do{
            try await AuthenticationManager.shared.updatePass(pass: newValue)
            //password changed
            dismiss()
        } catch {
#if DEBUG
            print("DEBUG:\(error.localizedDescription)")
#endif
        }
    }
}

#Preview {
    UpdateEPView(currentValue: "", updEP: .password)
        .environmentObject(GlobalStorage())
    
}
//#Preview {
//        UpdateEPView(updEP: .email)
//        .environmentObject(GlobalStorage())
//
//}
