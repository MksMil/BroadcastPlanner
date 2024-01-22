//
//  StarterScreen.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 10.01.2024.
//

import SwiftUI

struct StarterScreen: View {
    @State var isErrorShow: Bool = true
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
            .blur(radius: globalStorage.isErrorShow ? 20.0 : 0.0)
            .animation(.easeInOut, value: globalStorage.isErrorShow)
            .zIndex(1)
            .disabled(globalStorage.isErrorShow)
            
            if globalStorage.isErrorShow{
                BPErrorView(errorDescription: globalStorage.errorDescription)
                    .transition(.asymmetric(insertion: .scale.animation(.easeInOut), removal: .scale.animation(.easeInOut)))
                    .zIndex(2)
                    .onTapGesture { globalStorage.isErrorShow = false }
                // TODO: Manage canceling task if disappear manualy
//                    .onAppear{
//                        Task{
//                            DispatchQueue.main.asyncAfter(deadline:.now() + 15){
//                                withAnimation(.easeInOut) {
//                                    globalStorage.isErrorShow = false
//                                }
//                            }
//                        }
//                    }
            }
        }
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
