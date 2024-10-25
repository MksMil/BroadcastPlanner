import SwiftUI
import Combine

struct RootView: View {
    
    @EnvironmentObject var sessionStorage: GlobalSessionStorage
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var timer: GlobalTimer
    
    @StateObject var dataManager = DataManager.shared
    @StateObject var networkManager = NetworkManager()
    
    @State var isStarted: Bool = false
    
    var body: some View {
        ZStack{
            if appState.state == .notAuthorized {
                AuthenticationScreen(){ user in
                    Task{
                        await networkManager.createUser(id: user.id, email: user.email)
                    }
                }
            } else {
                Home(globalStorage: GlobalStorage(localUser: dataManager.fetchOrCreateUserWithId(sessionStorage.userSession?.id ?? UUID().uuidString),networkManager: networkManager))
            }
            MainBackground()
                .opacity(isStarted ? 0:1)
            AnimatedStart()
                .opacity(isStarted ? 0:1)
        }
        .environment(\.managedObjectContext, dataManager.moc)
        .onAppear{
                Task{
                    if let sessionUser = await networkManager.getCurrentSessionUserInfo(){
                        sessionStorage.userSession = sessionUser
                    }
                    withAnimation(.easeOut(duration: 2).delay(2)) {
                        isStarted.toggle()
                    }
                }
        }
            .onReceive(sessionStorage.$userSession) { session in
                if let _ = session {
                    appState.state = .authorized
                } else {
                    appState.state = .notAuthorized
                }
            }
            .onReceive(appState.$userOnlineStatus) { value in
                guard let id = sessionStorage.userSession?.id else { return }
                switch value{
                    case .online:
                        Task{
                            await networkManager.goOnline(id: id)
                        }
                    case .offline:
                        Task{
                            await networkManager.goOffline(id: id)
                        }
                }
            }
    }
}

#Preview {
    RootView()
        .environmentObject(GlobalTimer())
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalSessionStorage())
        .environmentObject(ApplicationState())
}
