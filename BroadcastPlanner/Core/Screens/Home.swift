import SwiftUI
import NavigationTransitions

struct Home: View {
    
    @EnvironmentObject var session: SessionManager
    @StateObject var mdm: MainDataManager

    @State private var selection: Int = 4
    
    init(localDataManager: DataManager,
         globalDataManager: NetworkManager,
         userId: String) {
        self._mdm = StateObject(wrappedValue: MainDataManager(localDataManager: localDataManager,
                            globalDataManager: globalDataManager,
                            userId: userId))
    }
    
    var body: some View {
        ZStack(alignment:.bottom){
            
            TabView(selection: $selection) {
                //event list
                
                MainEventsList()
                    .tabItem { Label("Hello", systemImage: "calendar") }
                    .tag(0)
                    .padding(.bottom,1)
                    

                // MyInfo Screen
                BPAccountInfoView(user: mdm.currentUser)
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
                //Test screen
                NetworkTestView()
                    .tabItem{ Label("Test",systemImage: "globe") }
                    .tag(4)
                    .padding(.bottom,1)
            }
        }
        .navigationBarBackButtonHidden()
        .environment(\.managedObjectContext, mdm.localDataManager.mainContext)
        .environmentObject(mdm)
    }
}

#Preview {
    Home(localDataManager: DataManager(),
         globalDataManager: NetworkManager(),
         userId: "123")
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
}
