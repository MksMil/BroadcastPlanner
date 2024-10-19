import SwiftUI
import NavigationTransitions

struct Home: View {
    
    @StateObject var globalStorage: GlobalStorage
    @State private var selection: Int = 1
   
    var body: some View {
        ZStack(alignment:.bottom){
            
            TabView(selection: $selection) {
                MainEventsList()
                    .tabItem { Label("Events", systemImage: "calendar")}
                    .tag(0)
                    .padding(.bottom,1)
                    .transition(.opacity)
                
                // MyInfo Screen
                BPAccountInfoView()
                    .tabItem { Label("Info", systemImage: "figure.mind.and.body") }
                    .tag(1)
                    .padding(.bottom,1)
                    .transition(.opacity)
                //messenger
                BPMessengerView()
                    .tabItem { Label("Messege", systemImage: "message.badge") }
                    .tag(2)
                    .padding(.bottom,1)
                    .transition(.opacity)
                //Settings Screen
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gear") }
                    .tag(3)
                    .padding(.bottom,1)
                    .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden()
        .environmentObject(globalStorage)
    }
}

#Preview {
    
    
    Home(globalStorage: GlobalStorage(localUser: LocalUser(context: DataManager.preview.moc),networkManager: NetworkManager()))
        .environmentObject(GlobalTimer())
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalSessionStorage())
}
