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
        ZStack{
            MainBackground()

            VStack(spacing: 5){
                    StatusView()
                    .frame(height: router.statusBarVisibility ? 70:0)
                    .opacity(router.statusBarVisibility ? 1:0)
                    .animation(.easeIn(duration: 0.3), value: router.statusBarVisibility)
                    .transition(.push(from: .top))
                    
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
                                        .navigationTransition(router.transition,
                                                              interactivity: router.interactivity)
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
                .animation(.easeIn(duration: 0.3), value: router.statusBarVisibility)
                .animation(.easeIn(duration: 0.3), value: router.actionBarVisibility)
                
                    ActionView(cancellAction: {
                        dataManager.globalCancelAction()
                    }, acceptAcion: {
                        dataManager.globalAcceptAction()
                    })
                    .frame(height: router.actionBarVisibility ? 70:0)
                    .opacity(router.actionBarVisibility ? 1:0)
                    .animation(.easeIn(duration: 0.3), value: router.actionBarVisibility)
            }
            
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
    
    let image = Image(systemName: "person")
    
    var body: some View {
        HStack{
            Spacer()
            Menu {
                Button {
                    print("personal page")
                } label: {
                    Label("Info", systemImage: "person")
                }
                Button {
                    print("personal page")
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                Button {
                    print("personal page")
                } label: {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                }

            } label: {
            image
                .resizable()
                .frame(width: 40, height: 40)
                .padding(8)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(.white, lineWidth: 2)
                }
                .padding(4)
            }
                            
        }
        .padding(.horizontal,8)
//        .border(.red, width: 1)
    }
}

struct ActionView: View {
    
    let cancellAction:()->()
    let acceptAcion:()->()
    
    var body: some View {
        HStack{
            Button {
                cancellAction()
            } label: {
                Text("cancel")
            }
            Spacer()
            Button {
               acceptAcion()
            } label: {
                Text("accept")
            }
        }
        .padding(.horizontal,8)
        .border(.red, width: 1)
    }
}
