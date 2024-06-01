import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject var globalStorage: GlobalStorage

    @State var selection: Int = 0
    
    
    var body: some View {
        
        TabView(selection: $selection) {
            MainEventsList()
                .tabItem { Label("Events", systemImage: "calendar")}
                .tag(0)
                .padding(.bottom,1)
            
            // MyInfo Screen
            BPAccountInfoView(globalStorage: globalStorage)
                .tabItem { Label("Info", systemImage: "figure.mind.and.body") }
                .tag(1)
                .padding(.bottom,1)
            //messenger
            BPMessengerView()
                .tabItem { Label("Messege", systemImage: "message.badge") }
                .tag(2)
                .padding(.bottom,1)
            //Settings Screen
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(3)
                .padding(.bottom,1)
                
        }
        .tint(Color.black)
        .environmentObject(globalStorage)
        
    }
}

#Preview {
    MainTabView()
        .environmentObject(GlobalStorage())
    
}
