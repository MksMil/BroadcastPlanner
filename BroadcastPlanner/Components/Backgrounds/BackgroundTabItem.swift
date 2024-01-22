//
//  BackgroundTabItem.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 15.10.2023.
//

import SwiftUI

struct BackgroundTabItem: View {
    var body: some View {
        ZStack{
            Color.lightBackgroundColor
                .ignoresSafeArea()
        }
    }
}

#Preview {
    BackgroundTabItem()
}
