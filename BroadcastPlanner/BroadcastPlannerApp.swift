import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn

enum AppState {
    case authorized, notAuthorized
}

enum UserOnlineStatus {
    case online, offline
}

class ApplicationState: ObservableObject{
    @Published var state: AppState = .notAuthorized
    @Published var userOnlineStatus: UserOnlineStatus = .offline
}

// MARK: - Main App
@main
struct BroadcastPlannerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var appState: ApplicationState = ApplicationState()
    
    @StateObject private var sessionManager: SessionManager = SessionManager()
    @StateObject private var globalSettings = GlobalSettings()
    
    var body: some Scene {
                
        WindowGroup {
            RootView()
                .onChange(of: scenePhase, perform: { phase in
                    if appState.state == .authorized{
                        switch phase {
                            case .active:
                                //send online status
                                print("scene in foreground: send online status")
                                appState.userOnlineStatus = .online
                            case .background, .inactive:
                                //send offline status
                                //save local cache: images + data( events, users, messages)
                                print("scene in background or inactive state: send offline status")
                                appState.userOnlineStatus = .offline
                            @unknown default:
                                print("scene in unknown phase: send unknown status")
                        }
                    }
                })
                .environmentObject(sessionManager)
                .environmentObject(globalSettings)
                .environmentObject(appState)
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
