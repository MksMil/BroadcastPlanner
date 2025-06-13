import Combine
import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var globalSettings: GlobalSettings

    @StateObject var router: Router = Router()
    let networkManager: NetworkManager
    @StateObject var dataManager: DataManager

    @State var isStarted: Bool = false

    init() {
        let manager = NetworkManager()
        self.networkManager =  manager
        self._dataManager = StateObject(
            wrappedValue: DataManager(globalDataManager: manager)
        )
    }
    var body: some View {
        ZStack(alignment: .top){
            MainBackground()
            if router.statusBarVisibility {
                StatusView()
            }
                
            NavigationStack(path: $router.path) {
                AnimatedStart()
                    .navigationTransition(
                        router.transition,
                        interactivity: router.interactivity
                    )
                    .navigationDestination(for: RouterPath.self) { path in
                        switch path {
                            case .broadcastList:
                                MainEventsList()
                            case .authScreen:
                                AuthenticationScreen()
                            case .locationSheet(let club):
                                LocationSheetView(club: club) {
                                    
                                } saveAction: { venue in
                                    
                                } addEditAction: { venue in
                                    
                                }
                            case .createEdit(let broadcast):
                                BroadcastEditView(broadcast: broadcast)
                            default:
                                Text("Hello Error")
                        }
                    }
            }
            .padding(.top, router.statusBarVisibility ? 70:0)
        }
        .onAppear {
            Task {
                await sessionManager.getUserSession()
            }
        }
        .onReceive(sessionManager.$sessionUser) { user in
            if let user {
                dataManager.setMember(id: user.id)
                appState.state = .authorized
                router.routeTo(path: .broadcastList)
            } else {
                dataManager.clearData()
                appState.state = .notAuthorized
                router.routeTo(path: .authScreen)
            }
        }
        .onReceive(appState.$userOnlineStatus) { value in
            guard let id = sessionManager.sessionUser?.id else { return }
            switch value {
            case .online:
                Task {
                    await networkManager.goOnline(id: id)
                }
            case .offline:
                Task {
                    await networkManager.goOffline(id: id)
                }
            }
        }
        .environmentObject(dataManager)
        .environmentObject(router)
        .environment(\.managedObjectContext, dataManager.mainContext)
    }
}

#Preview {
    RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
}

struct StatusView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var dataManager: DataManager
    
    
    var body: some View {
        HStack{
            Spacer()
            Circle().stroke(Color.green, lineWidth: 2)
                .frame(width: 60,height: 60)
        }
        .padding(.horizontal,8)
        .border(.red, width: 1)
    }
    
}
