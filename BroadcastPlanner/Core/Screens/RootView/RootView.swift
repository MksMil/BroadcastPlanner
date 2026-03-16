import SwiftUI

// MARK: - RootView
// Единая точка входа. Переключает между тремя состояниями через ZStack + transition.
// Никакого NavigationStack на этом уровне — каждое состояние управляет навигацией само.

struct RootView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var router: Router
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ZStack {
            switch router.appScreen {
            case .splash:
                AnimatedStart()
                    .transition(.opacity)
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
                .transition(.opacity)

            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: router.appScreen)
        // Глобальный sheet для меню — доступен из любого таба
        .sheet(isPresented: $router.isMenuPresented) {
            MenuSheetView()
        }
        // Реакция на изменение sessionUser (логаут / удаление аккаунта)
        .onReceive(sessionManager.$sessionUser){ user in
          guard router.appScreen != .splash else { return }
          if user == nil {
              withAnimation { router.showAuth() }
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
            if sessionManager.sessionUser != nil {
                router.showMain()
              Task{
                await dataManager.setMember(id: sessionManager.sessionUser!.id)
              }
            } else {
                router.showAuth()
            }
        }
    }
}



// MARK: - Preview

#if DEBUG
#Preview {
//  do{
    let dm = DataManager.preview(networkManager: NetworkManager())
    let appState = ApplicationState()
    return RootView()
      .environmentObject(SessionManager())
      .environmentObject(Router())
      .environmentObject(appState)
      .environmentObject(dm)
      .environment(\.managedObjectContext, dm.mainContext)
//  } catch {
//    print("error")
//  }
}
#endif
