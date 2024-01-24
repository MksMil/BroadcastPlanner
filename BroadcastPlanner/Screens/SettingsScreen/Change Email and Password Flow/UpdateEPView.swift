//
//  UpdateEPView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 24.01.2024.
//

import SwiftUI
import Firebase

enum UpdatedEP: String {
    case email, password
    
}
extension UpdatedEP: Identifiable{
    var id: String {
        return self.rawValue
    }
}

struct UpdateEPView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var globalStorage: GlobalStorage
    @State private var oldValue: String = ""
    @State private var newValue: String = ""
    var updEP: UpdatedEP
    
    var body: some View {
        ZStack{
            Color.mainBackgroundColor.ignoresSafeArea()
            // MARK: - Dismiss
            VStack{
                
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
                Spacer()
            }
            VStack{
                Text("Udate \(updEP == .email ? "email":"password")")
                    .font(.title)
                    .foregroundColor(.accentColor)
                    .padding(.top)
                Spacer()
            }
            VStack(spacing: 20){
                Spacer()
                BPTextFieldWithIcon(text: $oldValue,
                                    placeholder: "old \(updEP == .email ? "email":"password")",
                                    imageName: updEP == .email ? "envelope":"lock.fill",
                                    isSecureField: updEP == .password  )
                
                BPTextFieldWithIcon(text: $newValue,
                                    placeholder: "new \(updEP == .email ? "email":"password")",
                                    imageName: updEP == .email ? "envelope":"lock.fill",
                                    isSecureField: updEP == .password  )
                Button(action: {
                    Task{
                        updEP == .email ? await updateEmail(): await updatePassword()
                    }
                }, label: {
                    
                    Text("Confirm")
                        .font(.title)
                        .foregroundStyle(Color.accent)
                    
                })
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background {
                    RoundedRectangle(cornerRadius: 25.0)
                        .foregroundColor(Color.white.opacity(0.7))
                        .padding(.horizontal)
                }
                .padding(.top,20)
                Spacer()
                Spacer()
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
                globalStorage.showSuccessMessage()
                dismiss()
            } catch {
                globalStorage.errorDescription = BPErrorHandleManager.handleFError(error: error as NSError)
                globalStorage.isErrorShow = true
            }
        } else {
            globalStorage.errorDescription = ("Wrong old Email", "envelope.badge.shield.half.filled")
            globalStorage.isErrorShow = true
        }

    }
    
    func updatePassword() async{
        guard oldValue == globalStorage.password else {
            globalStorage.errorDescription = ("Wrong old Password", "key.slash")
            globalStorage.isErrorShow = true
            return
        }
        
            do{
                try await AuthenticationManager.shared.updatePass(pass: newValue)
                globalStorage.showSuccessMessage()
                dismiss()
            } catch {
                globalStorage.errorDescription = BPErrorHandleManager.handleFError(error: error as NSError)
                globalStorage.isErrorShow = true
            }
    }
}

#Preview {
        UpdateEPView(updEP: .password)
        .environmentObject(GlobalStorage())
        
}
#Preview {
        UpdateEPView(updEP: .email)
        .environmentObject(GlobalStorage())
        
}
