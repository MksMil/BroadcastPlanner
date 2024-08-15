//
//  BPTabBarView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 29.07.2024.
//

import SwiftUI

struct BPTabBarView: View {
    
    var body: some View {
        HStack(alignment:.bottom){
            Text("Events")
                .onTapGesture {
//                    mainRouter.goHome()
                }

            Divider()
            
            Text("Info")
                .onTapGesture {
//                    mainRouter.goPersonalInfo()
                }

            Divider()
            Text("Messages")
                .onTapGesture {
//                    mainRouter.goMessenger()
                }

            Divider()
            Text("Settings")
                .onTapGesture {
//                    mainRouter.goSettings()
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(.ultraThickMaterial)
            
        
    }
}

#Preview {
    BPTabBarView()
}
