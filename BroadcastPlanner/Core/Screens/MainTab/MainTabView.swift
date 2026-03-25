import SwiftUI
// 49 — стандартная высота UITabBar в iOS (константа Apple).


// MARK: - MainTabView
struct MainTabView: View {
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var dataManager: DataManager

  var body: some View {
    
      ZStack(alignment: .bottom) {
        MainBackground()
          .ignoresSafeArea()
        VStack(spacing: 0) {
          StatusView()
          
          TabView(selection: $router.selectedTab) {
            
            NavigationStack(path: $router.broadcastPath) {
              BroadcastListView(
                viewModel: BroadcastListViewModel(
                  broadcastRepository: dataManager.broadcasts,
                  memberRepository: dataManager.members,
                  router: router
                )
              )
              .navigationDestination(for: BroadcastPath.self) {
                broadcastDestination($0)
              }
            }
            .tag(AppTab.broadcasts)
            
            NavigationStack(path: $router.messengerPath) {
              BPMessengerView()
                .navigationDestination(for: MessengerPath.self) {
                  messengerDestination($0)
                }
            }
            .tag(AppTab.messenger)
          }
          .toolbar(.hidden, for: .tabBar) // скрываем стандартный
        }
        .padding(.bottom, 17)
        // Кастомный таббар поверх контента
        customTabBar
      }
      
    
  }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabBarButton(
                tab: .broadcasts,
                icon: "sportscourt",
                label: "Broadcasts"
            )

            Divider()
                .frame(height: 24)
                .overlay(Color.white.opacity(0.4))

            tabBarButton(
                tab: .messenger,
                icon: "message",
                label: "Messenger"
            )
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func tabBarButton(tab: AppTab, icon: String, label: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                router.selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: router.selectedTab == tab ? "\(icon).fill" : icon)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(router.selectedTab == tab ? .primary : .secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        case .createEdit(let broadcast, let isNew):
            BroadcastEditView(broadcast: broadcast,
                              isNew: isNew,
                              dataManager: dataManager,
                              router: router)
        case .stadPointsEdit(let broadcast):
            BluePrintEditView(broadcast: broadcast,dataManager: dataManager,router: router)
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
