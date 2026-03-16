import Firebase
import GoogleSignIn
import SwiftUI
import UserNotifications

@main
struct BroadcastPlannerApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @Environment(\.scenePhase) var scenePhase

  @StateObject var appState: ApplicationState = ApplicationState()

  @StateObject private var sessionManager: SessionManager = SessionManager()
  @StateObject private var globalSettings = GlobalSettings()
  @StateObject var router: Router = Router()
  @StateObject var dataSourceContainer: DataSourceContainer =
    DataSourceContainer()

  var body: some Scene {

    WindowGroup {
      RootView()
        .onAppear {
          delegate.notificationHandler = appState
          dataSourceContainer
            .configure(
              appState: appState,
              globalSettings: globalSettings,
              notificationHandler: appState
            )
        }
        .onChange(
          of: scenePhase,
          perform: { phase in
            if appState.state == .authorized {
              switch phase {
              case .active:
                //send online status
                #if DEBUG
                  print("scene in foreground: send online status")
                #endif
                appState.userOnlineStatus = .online
              case .background, .inactive:
                //send offline status
                #if DEBUG
                  print(
                    "scene in background or inactive state: send offline status"
                  )
                #endif
                appState.userOnlineStatus = .offline
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
        .environmentObject(dataSourceContainer.dataManager)
        .environment(
          \.managedObjectContext,
          dataSourceContainer.dataManager.mainContext
        )
    }
  }
}

