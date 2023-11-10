//
//  StaffTabItamView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 15.10.2023.
//

import SwiftUI

struct StaffTabItamView: View {
    
    @State private var addBroadcasterViewShow: Bool = false
    @State private var addUserViewShow: Bool = false
    
    @EnvironmentObject var storage: Storage
    
    var body: some View {
        ZStack{
            BackgroundTabItem()
            
            VStack{
                Text("Broadcaster")
                
                Button("Add Broadcaster") {
                    addBroadcasterViewShow = true
                }
                .buttonStyle(.bordered)
                
                Text("Users")
                
                Button("Add User") {
                    addUserViewShow = true
                }
                .buttonStyle(.bordered)
            }
        }
        .foregroundStyle(Color.white)
    }
}

#Preview {
    StaffTabItamView()
        .environmentObject(Storage())
}
