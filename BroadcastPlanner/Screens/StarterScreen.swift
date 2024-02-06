//
//  StarterScreen.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 10.01.2024.
//

import SwiftUI

struct StarterScreen: View {
    @State private var isLogged = false
    @StateObject var globalStorage: GlobalStorage = GlobalStorage()
    
    var body: some View {
        ZStack{
            ZStack{
                if !isLogged{
                    AuthenticationScreen(isLogged: $isLogged)
                        .environmentObject(globalStorage)
                } else {
                    MainTabView(isLogged: $isLogged)
                        .environmentObject(globalStorage)
                }
            }
            
        }
        .bpError(isShown: $globalStorage.isErrorShow, errorDescription: $globalStorage.errorDescription)
        .onAppear{
            Task{
                do{
                    globalStorage.currentFirebaseUser = try AuthenticationManager.shared.getUser()
                    self.isLogged = globalStorage.currentFirebaseUser != nil
                    print("isLogged")
                } catch {
                    
                    print("no current user")
                }
            }
        }
    }
}

#Preview {
    StarterScreen()
}
