import SwiftUI
import Firebase
import GoogleSignIn

@main
struct BroadcastPlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var appState: ApplicationState = ApplicationState()
    
    @StateObject private var sessionManager: SessionManager = SessionManager()
    @StateObject private var globalSettings = GlobalSettings()
    @StateObject var router: Router = Router()
    @StateObject var dataManager: DataManager = DataManager(globalDataManager: NetworkManager())
    
    var body: some Scene {
                
        WindowGroup {
            RootView()
                .onAppear{
                    dataManager.networkManager.eventProgressHandler = appState
                    dataManager.networkManager.globalSettingsDelegate = globalSettings
                }
                .onChange(of: scenePhase, perform: { phase in
                    if appState.state == .authorized{
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
                                print("scene in background or inactive state: send offline status")
                                #endif
                                appState.userOnlineStatus = .offline
                            @unknown default:
                                #if DEBUG
                                print("scene in unknown phase: send unknown status")
                                #endif
                        }
                    }
                })
                .environmentObject(sessionManager)
                .environmentObject(globalSettings)
                .environmentObject(appState)
                .environmentObject(router)
                .environmentObject(dataManager)
                .environment(\.managedObjectContext, dataManager.mainContext)
        }
    }
}


// MARK: - AppDelegate, Firebase configuration, GID configuration
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
