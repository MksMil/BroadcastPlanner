//
//  SettingsView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 12.01.2024.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var globalStorage: GlobalStorage
    
    @Binding var isLogged: Bool
    @State var newEmail: String = ""
    @State var newPassword: String = ""
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundTabItem()
                VStack{
                    Text("Settings here")
                        .foregroundStyle(Color.accentColor)
                        .font(.title)
                        .bold()
                    Spacer()
                }
                VStack{
                    Section {
                        VStack(spacing: 15){
                            NavigationLink {
                                UpdateEPView(updEP: .email)
                            } label: {
                                Text("Change E-mail")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background {Color.white.opacity(30)}
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.horizontal)
                            }
                            
                            NavigationLink {
                                UpdateEPView(updEP: .password)
                            } label: {
                                Text("Change Password")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background {Color.white.opacity(30)}
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.horizontal)
                            }
                        }
                    } header: {
                        Text("Email and Password")
                            .font(.title2)
                            .fontWeight(.light)
                            .foregroundStyle(Color.gray)
                    }
                }.foregroundStyle(Color.accent)
                
                // MARK: - "Sign out" button
                VStack{
                    Spacer()
                    Button(action: {
                        Task{
                            do{
                                try AuthenticationManager.shared.logOut()
                                
                            } catch {
                                print("failed to signing out: \(error.localizedDescription)")
                            }
                        }
                        isLogged = false
                        globalStorage.showSuccessMessage()
                        
                    }, label: {
                        Text("Sign Out")
                            .font(.title)
                            .foregroundColor(.accent)
                    })
                    
                    .padding(.bottom)
                }
                
            }
        }
    }
}

#Preview {
    SettingsView(isLogged: .constant(false))
        .environmentObject(GlobalStorage())
}
