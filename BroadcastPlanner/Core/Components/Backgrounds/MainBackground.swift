//
//  BackgroundTabItem.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 15.10.2023.
//

import SwiftUI

struct MainBackground: View {
    var body: some View {
        ZStack{
            Color("MainBackgroundColor")
                .ignoresSafeArea()
        }
    }
}

#Preview {
    MainBackground()
}
