import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn
import NavigationTransitions


// MARK: - Main App
@main
struct BroadcastPlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var globalTimer = GlobalTimer()
    @StateObject private var globalStorage = GlobalStorage()
    @StateObject private var globalSettings = GlobalSettings()
    
    @State var isStarted: Bool = false
    
    var body: some Scene {
        
        // TODO: First Time Loading problem need to debug
        
        WindowGroup {
                ZStack{
                    MainBackground()
                    if !isStarted {
                        AnimatedStart(isStarted: $isStarted)
                            .transition(.opacity)
                    } else {
                        if globalStorage.isLogged {
                            let  _ = print("isLogged")
                            Home()
                                .transition(.opacity)
                        } else {
                            let _ = print("current user == nil")
                            AuthenticationScreen(globalStorage: globalStorage)
                                .transition(.opacity)
                        }
                    }
                }
            .scrollContentBackground(.hidden)
            .environmentObject(globalStorage)
            .environmentObject(globalSettings)
            .environmentObject(globalTimer)
            .onChange(of: scenePhase, perform: { phase in
                switch phase {
                    case .active:
                        //send online status
                        print("scene in foreground: send online status")
                        Task {
                            await globalStorage.goOnline()
                        }

                    case .background:
                        //send offline status
                        //save local cache: images + data( events, users, messages)
                        print("scene in background: send offline status")
                        Task{
                            await globalStorage.goOffline()
                        }

                    case .inactive:
                        print("scene in inactive: send inactive status")
                        Task {
                            await globalStorage.goOffline()
                        }

                    @unknown default:
                        print("scene in unknown phase: send unknown status")
                }
            })
            
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
