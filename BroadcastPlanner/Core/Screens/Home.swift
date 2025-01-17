import SwiftUI
import NavigationTransitions

struct Home: View {
    
    @EnvironmentObject var session: SessionManager
    @State private var selection: Int = 1
    @StateObject var mdm: MainDataManager
    
    init(localDataManager: DataManager, globalDataManager: NetworkManager,userId: String?) {
        self._mdm = StateObject(wrappedValue: MainDataManager(localDataManager: localDataManager, globalDataManager: globalDataManager,userId: userId))
    }
    
    var body: some View {
        ZStack(alignment:.bottom){
            
            TabView(selection: $selection) {
                MainEventsList()
                    .tabItem { Label("Events", systemImage: "calendar")}
                    .tag(0)
                    .padding(.bottom,1)
                    .transition(.opacity)
//                
//                // MyInfo Screen
                BPAccountInfoView(id: session.sessionUser?.id ?? "")
                    .tabItem { Label("Info", systemImage: "figure.mind.and.body") }
                    .tag(1)
                    .padding(.bottom,1)
                    .transition(.opacity)
//                //messenger
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
        .environment(\.managedObjectContext, mdm.localDataManager.moc)
        .environmentObject(mdm)
    }
}

#Preview {
    Home(localDataManager: DataManager(),
         globalDataManager: NetworkManager(), userId: "123")
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
}
