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
                                MainEventsList()
                            case .authScreen:
                                AuthenticationScreen()
                            case .ownerInfo:
                                BPAccountInfoView(user: dataManager.fetchOwner())
                            case .settings:
                                SettingsView()
                                // email/pass update
                            case .updateEmail:
                                UpdateEPView(currentValue: sessionManager.email,
                                             updEP: UpdatedEP.email) {
                                    router.stepBack()
                                } updateAction: { newEmail in
                                    Task{
                                        await sessionManager.updateEmailOrPassword(newValue: newEmail,
                                                                                   type: UpdatedEP.email)
                                    }
                                    router.stepBack()
                                }
                            case .updatePassword:
                                UpdateEPView(currentValue: sessionManager.password,
                                             updEP: UpdatedEP.password) {
                                    router.stepBack()
                                } updateAction: { newPass in
                                    Task{
                                        await sessionManager.updateEmailOrPassword(newValue: newPass,
                                                                                   type: UpdatedEP.password)
                                    }
                                    router.stepBack()
                                }
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
                                BPEditStadiumView(broadcast: broadcast)
                                //messenger
                            case .messenger:
                                BPMessengerView()
                            default:
                                Text("Hello Error")
                        }
                    }
            }
            .padding(.vertical,65)

            //------------Test settings and action controls----
//                HStack {
//                    Button{
//                        status.toggle()
//                        appState.makePrimaryButtonVisible(status)
//                        appState.makeSecondaryButtonVisible(status)
//                        appState.makeBackwardButtonVisible(status)
//                    } label:{
//                        Text("V")
//                    }
//                    Button{
//                        status.toggle()
//                        appState.makePrimaryButtonEnabled(status)
//                        appState.makeSecondaryButtonEnabled(status)
//                        appState.makeBackwardButtonEnabled(status)
//                       
//                    } label:{
//                        Text("A")
//                    }
//                    Button{
//                        appState.setUnreadMessages(num: appState.unreadMessagesPublisher.value + 1)
//                    } label:{
//                        Text("+")
//                    }
//                    Button{
//                        appState.setUnreadMessages(num: appState.unreadMessagesPublisher.value - 1)
//                    } label:{
//                        Text("-")
//                    }
//                    Button{
//                        appState.setIconToPrimaryButton(.edit)
//                    } label:{
//                        Text("Edit")
//                    }
//                    Button{
//                        appState.setIconToPrimaryButton(.accept)
//                    } label:{
//                        Text("CHECK")
//                    }
//                    Button{
////                        appState.addNewNotification(note: StatusViewNotification.random())
//                        appState.setTitle(["Hello","How are you?","Goodbye!","Very very very long title here and we are ready for it!"].randomElement()!)
//                    } label: {
//                        Image(systemName: "plus")
//                    }
//                }
//                .offset(y: isStarted ? 0: 500)

            //-------------------------------------------------
                ActionView()
                .padding(.horizontal)
                .frame(height: 60)
                .offset(y: (isStarted && appState.state == .authorized) ? 0: 200)
                .frame(maxHeight: .infinity,alignment: .bottom)
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
            guard let _ = sessionManager.sessionUser else { return }
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
        .onReceive(router.pathPubisher) { path in
//            print("path received: \(path)")
            appState.switchStateByPath(path)
        }
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












