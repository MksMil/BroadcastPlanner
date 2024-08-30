import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn



// MARK: - Main App
@main
struct BroadcastPlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var sessionStorage: GlobalSessionStorage = GlobalSessionStorage()
    @StateObject private var globalStorage = GlobalStorage()
    @StateObject private var globalSettings = GlobalSettings()
    @StateObject private var globalTimer = GlobalTimer()
    
    var body: some Scene {
                
        WindowGroup {
            RootView()
                .onChange(of: scenePhase, perform: { phase in
                    if !globalStorage.id.isEmpty{
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
                    }
                })
                .environmentObject(sessionStorage)
                .environmentObject(globalStorage)
                .environmentObject(globalSettings)
                .environmentObject(globalTimer)
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
