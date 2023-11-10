import SwiftUI

struct MainTabView: View {
    
    var storage: Storage = Storage(cameras: [])
//    @StateObject var motionManager = MotionManager()
    
    var body: some View {
        ZStack{
            BackgroundTabItem()
            TabView {
                
                MainEventsList(/*motionManager: motionManager*/)
                    .tabItem { Label("Events", systemImage: "calendar").foregroundStyle(Color.white) }
                
                StaffTabItamView()
                    .tabItem { Label("Staff", systemImage: "person.3.fill") }
//                            EventMainView(motionManager: motionManager)
//                                .tabItem { Label("Cameras", systemImage: "video") }
                
                AddUserView(/*motionManager: motionManager*/)
                    .tabItem { Label("Users", systemImage: "person.crop.circle") }
                
            }
            .tint(Color.white)
            
            // TODO:  background animation
            //        .onAppear{
            //            motionManager.startMonitoringMotionUpdates()
            //        }
            .environmentObject(storage)
            .task {
                storage.users = NetworkManager.shared.getUsers()
                storage.events = NetworkManager.shared.getEvents()
            }
        }
    }
}

#Preview {
    MainTabView()
}
