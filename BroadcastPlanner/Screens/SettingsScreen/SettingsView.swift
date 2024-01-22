//
//  SettingsView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 12.01.2024.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var isLogged: Bool
    
    var body: some View {
        ZStack{
            BackgroundTabItem()
            VStack{
                Text("Settings here")
                
                // MARK: - "Sign out" button
                Button(action: {
                    Task{
                        do{
                           try AuthenticationManager.shared.logOut()
                        } catch {
                            print("failed to signing out: \(error.localizedDescription)")
                        }
                    }
                    isLogged = false
                }, label: {
                    Text("Sign Out")
                        .foregroundStyle(.white)
                })
            }
        }
    }
}

#Preview {
    SettingsView(isLogged: .constant(false))
}
