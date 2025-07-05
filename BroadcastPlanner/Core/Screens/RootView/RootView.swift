import Combine
import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var dataManager: DataManager

    @EnvironmentObject var router: Router
    

    @State var isStarted: Bool = false

    @State var status: Bool = false
    
    var body: some View {
        
//#if DEBUG
//        let _ = Self._printChanges()
//#endif
        ZStack{
            MainBackground()
            
            VStack(spacing: 5){
                StatusView()
                    .offset(y: (isStarted && appState.state == .authorized) ? 0: -200)
               
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
                                case .stadPointsEdit(let broadcast):
                                    BPEditStadiumView(broadcast: broadcast)
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
                    Button{
//                        appState.addNewNotification(note: StatusViewNotification.random())
                        appState.setTitle(["Hello","How are you?","Goodbye!","Very very very long title here and we are ready for it!"].randomElement()!)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                .offset(y: isStarted ? 0: 500)

            //-------------------------------------------------
                ActionView()
                .padding(.horizontal)
                .frame(height: 60)
                .offset(y: (isStarted && appState.state == .authorized) ? 0: 200)
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
            } else {
                dataManager.clearData()
                appState.state = .notAuthorized
            }
        }
        .onReceive(appState.startPublisher, perform: { isStart in
            if isStart{
                if appState.state == .authorized{
                    router.routeTo(path: .broadcastList)
                    
                } else {
                    router.routeTo(path: .authScreen)
                }
                withAnimation(.spring(duration: 0.3, bounce: 0.3)){
                    isStarted = true
                }
            }
        })
        .onReceive(appState.$userOnlineStatus) { value in
            guard let id = sessionManager.sessionUser?.id else { return }
            switch value {
            case .online:
                Task {
                    await dataManager.changeOnlineStatus(isOnline: true)
                }
            case .offline:
                Task {
                    await dataManager.changeOnlineStatus(isOnline: false)
                }
            }
        }
        
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
    
    @State var image = Image(systemName: "person")
    
    @State private var isOnline: Bool = false
    
    var body: some View {
        HStack{
            BackwardButton()
                .frame(width: 50, height: 50)
            Spacer()
            /// element with app's status / errors / notifications etc.
            VStack(spacing: 0){
                //status view title here
                TitleView()
                NotificationView()
                   
            }
            .frame(height: 50)
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
                    Circle().stroke(isOnline ? Color.green: Color.red, lineWidth: 2)
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
        
        .onReceive(appState.networkStatusPublisher) { isOnline in
            self.isOnline = isOnline
        }
    }
    
    func updateImage(){
        if let image = ImagesManager.loadImage(imageSize: .smallImages, id: dataManager.currentId){
            withAnimation{
                withAnimation(.easeInOut(duration: 0.7)){
                    self.image = Image(uiImage: image)
                }
            }
        }
    }
}










