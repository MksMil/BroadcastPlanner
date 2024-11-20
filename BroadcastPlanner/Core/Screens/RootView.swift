import SwiftUI
import Combine

struct RootView: View {
//    @EnvironmentObject var globalStorage: GlobalStorage
    @EnvironmentObject var sessionStorage: GlobalSessionStorage
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var globalSettings: GlobalSettings
    
    @State var isStarted: Bool = false
    
    var body: some View {
        ZStack{
            if appState.state == .notAuthorized {
                AuthenticationScreen(){ user in
                    Task{
                        await NetworkManager.shared.createUser(id: user.id, email: user.email)
                    }
                }
            } else {
                Home()
            }
            MainBackground()
                .opacity(isStarted ? 0:1)
            AnimatedStart()
                .opacity(isStarted ? 0:1)
        }
        .environment(\.managedObjectContext, DataManager.shared.moc)
        .onAppear{
                Task{
                    if let sessionUser = await NetworkManager.shared.getCurrentSessionUserInfo(){
                        sessionStorage.userSession = sessionUser
                    }
                    withAnimation(.easeOut(duration: 2).delay(2)) {
                        isStarted.toggle()
                    }
                }
        }
            .onReceive(sessionStorage.$userSession) { session in
                if session != nil {
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
                            await NetworkManager.shared.goOnline(id: id)
                        }
                    case .offline:
                        Task{
                            await NetworkManager.shared.goOffline(id: id)
                        }
                }
            }
    }
}

#Preview {
    RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalSessionStorage())
        .environmentObject(ApplicationState())
}
