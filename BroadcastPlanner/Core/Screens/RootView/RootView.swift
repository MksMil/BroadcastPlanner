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
    
    @State private var isTextFieldShowed: Bool = false
    
    var body: some View {
        
        ZStack{
            MainBackground()
            ZStack{
            StatusView()
                .offset(y: (isStarted && appState.state == .authorized) ? 0: -200)
                .frame(maxHeight: .infinity,alignment: .top)
            
            NavigationStack(path: $router.path) {
                MainBackground()
                    .navigationDestination(for: RouterPath.self) { path in
                        switch path {
                            case .animatedStart:
                                AnimatedStart()
                            case .broadcastList:
                                BroadcastListView()
                            case .authScreen:
                                AuthenticationScreen()
                            case .sighUp:
                                SignUpView(){
                                    Task{
                                        await sessionManager.signUp()
                                    }
                                }
                            case .ownerInfo:
                                EditMemberInfoView(member: dataManager.fetchOwner())
                            case .settings:
                                SettingsView()
                                // email/pass update
                            case .updateSessionUserData:
                                UpdateSessionUserDataView()
                                
                                //club managment
                            case .clubCollection:
                                ClubCollectionView()
                            case .addEditClub(let club):
                                AddEditClubView(club: club)
                                //venue managmaent
                            case .venueCollection:
                                VenueCollectionView()
                            case .addEditVenue(let venue):
                                AddEditVenueView(venue: venue)
                                //broadcast managment
                            case .createEdit(let broadcast):
                                BroadcastEditView(broadcast: broadcast)
                            case .stadPointsEdit(let broadcast):
                                BroadcastSchemaEditView(broadcast: broadcast)
                                //obvan managment
                            case .obvanCollection:
                                ObvanCollectionView()
                            case .addEditObvan(let obvan):
                                AddEditObvanView(obvan: obvan)
                                //messenger
                            case .messenger:
                                BPMessengerView()
                            default:
                                Text("Hello Error")
                        }
                    }
            }
            .transitionWithOpacity()
            .padding(.vertical,65)
            
            ActionView()
                .padding(.horizontal)
                .frame(height: 60)
                .offset(y: (isStarted && appState.state == .authorized) ? 0: 200)
                .frame(maxHeight: .infinity,alignment: .bottom)
        }
            .padding(.vertical)
    }
        .onAppear(perform: {
            router.routeTo(path: .animatedStart)
        })
        .task{
            if sessionManager.sessionUser == nil{
                await sessionManager.getUserSession()
            }
        }
        .onReceive(sessionManager.$sessionUser) { user in
                if let user{
                    dataManager.setMember(id: user.id)
                    appState.state = .authorized
                    if isStarted{
                        appState.isStartAnimationFinishedPublisher.send(true)
                    }
                } else {
                    dataManager.clearData()
                    appState.state = .notAuthorized
                }
        }
        .onReceive(appState.isStartAnimationFinishedPublisher, perform: { isStart in
            if isStart{
                if appState.state == .authorized{
                    router.routeTo(path: .broadcastList)
                } else {
                    router.routeTo(path: .authScreen)
                }
                withAnimation(.spring(duration: 0.7, bounce: 0.2)){
                    isStarted = true
                }
            }
        })
        .onReceive(appState.$userOnlineStatus) { value in
            guard let id = sessionManager.sessionUser?.id else { return }
            switch value {
            case .online:
                Task {
                    await dataManager.changeOnlineStatus(isOnline: true,id:id)
                }
            case .offline:
                Task {
                    await dataManager.changeOnlineStatus(isOnline: false,id:id)
                }
            }
        }
        .onReceive(router.pathPubisher) { path in
            appState.switchStateByPath(path)
        }
        .onReceive(appState.$isTextFieldShowed) { value in
            withAnimation{
                isTextFieldShowed = value
            }
        }
        .sheet(isPresented: $isTextFieldShowed) {
            TextFieldSheetView(
                source: $appState.textfieldSource,
                promptSource: appState.promptString,
                fieldType: appState.fieldType,
                isSecure: appState.isSecure) {
                    appState.closeTextField()
                } doneAction: { value in
                    appState.doneAction(value)
                    appState.closeTextField()
                }
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Cancel") {
                    appState.closeTextField()
                }
                ForEach(appState.fieldType.toolbarButtons, id: \.self) { symbol in
                    Button(symbol) {
                        print("\(symbol) tapped, appending to source")
                        appState.textfieldSource += symbol
                    }
                }
                Spacer()
                Button("Done") {
                    appState.doneAction(appState.textfieldSource)
                    appState.closeTextField()
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif












