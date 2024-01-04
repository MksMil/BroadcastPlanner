import SwiftUI

struct MainTabView: View {
    
    var storage: Storage = Storage(cameras: [])
    @State var isLogged: Bool = false
    
    var body: some View {
        
        if isLogged {
            ZStack{
                BackgroundTabItem()
                TabView {
                    
                    MainEventsList()
                        .tabItem { Label("Events", systemImage: "calendar").foregroundStyle(Color.white) }
                    
                    // MyInfo Screen
                    
                    //Settings Screen
                    
                    
                }
                .tint(Color.white)
                
                .environmentObject(storage)
                .task {
                    storage.users = NetworkManager.shared.getUsers()
                    storage.events = NetworkManager.shared.getEvents()
                }
            }
        } else {
            LogScreen(isLogged: $isLogged)
        }
    }
}

#Preview {
    MainTabView()
}
