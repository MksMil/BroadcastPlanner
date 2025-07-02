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

            //------------
                HStack {
                    Button{
                        status.toggle()
                        router.makeAcceptButtonVisible(status)
                        router.makeRemoveButtonVisible(status)
                    } label:{
                        Text("V")
                    }
                    Button{
                        status.toggle()
                        router.makeAcceptButtonEnabled(status)
                        router.makeRemoveButtonEnabled(status)
                    } label:{
                        Text("A")
                    }
                    Button{
                        router.setUnreadMessages(num: router.unreadMessages + 1)
                    } label:{
                        Text("+")
                    }
                    Button{
                        router.setUnreadMessages(num: router.unreadMessages - 1)
                    } label:{
                        Text("-")
                    }
                }
                
                ActionView(removeAction: {
                    dataManager.globalCancelAction()
                }, acceptAction: {
                    dataManager.globalAcceptAction()
                })
                .padding(.horizontal)
                .frame(height: 70)
                }
        }
//            .border(Color.black, width: 3)
            
//        }
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

#Preview {
    RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
        .environmentObject(Router())
}

struct StatusView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var dataManager: DataManager
    
    @State var image = Image(systemName: "person")
    
    var body: some View {
        HStack{
            Button {
                router.routeStepBack()
            } label: {
                Image(systemName: "chevron.backward.circle")
                    .font(.system(size: 50))
            }
            Spacer()
            Menu {
                Button {
                    router.routeTo(path: .ownerInfo)
                } label: {
                    Label("Info", systemImage: "person")
                }
                Button {
                    router.routeTo(path: .settings)
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
//        .border(.red, width: 1)
    }
    
    func updateImage(){
        if let image = ImagesManager.loadImage(imageSize: .smallImages, id: dataManager.currentId){
            withAnimation{
                self.image = Image(uiImage: image)
            }
        }
    }
}

struct ActionView: View {
    @EnvironmentObject var router: Router
    
    let height: Double = 60
    
    let removeAction:()->()
    let acceptAction:()->()
    
    @State private var isAcceptEnabled: Bool = false
    @State private var isRemoveEnabled: Bool = false
    @State private var isAcceptVisible: Bool = false
    @State private var isRemoveVisible: Bool = false
    @State private var unreadMessages: Int = 999
    
    @State private var isMessengerActive: Bool = false
    
    var body: some View {
        HStack{
            
                Button {
                    removeAction()
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding(height / 4)
                        .frame(height: height)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill( .ultraThinMaterial.opacity(isRemoveEnabled ? 0.5 : 0.3))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.ultraThinMaterial.opacity(isRemoveEnabled ? 0.5: 0.3),
                                                lineWidth: 2)
                                }
                        }
                        .fixedSize()
                }
                .offset(x: isRemoveVisible ? 0:-100)
                .disabled(!isRemoveEnabled)
            
            
            ZStack{
                HStack(spacing: 1){
                    Button{
                        router.makeMessengerActive(false)
                    } label:{
                        Image(systemName: "calendar")
                            .resizable()
                            .scaledToFit()
                        //                        .bold()
                            .padding(height / 6)
                            .padding(.horizontal,height / 6)
                            .frame(height: height)
                            .background {
                                UnevenRoundedRectangle(topLeadingRadius: height / 4,
                                                       bottomLeadingRadius: height / 4, bottomTrailingRadius: 0, topTrailingRadius: 0, style: .circular)
                                .fill(Color.white.opacity(0.3))
                            }
                            .opacity(!isMessengerActive ? 0.5:1)
                    }
                    .disabled(!isMessengerActive)
                    
                    Button{
                        router.makeMessengerActive(true)
                    } label: {
                        Image(systemName: "ellipsis.message")
                            .resizable()
                            .scaledToFit()
                            .padding(height / 6)
                            .padding(.horizontal,height / 6)
                            .frame(height: height)
                            .background{
                                UnevenRoundedRectangle(topLeadingRadius: 0,
                                                       bottomLeadingRadius: 0,
                                                       bottomTrailingRadius: height / 4, topTrailingRadius: height / 4,
                                                       style: .circular)
                                .fill(Color.white.opacity(0.5))
                            }
                    }
                    .opacity(isMessengerActive ? 0.3:1)
                    .overlay{
                        if unreadMessages > 0 {
                            Circle().fill(Color.white)
                                .frame(width: height / 3, height: height / 3)
                                .overlay{
                                    Circle().stroke(Color.black, lineWidth: 2)
                                }
                                .padding(-2)
                                .overlay {
                                    Text(unreadMessages >= 1000 ? "1K":"\(unreadMessages)")
                                        .font(.system(size: 10))
                                        .minimumScaleFactor(0.3)
                                        .lineLimit(1)
                                        .foregroundStyle(Color.black)
                                }
                                .offset(x: height / 4, y: -height / 4)
                                .opacity(isMessengerActive ? 0.4:1)
                        }
                    }
                    .disabled(isMessengerActive)
                }
                .padding(.horizontal)
            }
            .frame(height: height)
            .frame(maxWidth: .infinity,alignment: .center)
            
                Button{
                    acceptAction()
                } label: {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding(height / 4)
                        .frame(height: height)
                    
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill( .ultraThinMaterial.opacity(isAcceptEnabled ? 0.5 : 0.3))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.ultraThinMaterial.opacity(isAcceptEnabled ? 0.5: 0.3),
                                                lineWidth: 2)
                                }
                        }
                        .fixedSize()
                }
                .offset(x: isAcceptVisible ? 0:100)
                .disabled(!isAcceptEnabled)
            
        }
        .onReceive(router.isAcceptButtonEnabledPublisher) { isEnabled in
            withAnimation{
                isAcceptEnabled = isEnabled
            }
        }
        .onReceive(router.isRemoveButtonEnabledPublisher) { isEnabled in
            withAnimation{
                isRemoveEnabled = isEnabled
            }
        }
        .onReceive(router.isAcceptButtonVisiblePublisher) { isVisible in
            withAnimation{
                isAcceptVisible = isVisible
            }
        }
        .onReceive(router.isRemoveButtonVisiblePublisher) { isViible in
            withAnimation{
                isRemoveVisible = isViible
            }
        }
        .onReceive(router.isMessengerActivePublisher) { active in
            withAnimation(.linear(duration: 0.1)){
                isMessengerActive = active
            }
        }
        .onReceive(router.unreadMessagesPublisher) { count in
//            withAnimation{
                unreadMessages = count
//            }
        }
    }
}

