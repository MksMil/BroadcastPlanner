import SwiftUI

// MARK: - RootView
// Единая точка входа. Переключает между тремя состояниями через ZStack + transition.
// Никакого NavigationStack на этом уровне — каждое состояние управляет навигацией само.

struct RootView: View {
  @EnvironmentObject var sessionManager: SessionManager
  @EnvironmentObject var router: Router
  @EnvironmentObject var dataManager: DataManager
  @EnvironmentObject var appState: ApplicationState

  var body: some View {
    ZStack {
      switch router.appScreen {
      case .splash:
        AnimatedStart()
          .task { await handleSplash() }

      case .auth:
        NavigationStack(path: $router.authPath) {
          AuthenticationScreen()
            .navigationDestination(for: AuthPath.self) { path in
              switch path {
              case .signUp: SignUpView()
              }
            }
        }

      case .main:
        MainTabView()
      }
    }
    .ignoresSafeArea(.keyboard)
    .animation(.easeInOut(duration: 0.35), value: router.appScreen)
    // Глобальный sheet для меню — доступен из любого таба
    .sheet(isPresented: $router.isMenuPresented) {
      MenuSheetView()
    }
    .sheet(isPresented: $router.isUserInfoPresent) {
      EditMemberInfoView()
    }
    .onAppear {
      do{
        try dataManager.startNetwork()
        
      } catch{
        print(error)
      }
    }
    // Реакция на изменение sessionUser (логаут / удаление аккаунта)
    .onReceive(sessionManager.$sessionUser) { user in
      guard router.appScreen != .splash else { return }
      if user == nil {
        Task{
          await dataManager.setOnlineStatus(isOnline: false)

        }
        withAnimation {
          router.showAuth()
        }
      }
      if router.appScreen == .auth, let user = user {
        goMain(user: user)
      }
    }
    
  }
    


  // MARK: - Splash logic
  // Минимум 1.5с сплэша + параллельная проверка сессии.
  // Переходим только когда оба завершены.

  private func handleSplash() async {
    async let minDelay: () = Task.sleep(nanoseconds: 1_500_000_000)
    async let session: () = sessionManager.restoreSession()
    _ = try? await (minDelay, session)

    withAnimation {
      if let user = sessionManager.sessionUser {
        goMain(user: user)
      } else {
        router.showAuth()
      }
    }
  }
  
  func goMain(user: SessionUser){
    
    router.showMain()
    Task {
      let dto = await dataManager.members.setMember(id: user.id)
      if let dto {
        appState.user = dto
        appState.setTitle(.base)
      }
      await dataManager.setOnlineStatus(isOnline: true)
    }
  }
}

// MARK: - Preview

#if DEBUG
  #Preview {
    
    let dm = DataManager.preview(networkManager: NetworkManager())
    return RootView()
      .environmentObject(SessionManager())
      .environmentObject(dm)
      .environment(\.managedObjectContext, dm.mainContext)
  }
#endif
