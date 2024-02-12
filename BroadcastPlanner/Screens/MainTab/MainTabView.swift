import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    
    var storage: Storage = Storage(cameras: [])
    @Binding var isLogged: Bool
    
    var body: some View {
        
            ZStack{
                BackgroundTabItem()
                TabView {
                    
                    MainEventsList()
                        .tabItem { Label("Events", systemImage: "calendar")
                            .foregroundStyle(Color.white) }
                    
                    // MyInfo Screen
                    
                    //Settings Screen
                    SettingsView(isLogged: $isLogged)
                        .tabItem { Label("Settings", systemImage: "gear") }
                }
                .tint(Color.white)
                .environmentObject(storage)
            }
        
    }
}

#Preview {
    MainTabView(isLogged: .constant(true))
}
