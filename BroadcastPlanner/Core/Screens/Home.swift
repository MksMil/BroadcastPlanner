//import SwiftUI
//import NavigationTransitions
//
//struct Home: View {
//    
//    @EnvironmentObject var session: SessionManager
//    @StateObject var mdm: DataManager
//
//    @State private var selection: Int = 0
//    
//    init(globalDataManager: NetworkManager,
//         userId: String) {
//        self._mdm = StateObject(wrappedValue: DataManager(
//                            globalDataManager: globalDataManager,
//                            userId: userId))
//    }
//    
//    var body: some View {
//        ZStack(alignment:.bottom){
//            
//            TabView(selection: $selection) {
//                //broadcast list
//                
//                MainEventsList()
//                    .tabItem { Label("Hello", systemImage: "calendar") }
//                    .tag(0)
//                    .padding(.bottom,1)
//               
//                // MyInfo Screen
//                BPAccountInfoView(user: mdm.currentUserInMainContext)
//                    .tabItem { Label("Info", systemImage: "figure.mind.and.body") }
//                    .tag(1)
//                    .padding(.bottom,1)
//                //messenger
//                BPMessengerView()
//                    .tabItem { Label("Messege", systemImage: "message.badge") }
//                    .tag(2)
//                    .padding(.bottom,1)
//                //Settings Screen
//                SettingsView()
//                    .tabItem { Label("Settings", systemImage: "gear") }
//                    .tag(3)
//                    .padding(.bottom,1)
//                //Test screen
////                NetworkTestView()
////                    .tabItem{ Label("Test",systemImage: "globe") }
////                    .tag(4)
////                    .padding(.bottom,1)
//            }
//        }
//        .navigationBarBackButtonHidden()
//        .environment(\.managedObjectContext, mdm.mainContext)
//        .environmentObject(mdm)
//    }
//}
//
//#Preview {
//    Home(globalDataManager: NetworkManager(),
//         userId: "123")
//        .environmentObject(GlobalSettings())
//        .environmentObject(SessionManager())
//        .environmentObject(ApplicationState())
//}
