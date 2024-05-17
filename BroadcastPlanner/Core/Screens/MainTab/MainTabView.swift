import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject var globalStorage: GlobalStorage

    @State var selection: Int = 0
    
    
    var body: some View {
        
        TabView(selection: $selection) {
            MainEventsList()
                .tabItem { Label("Events", systemImage: "calendar")
                    .foregroundStyle(Color.white) }
                .tag(0)
            
            // MyInfo Screen
            BPAccountInfoView()
                .tabItem { Label("Info", systemImage: "figure.mind.and.body") }
                .tag(1)
                
            //messenger
            BPMessengerView()
                .tabItem { Label("Messege", systemImage: "message.badge") }
                .tag(2)
            //Settings Screen
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(3)
                
        }
        .toolbarBackground(Color.clear, for: .tabBar)
        .tint(Color.accentColor)
        .environmentObject(globalStorage)
    }
}

#Preview {
    MainTabView()
        .environmentObject(GlobalStorage())
    
}
