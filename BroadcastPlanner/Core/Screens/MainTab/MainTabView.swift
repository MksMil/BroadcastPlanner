import SwiftUI

// MARK: - MainTabView
// Два независимых NavigationStack внутри TabView.
// Каждый таб держит свой path — переключение не сбрасывает историю соседнего.

struct MainTabView: View {
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
      ZStack{
        VStack(spacing: 0){
          StatusView()
          TabView(selection: $router.selectedTab) {
            
            // MARK: - Broadcasts tab
            NavigationStack(path: $router.broadcastPath) {
              BroadcastListView(
                viewModel: BroadcastListViewModel(
                  broadcastRepository: dataManager.broadcasts,
                  memberRepository: dataManager.members,
                  router: router
                )
              )
              .navigationDestination(for: BroadcastPath.self) { path in
                broadcastDestination(path)
              }
            }
            .tabItem {
              Label("Broadcasts", systemImage: "antenna.radiowaves.left.and.right")
            }
            .tag(AppTab.broadcasts)
            
            // MARK: - Messenger tab
            NavigationStack(path: $router.messengerPath) {
              BPMessengerView()
                .navigationDestination(for: MessengerPath.self) { path in
                  messengerDestination(path)
                }
            }
            .tabItem {
              Label("Messenger", systemImage: "message")
            }
            .tag(AppTab.messenger)
          }
        }
      }
      .onReceive(appState.$userOnlineStatus, perform: { isOnline in
        
      })
        // Кнопка профиля — toolbar, видна в обоих табах через NavigationStack
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
              
                Button {
                    router.isMenuPresented = true
                } label: {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            }
        }
    }

    // MARK: - Broadcast destinations

    @ViewBuilder
    private func broadcastDestination(_ path: BroadcastPath) -> some View {
        switch path {
        case .broadcastList:
            BroadcastListView(
              viewModel: BroadcastListViewModel(
                broadcastRepository: dataManager.broadcasts,
                memberRepository: dataManager.members,
                router: router))
        case .createEdit(let broadcast):
            BroadcastEditView(broadcast: broadcast,
                              dataManager: dataManager,
                              router: router)
        case .stadPointsEdit(let broadcast):
            BroadcastSchemaEditView(broadcast: broadcast)
        case .clubCollection:
            ClubCollectionView()
        case .addEditClub(let club):
            AddEditClubView(club: club)
        case .venueCollection:
            VenueCollectionView()
        case .addEditVenue(let venue):
            AddEditVenueView(venue: venue)
        case .obvanCollection:
            ObvanCollectionView()
        case .addEditObvan(let obvan):
            AddEditObvanView(obvan: obvan)
        case .ownerInfo:
            EditMemberInfoView()//member: dataManager.fetchOwner())
        case .settings:
            SettingsView()
//        case .updateSessionUserData:
//            UpdateSessionUserDataView()
        }
    }

    // MARK: - Messenger destinations

    @ViewBuilder
    private func messengerDestination(_ path: MessengerPath) -> some View {
        switch path {
        case .messenger:
            BPMessengerView()
        }
    }
}

// MARK: - MenuSheetView
// Собственный NavigationStack — полностью независим от табов.
// При dismiss стек сбрасывается автоматически (sheet пересоздаётся при следующем открытии).

struct MenuSheetView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var router: Router

    var body: some View {
        NavigationStack {
            SettingsView()
                .navigationTitle("Меню")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Закрыть") {
                            router.isMenuPresented = false
                        }
                    }
                }
        }
    }
}
