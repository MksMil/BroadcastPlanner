//
//  LogScreen.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 04.01.2024.
//

import SwiftUI

struct LogScreen: View {
    
    @Binding var isLogged: Bool
    
    @State var login: String = ""
    @State var password: String = ""
    
    var body: some View {
        ZStack{
            BackgroundTabItem()
            VStack{
                Spacer()
                
                TextField("login", text: $login, prompt: Text("Login").foregroundColor(.orange.opacity(0.7)))
                    .frame(height: 40)
                    .padding(.horizontal)
                    .background(Color.white)
                    .foregroundStyle(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).strokeBorder(Color.orange,lineWidth: 2)
                    }
                    .padding(.horizontal)
                    .keyboardType(.default)
                    
                TextField("password", text: $password, prompt: Text("Password").foregroundColor(.orange.opacity(0.7)))
                    .frame(height: 40)
                    .padding(.horizontal)
                    .background(Color.white)
                    .foregroundStyle(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8).strokeBorder(Color.orange,lineWidth: 2)
                    }
                    .padding(.horizontal)
                    .keyboardType(.default)
                
                Spacer()
                Button("Log in") {
                    isLogged = true
                    print("logged In")
                }
                .foregroundColor(.white)
            }
            .padding()
        }
    }
}

#Preview {
    LogScreen(isLogged: .constant(false))
}
