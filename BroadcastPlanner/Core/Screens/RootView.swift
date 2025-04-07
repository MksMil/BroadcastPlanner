import Combine
import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var globalSettings: GlobalSettings
    
    @StateObject var localDataManager = DataManager()
    @StateObject var globalDataManager = NetworkManager()

    @State var isStarted: Bool = false
    var body: some View {
            ZStack {
                if appState.state == .authorized,
                   let id = sessionManager.sessionUser?.id {
                    Home(localDataManager: localDataManager,
                         globalDataManager: globalDataManager,
                         userId: id)
                    .environmentObject(appState)
                    .environmentObject(globalSettings)
                    .environmentObject(sessionManager)
                            } else {
                                AuthenticationScreen()
                            }
                MainBackground()
                    .opacity(isStarted ? 0 : 1)
                AnimatedStart()
                    .opacity(isStarted ? 0 : 1)
                    .scaleEffect(isStarted ? 0 : 1)
            }
        .onAppear {
            Task {
                await sessionManager.getUserSession()
                withAnimation(.easeOut(duration: 0.3).delay(2)) {
                    isStarted.toggle()
                }
            }
        }
        .onReceive(sessionManager.$sessionUser) { user in
            if user != nil {
                appState.state = .authorized
            } else {
                appState.state = .notAuthorized
            }
        }
        .onReceive(appState.$userOnlineStatus) { value in
            guard let id = sessionManager.sessionUser?.id else { return }
            switch value {
            case .online:
                Task {
                    await globalDataManager.goOnline(id: id)
                }
            case .offline:
                Task {
                    await globalDataManager.goOffline(id: id)
                }
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
}
