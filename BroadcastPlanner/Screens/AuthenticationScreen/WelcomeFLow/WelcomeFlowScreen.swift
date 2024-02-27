//
//  WelcomeFlowScreen.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 23.02.2024.
//

import SwiftUI



struct WelcomeFlowScreen: View {

    @State var selection: Int = 1
    
    var body: some View {
        TabView(selection: $selection,
                content:  {
            Text("Welcome!\nselection: \(selection)").tabItem { Text("Tab Label 1") }.tag(1)
            Text("Move Forvard\nselection: \(selection)").tabItem { Text("Tab Label 2") }.tag(2)
        })
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color.gray)
        
    }
}

#Preview {
    WelcomeFlowScreen()
}
