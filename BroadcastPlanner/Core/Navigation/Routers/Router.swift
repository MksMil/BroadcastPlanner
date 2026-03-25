import SwiftUI

// MARK: - AppScreen

// Три верхнеуровневых состояния приложения.
// RootView переключает между ними — никакого NavigationStack на этом уровне.

enum AppScreen {
  case splash
  case auth
  case main
}

enum AppTab: Hashable {
  case broadcasts
  case messenger
}

// MARK: - AuthPath
// Destinations внутри auth-флоу (живёт здесь, используется в RootView).

enum AuthPath: Hashable {
  case signUp
}

// MARK: - BroadcastPath
// Destinations для таба Broadcasts.

enum BroadcastPath: Hashable {
  case broadcastList
  case createEdit(broadcast: Broadcast, isNew: Bool)
  case stadPointsEdit(broadcast: Broadcast)
  case clubCollection
  case addEditClub(club: Club)
  case venueCollection
  case addEditVenue(venue: Venue)
  case obvanCollection
  case addEditObvan(obvan: Obvan)
  case ownerInfo
  case settings
//  case updateSessionUserData
}

// MARK: - MessengerPath
// Destinations для таба Messenger.

enum MessengerPath: Hashable {
  case messenger
  // расширяется по мере появления новых экранов в чат-флоу
}

// MARK: - Router

@MainActor
final class Router: ObservableObject {

  // MARK: App-level state
  @Published var appScreen: AppScreen = .splash

  // MARK: Tab selection
  @Published var selectedTab: AppTab = .broadcasts{
    didSet{
      canMoveBack(tab: selectedTab)
    }
  }

  // MARK: Per-tab navigation stacks
  @Published var broadcastPath: [BroadcastPath] = []{
    didSet{
      canMoveBack(tab: .broadcasts)
          }
  }
  @Published var messengerPath: [MessengerPath] = [] {
    didSet{
      canMoveBack(tab: .messenger)
    }
  }
  func canMoveBack(tab: AppTab){
    if selectedTab == .broadcasts{
      self.canMoveBack = !(broadcastPath.count < 1)
    }
    if selectedTab == .messenger{
      self.canMoveBack = !(messengerPath.count < 1)
    }

  }
  // MARK: Auth stack (для перехода SignIn → SignUp)
  @Published var authPath: [AuthPath] = []

  // MARK: Menu sheet
  @Published var isMenuPresented: Bool = false
  @Published var isUserInfoPresent: Bool = false
  
  @Published var canMoveBack: Bool = false
  

  // MARK: - Helpers
  
  
  func showMain() {
    appScreen = .main
  }

  func showAuth() {
    appScreen = .auth
    // Сбрасываем все стеки при выходе — чтобы при следующем входе стартовать чисто
    authPath = []
    broadcastPath = []
    messengerPath = []
  }
  func showUserInfo() {
    isUserInfoPresent = true
  }
  func showSettings(){
    isMenuPresented = true
  }
  // Универсальный pop — работает для активного флоу
  func stepBack() {
    switch appScreen {
    case .auth:
      if !authPath.isEmpty { authPath.removeLast() }
    case .main:
      switch selectedTab {
      case .broadcasts:
        if !broadcastPath.isEmpty { broadcastPath.removeLast() }
      case .messenger:
        if !messengerPath.isEmpty { messengerPath.removeLast() }
      }
    case .splash:
      break
    }
  }

  func showSplash() {
    appScreen = .splash
  }
}

// MARK: - AppTab



// MARK: - BroadcastListRouting Protocol
@MainActor
protocol BroadcastListRouting: AnyObject {
  func openBroadcast(_ broadcast: Broadcast)
  func openNewBroadcast(_ broadcast: Broadcast)
  func openEditPoints(_ broadcast: Broadcast)
}

extension Router: BroadcastListRouting {
  func openBroadcast(_ broadcast: Broadcast) {
    broadcastPath.append(.createEdit(broadcast: broadcast,isNew: false))
  }
  func openNewBroadcast(_ broadcast: Broadcast) {
    broadcastPath.append(.createEdit(broadcast: broadcast,isNew: true))
  }
  func openEditPoints(_ broadcast: Broadcast){
    broadcastPath.append(.stadPointsEdit(broadcast: broadcast))
  }
}
