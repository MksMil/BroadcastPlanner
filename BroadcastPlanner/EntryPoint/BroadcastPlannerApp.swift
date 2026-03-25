
import SwiftUI


@main
struct BroadcastPlannerApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @Environment(\.scenePhase) var scenePhase

  @StateObject var appState: ApplicationState = ApplicationState()
  @StateObject private var sessionManager: SessionManager = SessionManager()
  @StateObject private var globalSettings = GlobalSettings()
  @StateObject var router: Router = Router()
  @StateObject var dataCoordinator: DataCoordinator =
    DataCoordinator()

  var body: some Scene {

    WindowGroup {
      RootView()
        .onAppear {
          appState.setRouter(router: router)
          delegate.notificationHandler = appState
          dataCoordinator
            .configure(
              appState: appState,
              globalSettings: globalSettings,
              notificationHandler: appState
            )
        }
        .onChangeCompat(
          of: scenePhase,
          perform: { phase in
            if !dataCoordinator.dataManager.currentId.isEmpty {
              switch phase {
              case .active:
                //send online status
                #if DEBUG
                  print("scene in foreground: send online status")
                #endif
                  Task{
                    await dataCoordinator.dataManager.setOnlineStatus(isOnline: true)
                  }
                case .background, .inactive:
                //send offline status
                #if DEBUG
                  print(
                    "scene in background or inactive state: send offline status"
                  )
                #endif
                  Task{
                    await dataCoordinator.dataManager.setOnlineStatus(isOnline: false)
                  }
              @unknown default:
                #if DEBUG
                  print("scene in unknown phase: send unknown status")
                #endif
              }
            }
          }
        )
        .environmentObject(sessionManager)
        .environmentObject(globalSettings)
        .environmentObject(appState)
        .environmentObject(router)
        .environmentObject(dataCoordinator.dataManager)
        .environment(
          \.managedObjectContext,
           dataCoordinator.dataManager.mainContext
        )
    }
  }
}

