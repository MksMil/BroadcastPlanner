import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    
    var storage: Storage = Storage(
        events: [
            MockData.sampleEvent,
            MockData.sampleEvent,
            MockData.sampleEvent
        ]
    )
    
    var body: some View {
        
        TabView {
            MainEventsList()
                .tabItem { Label("Events", systemImage: "calendar")
                    .foregroundStyle(Color.white) }
            
            // MyInfo Screen
            BPMainPersonalView()
                .tabItem { Label("Info", systemImage: "figure.mind.and.body") }
                
                
            //messenger
            BPMessengerView()
                .tabItem { Label("Messege", systemImage: "message.badge") }
            
            //Settings Screen
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .toolbarBackground(Color.clear, for: .tabBar)
        .tint(Color.accentColor)
        .environmentObject(storage)
        
    }
}

#Preview {
    MainTabView()
        .environmentObject(GlobalStorage())
    
}
