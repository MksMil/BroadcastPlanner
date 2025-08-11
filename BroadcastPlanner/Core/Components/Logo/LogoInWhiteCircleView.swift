//
//  LogoInWhiteCircleView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 07.08.2025.
//

import SwiftUI

struct LogoInWhiteCircleView: View {
    
    let image: Image
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            
            image
                .resizable()
                .scaledToFill()
                .frame(width:  w,height:  w)
                .clipShape(Circle())
                .contentShape(Circle())
                .overlay {
                    Circle().stroke(Color.white, lineWidth: 2)
                }
        }
        
    }
}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif
