//
//  StarterScreen.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 10.01.2024.
//

import SwiftUI

struct StarterScreen: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    
    var body: some View {
        ZStack{
            ZStack{
                if globalStorage.currentFirebaseUser == nil{
                    AuthenticationScreen()
                } else {
                    MainTabView()
                }
            }
        }
        .bpError(isShown: $globalStorage.isErrorShow, errorDescription: $globalStorage.errorDescription)

    }
}

#Preview {
    StarterScreen()
        .environmentObject(GlobalStorage())
}
