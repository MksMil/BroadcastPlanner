import Combine
import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var globalSettings: GlobalSettings

    @EnvironmentObject var router: Router 
    
    let networkManager: NetworkManager
    @StateObject var dataManager: DataManager

    @State var isStarted: Bool = false

    @State var status: Bool = false
    
    
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
                    .frame(height: 70)
               
                NavigationStack(path: $router.path) {
                    AnimatedStart()
                        .navigationDestination(for: RouterPath.self) { path in
                            switch path {
                                case .broadcastList:
                                    MainEventsList()
                                case .authScreen:
                                    AuthenticationScreen()
                                case .ownerInfo:
                                    BPAccountInfoView(user: dataManager.fetchOwner())
                                case .settings:
                                    SettingsView()
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
                .navigationTransition(router.transition,
                                      interactivity: router.interactivity)

            //------------Test settings and action controls----
                HStack {
                    Button{
                        status.toggle()
                        appState.makePrimaryButtonVisible(status)
                        appState.makeSecondaryButtonVisible(status)
                        appState.makeBackwardButtonVisible(status)
                    } label:{
                        Text("V")
                    }
                    Button{
                        status.toggle()
                        appState.makePrimaryButtonEnabled(status)
                        appState.makeSecondaryButtonEnabled(status)
                        appState.makeBackwardButtonEnabled(status)
                       
                    } label:{
                        Text("A")
                    }
                    Button{
                        appState.setUnreadMessages(num: appState.unreadMessages + 1)
                    } label:{
                        Text("+")
                    }
                    Button{
                        appState.setUnreadMessages(num: appState.unreadMessages - 1)
                    } label:{
                        Text("-")
                    }
                    Button{
                        appState.setIconToPrimaryButton(.edit)
                    } label:{
                        Text("Edit")
                    }
                    Button{
                        appState.setIconToPrimaryButton(.accept)
                    } label:{
                        Text("CHECK")
                    }
                }
            //-------------------------------------------------
                ActionView()
                .padding(.horizontal)
                .frame(height: 60)
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
        .environment(\.managedObjectContext, dataManager.mainContext)
    }
}

#if DEBUG
#Preview {
    RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
        .environmentObject(Router())
}
#endif

struct StatusView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appState: ApplicationState
    
    @State private var statusText: String = "Status Here"
    
    @State private var isBackwardEnabled: Bool = false
    @State private var isBackwardVisible: Bool = false
    
    @State var image = Image(systemName: "person")
    
    var body: some View {
        HStack{
            BackwardButton()
            Spacer()
            /// element with app's status / errors / notifications etc.
            Text(statusText)
            ///
            Spacer()
            Menu {
                //Owner Info
                Button {
                    if appState.menuState == .settings{
                        router.routeFrom(from: .settings,
                                         to: .ownerInfo)
                    } else {
                        router.routeTo(path: .ownerInfo)
                    }
                    appState.setMenuState(state: .info)
                    appState.setAppUIState(isBackwardEnabled: true,
                                           isBackwardVisible: true,
                                           isPrimaryEnabled: true,
                                           isPrimaryVisible: true,
                                           primaryIcon: .edit,
                                           isSecondaryEnabled: false,
                                           isSecondaryVisible: false,
                                           secondaryIcon: .cancel)
                } label: {
                    Label("Info", systemImage: "person")
                }
                .disabled(appState.menuState == .info)
                //Settings
                Button {
                    if appState.menuState == .info{
                        router.routeFrom(from: .ownerInfo,
                                         to: .settings)
                    } else {
                        router.routeTo(path: .settings)
                    }
                    appState.setMenuState(state: .settings)
                    appState.setAppUIState(isBackwardEnabled: true,
                                           isBackwardVisible: true,
                                           isPrimaryEnabled: false,
                                           isPrimaryVisible: false,
                                           primaryIcon: .accept,
                                           isSecondaryEnabled: false,
                                           isSecondaryVisible: false,
                                           secondaryIcon: .cancel)
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .disabled(appState.menuState == .settings)
                //LogOut
                Button {
                    print("log out")
                } label: {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                }

            } label: {
            image
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(.white, lineWidth: 2)
                }
            }

                            
        }
        .padding(.horizontal)
        .task{
            updateImage()
        }
        
        .onReceive(dataManager.updatePublisher) { value in
            if value.0 == .images, value.1.contains(dataManager.currentId){
                updateImage()
            }
        }
    }
    
    func updateImage(){
        if let image = ImagesManager.loadImage(imageSize: .smallImages, id: dataManager.currentId){
            withAnimation{
                self.image = Image(uiImage: image)
            }
        }
    }
}










